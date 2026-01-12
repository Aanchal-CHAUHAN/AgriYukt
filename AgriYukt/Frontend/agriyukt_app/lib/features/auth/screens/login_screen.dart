import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agriyukt_app/features/auth/controllers/login_controller.dart';
import 'package:agriyukt_app/features/onboarding/onboarding_controller.dart';
import 'package:agriyukt_app/core/constants/app_strings.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final authCtrl = Provider.of<LoginController>(context, listen: false);
    final onboardingCtrl =
        Provider.of<OnboardingController>(context, listen: false);

    // Get Selected Language Logic
    final lang = onboardingCtrl.selectedLanguage.isEmpty
        ? 'en'
        : onboardingCtrl.selectedLanguage;
    final str = AppStrings.languages[lang] ?? AppStrings.languages['en']!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const SizedBox(height: 100),
            const Icon(Icons.agriculture, size: 80, color: Colors.green),
            const SizedBox(height: 20),

            // 1. Translated Title
            Text(str['login_title']!,
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
            const SizedBox(height: 50),

            // 2. Translated Email Field
            TextField(
              controller: authCtrl.emailCtrl,
              decoration: InputDecoration(
                labelText: str['email_phone'], // "ईमेल किंवा मोबाईल नंबर"
                prefixIcon: const Icon(Icons.email_outlined),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Translated Password Field
            TextField(
              controller: authCtrl.passCtrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: str['password'], // "पासवर्ड"
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure)),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),

            // 4. Translated Forgot Password Link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/forgot-password'),
                child: Text(str['forgot_pass']!, // "पासवर्ड विसरलात?"
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green)),
              ),
            ),

            const SizedBox(height: 30),

            // 5. Translated Login Button
            Consumer<LoginController>(
              builder: (ctx, auth, _) => auth.isLoading
                  ? const CircularProgressIndicator(color: Colors.green)
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      onPressed: () => auth.login(context),
                      child: Text(str['login_btn']!, // "लॉगिन"
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
            ),

            const SizedBox(height: 30),

            // 6. Translated Create Account Text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(str['no_account']!,
                    style: const TextStyle(
                        color: Colors.black54)), // "खाते नाही? "
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/create-account'),
                  child: Text(str['create_acc']!, // "नवीन खाते तयार करा"
                      style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
