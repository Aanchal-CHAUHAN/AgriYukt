import 'package:flutter/material.dart';
import 'package:agriyukt_app/features/auth/screens/registration/create_account/create_account_controller.dart';
import 'package:agriyukt_app/features/auth/screens/registration/create_account/widgets/input_field.dart';

class BuyerTab extends StatelessWidget {
  final CreateAccountController controller;
  const BuyerTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        InputField(
          label: "Business License Number",
          icon: Icons.business_center,
          controller: controller.extraFieldCtrl, // ✅ Now this works
        ),
        const SizedBox(height: 10),
        const Text(
          "As a Buyer, you can view nearby farms and place orders.",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
