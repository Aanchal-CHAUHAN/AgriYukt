import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agriyukt_app/features/onboarding/onboarding_controller.dart';
import 'package:agriyukt_app/core/constants/app_strings.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Listen to Controller
    final ctrl = Provider.of<OnboardingController>(context);

    // 2. Get Translations based on selection (updates instantly)
    final langCode = ctrl.selectedLanguage;
    final strings = AppStrings.languages[langCode]!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            children: [
              const Spacer(),
              // Animated Container for Logo
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.green.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5)
                    ]),
                child: const Icon(Icons.agriculture_rounded,
                    size: 70, color: Colors.green),
              ),
              const SizedBox(height: 30),

              Text(
                strings['welcome_msg']!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              const SizedBox(height: 10),
              Text(
                strings['select_lang']!,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 50),

              // Language Cards
              _langOption(ctrl, "English", "en"),
              const SizedBox(height: 15),
              _langOption(ctrl, "मराठी (Marathi)", "mr"),

              const Spacer(),

              // Get Started Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                  shadowColor: Colors.green.withOpacity(0.4),
                ),
                onPressed: () => ctrl.saveLanguageAndProceed(context),
                child: Text(
                  strings['get_started']!,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _langOption(OnboardingController ctrl, String name, String code) {
    bool selected = ctrl.selectedLanguage == code;
    return GestureDetector(
      onTap: () => ctrl.selectLanguage(code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: selected ? Colors.green.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: selected ? Colors.green : Colors.grey.shade200, width: 2),
        ),
        child: Row(
          children: [
            Text(
              name,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.green : Colors.black87),
            ),
            const Spacer(),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? Colors.green : Colors.grey.shade400,
            )
          ],
        ),
      ),
    );
  }
}
