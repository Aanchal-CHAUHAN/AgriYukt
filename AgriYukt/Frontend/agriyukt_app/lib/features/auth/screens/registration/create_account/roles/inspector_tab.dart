import 'package:flutter/material.dart';
import 'package:agriyukt_app/features/auth/screens/registration/create_account/create_account_controller.dart';
import 'package:agriyukt_app/features/auth/screens/registration/create_account/widgets/input_field.dart';

class InspectorTab extends StatelessWidget {
  final CreateAccountController controller;
  const InspectorTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        InputField(
          label: "Govt Employee ID",
          icon: Icons.badge,
          controller: controller.extraFieldCtrl, // ✅ Now this works
        ),
        const SizedBox(height: 10),
        const Text(
          "As an Inspector, you will verify farms and approve quality.",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
