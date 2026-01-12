import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
<<<<<<< HEAD
import 'package:agriyukt_app/features/auth/screens/login_screen.dart';
import 'package:agriyukt_app/features/common/screens/settings_screen.dart';
import 'package:agriyukt_app/features/common/screens/wallet_screen.dart';
// ✅ Import Active Crops Screen
import 'package:agriyukt_app/features/inspector/screens/inspector_active_crops_screen.dart';
// ✅ Import Mapped Farmers Screen
import 'package:agriyukt_app/features/inspector/screens/inspector_farmers_tab.dart';
// Note: You might need to adjust this import based on where your Inspector Add Crop screen is located
import 'package:agriyukt_app/features/inspector/screens/inspector_add_crop_tab.dart';

class InspectorDrawer extends StatefulWidget {
  final Function(int) onItemSelected;
  const InspectorDrawer({super.key, required this.onItemSelected});

  @override
  State<InspectorDrawer> createState() => _InspectorDrawerState();
}

class _InspectorDrawerState extends State<InspectorDrawer> {
  final _supabase = Supabase.instance.client;
  String _userName = "Inspector";
  String _shortId = "0000";
  String _email = "";

  // Inspector Theme Color (Orange)
  final Color _themeColor = const Color(0xFFE65100);

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        final data = await _supabase
            .from('profiles')
            .select('first_name, last_name, employee_id')
            .eq('id', user.id)
            .maybeSingle();

        if (mounted) {
          setState(() {
            _email = user.email ?? "";
            // Use employee_id if available, else fallback to user ID substring
            _shortId =
                data?['employee_id'] ?? user.id.substring(0, 4).toUpperCase();
            if (data != null) {
              _userName =
                  "${data['first_name']} ${data['last_name'] ?? ''}".trim();
            }
          });
        }
      } catch (e) {
        debugPrint("Error fetching inspector data: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // --- 1. CLEAN HEADER (Compact) ---
          InkWell(
            onTap: () {
              Navigator.pop(context);
              widget.onItemSelected(3); // Profile Tab
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              decoration: BoxDecoration(
                color: _themeColor, // Inspector Orange
                image: const DecorationImage(
                  image: AssetImage('assets/images/pattern.png'),
                  opacity: 0.1,
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      _userName.isNotEmpty ? _userName[0].toUpperCase() : "I",
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: _themeColor),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Namaste, $_userName",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "ID: $_shortId",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- 2. MENU ITEMS ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                // Profile
                _drawerItem(
                  icon: Icons.person_outline,
                  text: "My Profile",
                  onTap: () {
                    Navigator.pop(context);
                    widget.onItemSelected(3); // Profile Tab
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Divider(height: 1, color: Colors.grey, thickness: 0.5),
                ),

                // Dashboard
                _drawerItem(
                  icon: Icons.dashboard_outlined,
                  text: "Dashboard",
                  onTap: () {
                    Navigator.pop(context);
                    widget.onItemSelected(0); // Dashboard Tab
                  },
                ),

                // Add Crop (Inspector Mode)
                _drawerItem(
                  icon: Icons.add_circle_outline,
                  text: "Add Crop (For Farmer)",
                  color: _themeColor,
                  isBold: true,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to Inspector Add Crop Screen
                    widget.onItemSelected(1);
                  },
                ),

                // ✅ NEW ITEM: Active Crops (All Farmers)
                _drawerItem(
                  icon: Icons.grass,
                  text: "Active Crops",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const InspectorActiveCropsScreen()),
                    );
                  },
                ),

                // ✅ Mapped Farmers (Opens as New Screen)
                _drawerItem(
                  icon: Icons.people_outline,
                  text: "Mapped Farmers",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const InspectorFarmersTab()),
                    );
                  },
                ),

                // My Orders
                _drawerItem(
                  icon: Icons.shopping_bag_outlined,
                  text: "My Orders",
                  onTap: () {
                    Navigator.pop(context);
                    widget.onItemSelected(2); // Orders Tab
                  },
                ),

                // Wallet
                _drawerItem(
                  icon: Icons.account_balance_wallet_outlined,
                  text: "Wallet",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WalletScreen(themeColor: _themeColor),
                      ),
                    );
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Divider(height: 1, thickness: 0.5),
                ),

                // Settings
                _drawerItem(
                  icon: Icons.settings_outlined,
                  text: "Settings",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                SettingsScreen(themeColor: _themeColor)));
                  },
                ),
              ],
            ),
          ),

          // --- 3. LOGOUT ---
          SafeArea(
            bottom: true,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red, size: 24),
                title: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onTap: () async {
                  await _supabase.auth.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ),
          ),
=======

class InspectorDrawer extends StatelessWidget {
  final Function(int) onItemSelected;

  const InspectorDrawer({
    super.key,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Drawer(
      child: Column(
        children: [
          // Header Pad: AgriYukt Inspector (ORANGE THEME)
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFFE65100), // ✅ Orange Theme
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child:
                  Icon(Icons.verified_user, color: Color(0xFFE65100), size: 40),
            ),
            accountName: const Text(
              "AgriYukt Inspector",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(user?.email ?? "inspector@agriyukt.com"),
          ),

          // Menu Items (Orange Icons)
          ListTile(
            leading:
                const Icon(Icons.dashboard_outlined, color: Color(0xFFE65100)),
            title: const Text("Dashboard / Stats"),
            onTap: () {
              onItemSelected(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.add_circle_outline, color: Color(0xFFE65100)),
            title: const Text("Add New Crop"),
            onTap: () {
              onItemSelected(1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_outline, color: Color(0xFFE65100)),
            title: const Text("Mapped Farmers"),
            onTap: () {
              onItemSelected(2);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline, color: Color(0xFFE65100)),
            title: const Text("Profile Settings"),
            onTap: () {
              onItemSelected(3);
              Navigator.pop(context);
            },
          ),

          const Spacer(),
          const Divider(),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              }
            },
          ),
          const SizedBox(height: 20),
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
        ],
      ),
    );
  }
<<<<<<< HEAD

  Widget _drawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color color = const Color(0xFF424242),
    bool isBold = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      visualDensity: VisualDensity.compact,
      minVerticalPadding: 10,
      leading: Icon(icon, color: color, size: 24),
      title: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 15,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
=======
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
}
