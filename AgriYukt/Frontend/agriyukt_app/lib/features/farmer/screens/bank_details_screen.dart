import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agriyukt_app/features/common/services/bank_verification_service.dart'; // ✅ Added

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({super.key});

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  final _accountNameCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchExistingDetails();
  }

  @override
  void dispose() {
    _accountNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _ifscCtrl.dispose();
    _bankNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchExistingDetails() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await _supabase
          .from('bank_accounts')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (data != null && mounted) {
        setState(() {
          _accountNameCtrl.text = data['account_holder_name'] ?? '';
          _accountNumberCtrl.text = data['account_number'] ?? '';
          _ifscCtrl.text = data['ifsc_code'] ?? '';
          _bankNameCtrl.text = data['bank_name'] ?? '';
        });
      }
    } catch (e) {
      debugPrint("Fetch error: $e");
    }
  }

  Future<void> _saveDetails() async {
    if (!_formKey.currentState!.validate()) return;

    // 🛡️ RULE-BASED VALIDATION (Stop errors before they reach the DB)
    final String ifsc = _ifscCtrl.text.trim().toUpperCase();
    final String accNum = _accountNumberCtrl.text.trim();

    final syntaxError = BankVerificationService.validateSyntax(ifsc, accNum);
    if (syntaxError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ $syntaxError"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 1. Save to dedicated bank_accounts table
      await _supabase.from('bank_accounts').upsert({
        'user_id': user.id,
        'account_holder_name': _accountNameCtrl.text.trim(),
        'account_number': accNum,
        'ifsc_code': ifsc,
        'bank_name': _bankNameCtrl.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // 2. Sync to profiles meta_data (Ensures PaymentService fallback always works)
      await _supabase.from('profiles').update({
        'meta_data': {
          'bank_name': _bankNameCtrl.text.trim(),
          'account_number': accNum,
          'ifsc_code': ifsc,
        }
      }).eq('id', user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("✅ Bank Details Linked & Verified!"),
            backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Bank Settings"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Payout Account",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Text("Earnings will be transferred to this account.",
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),
              _buildInput("Account Holder Name", _accountNameCtrl,
                  Icons.person_outline),
              _buildInput("Account Number", _accountNumberCtrl, Icons.numbers,
                  isNumber: true),
              _buildInput("IFSC Code", _ifscCtrl, Icons.qr_code_scanner,
                  hint: "e.g. SBIN0001234"),
              _buildInput(
                  "Bank Name", _bankNameCtrl, Icons.account_balance_outlined,
                  hint: "e.g. HDFC Bank"),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveDetails,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("VERIFY & SAVE DETAILS",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              _buildSecurityNote(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
      String label, TextEditingController controller, IconData icon,
      {bool isNumber = false, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        textCapitalization:
            !isNumber ? TextCapitalization.characters : TextCapitalization.none,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.green[700]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green[700]!, width: 2),
          ),
        ),
        validator: (val) => val!.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_outlined, size: 20, color: Colors.blue),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Your payout information is encrypted. We use Rule-Based API Validation to ensure secure transfers.",
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
