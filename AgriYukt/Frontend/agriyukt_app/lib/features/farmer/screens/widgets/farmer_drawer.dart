import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
<<<<<<< HEAD
import 'package:agriyukt_app/features/auth/screens/login_screen.dart';
import 'package:agriyukt_app/features/farmer/screens/add_crop_screen.dart';
import 'package:agriyukt_app/features/common/screens/settings_screen.dart';
// ✅ Import the new Wallet Screen
import 'package:agriyukt_app/features/common/screens/wallet_screen.dart';
=======
import 'package:agriyukt_app/features/farmer/screens/add_crop_screen.dart';
import 'package:agriyukt_app/features/farmer/screens/farmer_inspector_request_screen.dart';
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416

class FarmerDrawer extends StatefulWidget {
  final Function(int) onTabChange;
  const FarmerDrawer({super.key, required this.onTabChange});

  @override
  State<FarmerDrawer> createState() => _FarmerDrawerState();
}

class _FarmerDrawerState extends State<FarmerDrawer> {
<<<<<<< HEAD
  final _supabase = Supabase.instance.client;
  String _userName = "Farmer";
  String _shortId = "0000";
  String _email = "";
=======
  bool _isInspectorMode = false;
  bool _loading = true;
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        final data = await _supabase
            .from('profiles')
            .select('first_name, last_name')
=======
    _checkInspectorMode();
  }

  // 1. Check if Inspector Mode is enabled in DB
  Future<void> _checkInspectorMode() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final data = await Supabase.instance.client
            .from('profiles')
            .select('inspector_request')
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
            .eq('id', user.id)
            .maybeSingle();

        if (mounted) {
          setState(() {
<<<<<<< HEAD
            _email = user.email ?? "";
            _shortId = user.id.substring(0, 4).toUpperCase();
            if (data != null) {
              _userName =
                  "${data['first_name']} ${data['last_name'] ?? ''}".trim();
            }
          });
        }
      } catch (e) {
        debugPrint("Error fetching drawer data: $e");
=======
            _isInspectorMode = data?['inspector_request'] ?? false;
            _loading = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _loading = false);
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
      }
    }
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // --- 1. CLEAN HEADER ---
          InkWell(
            onTap: () {
              Navigator.pop(context);
              widget.onTabChange(3); // Profile Tab
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32), // Farmer Green
                image: DecorationImage(
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
                      _userName.isNotEmpty ? _userName[0].toUpperCase() : "F",
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32)),
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
                          "ID: AGRI-$_shortId",
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
                _drawerItem(
                  icon: Icons.person_outline,
                  text: "My Profile",
                  onTap: () {
                    Navigator.pop(context);
                    widget.onTabChange(3);
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Divider(height: 1, color: Colors.grey, thickness: 0.5),
                ),

                _drawerItem(
                  icon: Icons.dashboard_outlined,
                  text: "Dashboard",
                  onTap: () {
                    Navigator.pop(context);
                    widget.onTabChange(0);
                  },
                ),
                _drawerItem(
                  icon: Icons.add_circle_outline,
                  text: "Add New Crop",
                  color: const Color(0xFF2E7D32),
                  isBold: true,
=======
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? "farmer@agriyukt.com";

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF2E7D32)),
            accountName: const Text("Namaste, Farmer",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: Text(
                "$email\nID: AGRI-${user?.id.substring(0, 4).toUpperCase() ?? '0000'}"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child:
                  Icon(Icons.agriculture, size: 40, color: Color(0xFF2E7D32)),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _menuItem(context, Icons.person, "My Profile", 3),
                const Divider(),
                _menuItem(context, Icons.dashboard, "Dashboard", 0),

                // ✅ 2. CONDITIONAL ADD CROP BUTTON
                if (_loading)
                  const ListTile(title: Text("Loading..."))
                else if (_isInspectorMode)
                  // 🔒 LOCKED STATE (Inspector Mode ON)
                  ListTile(
                    leading: const Icon(Icons.lock, color: Colors.grey),
                    title: const Text("Add New Crop",
                        style: TextStyle(color: Colors.grey)),
                    subtitle: const Text(
                        "Managed by Inspector (View/Edit Only)",
                        style: TextStyle(fontSize: 10)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            "Inspector Mode is ON. Only Inspectors can add crops. You can still Edit/Delete existing ones."),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 3),
                      ));
                    },
                  )
                else
                  // 🔓 UNLOCKED STATE (Self Mode)
                  ListTile(
                    leading: const Icon(Icons.add_circle, color: Colors.orange),
                    title: const Text("Add New Crop",
                        style: TextStyle(
                            color: Colors.orange, fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddCropScreen()));
                    },
                  ),

                _menuItem(context, Icons.grass, "Active Crops", 1),
                _menuItem(context, Icons.shopping_bag, "My Orders", 2),
                const Divider(),

                // Inspector Mode Toggle Link
                ListTile(
                  leading: Icon(
                      _isInspectorMode
                          ? Icons.verified_user
                          : Icons.verified_user_outlined,
                      color: _isInspectorMode ? Colors.green : Colors.orange),
                  title: const Text("Inspector Mode"),
                  subtitle: Text(
                      _isInspectorMode ? "Active" : "Request Verification"),
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
<<<<<<< HEAD
                            builder: (_) => const AddCropScreen()));
                  },
                ),
                _drawerItem(
                  icon: Icons.grass_outlined,
                  text: "Active Crops",
                  onTap: () {
                    Navigator.pop(context);
                    widget.onTabChange(1);
                  },
                ),
                _drawerItem(
                  icon: Icons.shopping_bag_outlined,
                  text: "My Orders",
                  onTap: () {
                    Navigator.pop(context);
                    widget.onTabChange(2);
                  },
                ),

                // ✅ NEW WALLET ITEM ADDED HERE
                _drawerItem(
                  icon: Icons.account_balance_wallet_outlined,
                  text: "My Wallet",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const WalletScreen(themeColor: Color(0xFF2E7D32)),
                      ),
                    );
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Divider(height: 1, thickness: 0.5),
                ),

                _drawerItem(
                  icon: Icons.settings_outlined,
                  text: "Settings",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen(
                                themeColor: Color(0xFF2E7D32))));
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
=======
                            builder: (_) =>
                                const FarmerInspectorRequestScreen())).then(
                        (_) => _checkInspectorMode()); // Refresh on return
                  },
                ),

                const Divider(),
                _menuItem(context, Icons.settings, "Settings", -1),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted)
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
            },
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
          ),
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
=======
  Widget _menuItem(
      BuildContext context, IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        if (index != -1) widget.onTabChange(index);
      },
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
    );
  }
}
