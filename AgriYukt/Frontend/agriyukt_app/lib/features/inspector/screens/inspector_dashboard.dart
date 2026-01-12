import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InspectorDashboard extends StatelessWidget {
  const InspectorDashboard({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inspector Dashboard"),
        backgroundColor: Colors.orange, // Inspectors get Orange theme
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          )
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.policy, size: 80, color: Colors.orange),
            SizedBox(height: 20),
            Text("Welcome, Inspector!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("Verification tasks will appear here.",
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
