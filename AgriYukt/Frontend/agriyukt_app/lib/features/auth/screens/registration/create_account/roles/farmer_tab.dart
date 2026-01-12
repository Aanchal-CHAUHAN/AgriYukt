import 'package:flutter/material.dart';
import 'package:agriyukt_app/features/auth/screens/registration/create_account/create_account_controller.dart';
import 'package:agriyukt_app/features/auth/screens/registration/create_account/widgets/input_field.dart';

class FarmerTab extends StatelessWidget {
  final CreateAccountController controller;
  const FarmerTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        InputField(
          label: "Kisan Card / Farm Size (Acres)",
          icon: Icons.landscape,
          controller: controller.extraFieldCtrl, // ✅ Now this works
        ),
        const SizedBox(height: 10),
        const Text(
          "As a Farmer, you can list crops and connect directly with buyers.",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
