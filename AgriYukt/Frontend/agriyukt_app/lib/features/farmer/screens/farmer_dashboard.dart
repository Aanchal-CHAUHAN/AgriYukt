import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FarmerDashboard extends StatelessWidget {
  const FarmerDashboard({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    // 1. Sign out from Supabase
    await Supabase.instance.client.auth.signOut();

    // 2. Go to Login Screen (and remove all previous routes so back button doesn't work)
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Farmer Dashboard"),
        backgroundColor: Colors.green,
        actions: [
          // LOGOUT BUTTON
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () => _handleLogout(context),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              accountName: Text("Farmer Name"), // Placeholder for now
              accountEmail: Text("farmer@example.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.green),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () => _handleLogout(context),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.agriculture, size: 80, color: Colors.green),
            SizedBox(height: 20),
            Text("Welcome, Farmer!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("Your crops will appear here.",
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Future: Go to Add Crop Screen
        },
        label: const Text("Add Crop"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}
