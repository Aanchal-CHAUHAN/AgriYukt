import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WithdrawalScreen extends StatefulWidget {
  final double availableBalance;

  const WithdrawalScreen({super.key, required this.availableBalance});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final _supabase = Supabase.instance.client;
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  Map<String, dynamic>? _bankDetails;

  @override
  void initState() {
    super.initState();
    _fetchBankDetails();
  }

  /// 1. Pre-fetch bank details to show where money will go
  Future<void> _fetchBankDetails() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final data = await _supabase
          .from('bank_accounts')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _bankDetails = data;
        });
      }
    } catch (e) {
      debugPrint("Error fetching bank details: $e");
    }
  }

  /// 2. Process the Withdrawal
  Future<void> _requestWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;

    // Safety Check: Bank Details must exist
    if (_bankDetails == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Please link a bank account in settings first."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = double.parse(_amountController.text.trim());

    // Safety Check: Balance Limit
    if (amount > widget.availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("❌ Insufficient funds."),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = _supabase.auth.currentUser!.id;

      // A. Create the Withdrawal Request Record
      // We save a snapshot of bank details so even if they change it later,
      // we know where this specific request was supposed to go.
      await _supabase.from('withdrawals').insert({
        'user_id': userId,
        'amount': amount,
        'status': 'pending', // Pending Admin Approval
        'bank_snapshot': _bankDetails,
        'created_at': DateTime.now().toIso8601String(),
      });

      // B. Deduct Balance Immediately (Prevent Double Spend)
      // This calls the secure Postgres Function we created
      await _supabase.rpc('deduct_wallet_balance', params: {
        'p_user_id': userId,
        'p_amount': amount,
      });

      if (mounted) {
        _showSuccessDialog(amount);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 50),
            SizedBox(height: 10),
            Text("Request Submitted"),
          ],
        ),
        content: Text(
          "Your request to withdraw ₹$amount has been received.\n\n"
          "Funds will be transferred to ${_bankDetails?['bank_name'] ?? 'your bank'} within 12-24 hours.",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close Dialog
              Navigator.pop(context); // Go back to Wallet Screen
            },
            child: const Text("DONE",
                style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Withdraw Funds"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BALANCE CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    Text("Available Balance",
                        style:
                            TextStyle(color: Colors.green[800], fontSize: 14)),
                    const SizedBox(height: 5),
                    Text("₹${widget.availableBalance.toStringAsFixed(2)}",
                        style: TextStyle(
                            color: Colors.green[900],
                            fontSize: 36,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // INPUT FIELD
              const Text("Enter Amount to Withdraw",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixText: "₹ ",
                  hintText: "0.00",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Enter an amount";
                  final n = double.tryParse(val);
                  if (n == null || n <= 0) return "Invalid amount";
                  if (n > widget.availableBalance)
                    return "Exceeds available balance";
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // BANK INFO PREVIEW
              if (_bankDetails != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance, color: Colors.grey),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Transferring to:",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            Text(
                                "${_bankDetails!['bank_name']} •••• ${_bankDetails!['account_number'].toString().substring(_bankDetails!['account_number'].toString().length - 4)}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 18)
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red),
                      SizedBox(width: 10),
                      Text("No bank account linked!",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

              const SizedBox(height: 40),

              // ACTION BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: (_isLoading || _bankDetails == null)
                      ? null
                      : _requestWithdrawal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("CONFIRM WITHDRAWAL",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
