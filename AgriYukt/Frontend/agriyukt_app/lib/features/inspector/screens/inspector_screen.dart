import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InspectorScreen extends StatelessWidget {
  const InspectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inspector Dashboard"),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Supabase.instance.client.auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: const Center(
          child: Text("Welcome Inspector! \nAudit tasks coming soon...",
              textAlign: TextAlign.center)),
    );
  }
}
