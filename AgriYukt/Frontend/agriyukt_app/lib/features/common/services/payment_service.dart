import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Note: BankVerificationService import removed as we are skipping strict checks

class PaymentService {
  final SupabaseClient _supabase = Supabase.instance.client;
  late Razorpay _razorpay;

  // 🔴 IMPORTANT: REPLACE THIS WITH YOUR REAL RAZORPAY TEST KEY
  static const String _razorpayKey = 'rzp_test_YourTestKeyHere';

  // Callbacks
  Function(bool)? _onResult;
  BuildContext? _context;

  // Transaction Data
  String? _currentOrderId;

  PaymentService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  /// ✅ MAIN PROCESS: FETCH -> PAY (Direct Logic)
  Future<void> processPayment({
    required BuildContext context,
    required String orderId,
    required String farmerId,
    required double amount,
    required Function(bool) onResult,
    String farmerName = "Farmer",
  }) async {
    _context = context;
    _currentOrderId = orderId;
    _onResult = onResult;

    try {
      // 1. FETCH FARMER'S BANK DETAILS (Just to attach to the order notes)
      Map<String, dynamic>? bankDetails;

      // A. Try dedicated bank_accounts table
      final bankAccountTable = await _supabase
          .from('bank_accounts')
          .select('bank_name, account_number, ifsc_code, account_holder_name')
          .eq('user_id', farmerId)
          .maybeSingle();

      if (bankAccountTable != null) {
        bankDetails = bankAccountTable;
      } else {
        // B. Fallback: Check profiles meta_data
        final profile = await _supabase
            .from('profiles')
            .select('meta_data, first_name, last_name')
            .eq('id', farmerId)
            .maybeSingle();

        if (profile != null && profile['meta_data'] != null) {
          final meta = profile['meta_data'] as Map<String, dynamic>;
          if (meta.containsKey('account_number') &&
              meta['account_number'] != null) {
            bankDetails = {
              'bank_name': meta['bank_name'] ?? 'Bank',
              'account_number': meta['account_number'],
              'ifsc_code': meta['ifsc_code'],
              'account_holder_name':
                  "${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}"
                      .trim(),
            };
          }
        }
      }

      // If absolutely no bank details found, we stop (because you can't pay them later)
      if (bankDetails == null) {
        _showSnack("⚠️ Farmer has not linked bank details yet.", isError: true);
        _onResult?.call(false);
        return;
      }

      String bankName = bankDetails['bank_name'] ?? 'Bank';
      String accHolder = (bankDetails['account_holder_name'] != null &&
              bankDetails['account_holder_name'].toString().isNotEmpty)
          ? bankDetails['account_holder_name']
          : farmerName;

      // ---------------------------------------------------------
      // 🚀 STEP 2: LAUNCH RAZORPAY IMMEDIATELY
      // (Verification removed as requested)
      // ---------------------------------------------------------

      final user = _supabase.auth.currentUser;
      final userEmail = user?.email ?? 'buyer@agriyukt.com';
      final userPhone = user?.phone ?? '9876543210';

      var options = {
        'key': _razorpayKey, // ✅ Your Platform Key
        'amount': (amount * 100).toInt(),
        'name': accHolder,
        'description': "Payment to $bankName",
        'retry': {'enabled': true, 'max_count': 1},
        'send_sms_hash': true,
        'prefill': {
          'contact': userPhone,
          'email': userEmail,
        },
        'notes': {
          'order_id': orderId,
          'farmer_id': farmerId,
          'bank_target': bankName // Just for your record
        }
      };

      _razorpay.open(options);
    } catch (e) {
      debugPrint("Payment Logic Error: $e");
      _showSnack("System Error: $e", isError: true);
      _onResult?.call(false);
    }
  }

  /// ✅ SUCCESS HANDLER
  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_currentOrderId == null) return;

    try {
      // Update Database -> Triggers "Locked Wallet" Logic
      await _supabase.from('orders').update({
        'payment_status': 'paid_confirmed',
        'tracking_status': 'Accepted',
        'payment_id': response.paymentId,
        'payment_date': DateTime.now().toIso8601String(),
      }).eq('id', _currentOrderId!);

      debugPrint("✅ Payment Success: ${response.paymentId}");
      _showSnack("✅ Payment Successful! Money Secured in Escrow.",
          isError: false);

      _onResult?.call(true);
    } catch (e) {
      debugPrint("❌ DB Update Error: $e");
      _showSnack(
          "Payment succeeded but order update failed. Please contact support.",
          isError: true);
      _onResult?.call(false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint("❌ Payment Failed: ${response.code} - ${response.message}");
    _showSnack("Payment Failed: ${response.message}", isError: true);
    _onResult?.call(false);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("⚠️ External Wallet: ${response.walletName}");
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (_context != null) {
      ScaffoldMessenger.of(_context!).hideCurrentSnackBar();
      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: isError ? Colors.red : Colors.green[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
