import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agriyukt_app/features/farmer/screens/edit_profile_screen.dart';
// ✅ Import Verification Screen
import 'package:agriyukt_app/features/common/screens/verification_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String _name = "Farmer";
  String _role = "Farmer";

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('first_name, last_name, role')
          .eq('id', user.id)
          .maybeSingle();

      if (mounted && data != null) {
        setState(() {
          _name = "${data['first_name']} ${data['last_name']}";
          _role = data['role'] ?? "Farmer";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child:
                        Icon(Icons.person, size: 40, color: Color(0xFF2E7D32)),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_name,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text(_role,
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. Menu Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _profileOption(
                      icon: Icons.edit,
                      title: "Edit Profile",
                      subtitle: "Personal, Farm & Location Details",
                      onTap: () async {
                        // Navigate and wait for result to refresh
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const EditProfileScreen()));
                        _fetchProfile(); // Refresh name if changed
                      }),

                  // ✅ NEW: Verification Center (Farmer)
                  _profileOption(
                      icon: Icons.verified_user,
                      title: "Verification Center",
                      subtitle: "Upload Aadhar for Approval",
                      // Optional: Highlight color logic can be added here if needed
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const VerificationScreen()),
                        );
                      }),

                  _profileOption(
                      icon: Icons.language,
                      title: "Change Language",
                      subtitle: "English, Hindi, Marathi",
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Coming Soon!")));
                      }),
                  _profileOption(
                      icon: Icons.help_outline,
                      title: "Help & Support",
                      subtitle: "FAQs, Contact Us",
                      onTap: () {}),
                  _profileOption(
                      icon: Icons.info_outline,
                      title: "About App",
                      subtitle: "Version 1.0.0",
                      onTap: () {}),

                  const SizedBox(height: 20),

                  // Logout Button
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.logout, color: Colors.red),
                    ),
                    title: const Text("Logout",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red)),
                    onTap: () async {
                      await Supabase.instance.client.auth.signOut();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/login', (route) => false);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileOption(
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: Colors.green),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
