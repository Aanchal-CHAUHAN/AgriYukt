import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agriyukt_app/features/onboarding/onboarding_controller.dart';
import 'package:agriyukt_app/core/constants/app_strings.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _inputController = TextEditingController();
  bool _isLoading = false;

  Future<void> _resetPassword(Map<String, String> str) async {
    setState(() => _isLoading = true);
    final input = _inputController.text.trim();

    try {
      // Supabase requires email for password reset
      await Supabase.instance.client.auth.resetPasswordForEmail(input);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                str['link_sent']!), // "रीसेट लिंक आपल्या ई-मेलवर पाठवली आहे!"
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("${str['error_prefix']!}${e.toString()}"), // "त्रुटी: ..."
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get Controller & Language
    final onboardingCtrl =
        Provider.of<OnboardingController>(context, listen: false);
    final lang = onboardingCtrl.selectedLanguage.isEmpty
        ? 'en'
        : onboardingCtrl.selectedLanguage;
    final str = AppStrings.languages[lang] ?? AppStrings.languages['en']!;

    return Scaffold(
      appBar: AppBar(
        title: Text(str['forgot_title']!), // "पासवर्ड विसरलात"
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Header Text
            Text(
              str['reset_header']!, // "पासवर्ड रीसेट करा"
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 10),

            // Description Text
            Text(
              str['reset_desc']!, // "रीसेट लिंक मिळवण्यासाठी..."
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 40),

            // Input Field
            TextField(
              controller: _inputController,
              decoration: InputDecoration(
                labelText: str['email_phone'], // "ई-मेल किंवा मोबाईल क्रमांक"
                prefixIcon: const Icon(Icons.mail_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Send Button
            _isLoading
                ? const CircularProgressIndicator(color: Colors.green)
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () =>
                        _resetPassword(str), // Pass strings to function
                    child: Text(
                      str['send_link']!, // "रीसेट लिंक पाठवा"
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
