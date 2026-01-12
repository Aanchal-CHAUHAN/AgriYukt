import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
<<<<<<< HEAD
import 'package:agriyukt_app/features/auth/screens/login_screen.dart';
import 'package:agriyukt_app/features/common/screens/settings_screen.dart'; // Ensure this exists or remove if not used
=======
// ✅ Import Cart Screen so Bucket works
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
import 'package:agriyukt_app/features/buyer/screens/buyer_cart_screen.dart';

class BuyerDrawer extends StatefulWidget {
  final Function(int) onTabChange;

  const BuyerDrawer({super.key, required this.onTabChange});

  @override
  State<BuyerDrawer> createState() => _BuyerDrawerState();
}

class _BuyerDrawerState extends State<BuyerDrawer> {
<<<<<<< HEAD
  final _supabase = Supabase.instance.client;
  String _userName = "Buyer";
  String _shortId = "0000";
  String _email = "";

  // Buyer Theme Color (Blue)
  final Color _themeColor = const Color(0xFF1565C0); // Material Blue 800
=======
  String _name = "Loading...";
  String _email = "";
  String _displayId = "...";
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
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final data = await Supabase.instance.client
            .from('profiles')
            .select()
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
            .eq('id', user.id)
            .maybeSingle();

        if (mounted) {
          setState(() {
<<<<<<< HEAD
            _email = user.email ?? "";
            // Generate ID from User UID
            _shortId = user.id.substring(0, 4).toUpperCase();
            if (data != null) {
              _userName =
                  "${data['first_name']} ${data['last_name'] ?? ''}".trim();
              if (_userName.isEmpty) _userName = "Buyer";
            }
          });
        }
      } catch (e) {
        debugPrint("Error fetching buyer data: $e");
      }
=======
            if (data != null) {
              String fname = data['first_name'] ?? "";
              String lname = data['last_name'] ?? "";
              _name = "$fname $lname".trim();
              if (_name.isEmpty) _name = "Buyer";
            }
            _email = user.email ?? "";
            // Generate distinct ID from User ID
            String uid = user.id.substring(0, 4).toUpperCase();
            _displayId = "BUY-$uid";
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching drawer profile: $e");
    }
  }

  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
<<<<<<< HEAD
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // --- 1. CLEAN HEADER (Compact Style) ---
          InkWell(
            onTap: () {
              Navigator.pop(context);
              widget.onTabChange(3); // Profile Tab (Index 3)
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              decoration: BoxDecoration(
                color: _themeColor,
                image: const DecorationImage(
                  image: AssetImage(
                      'assets/images/pattern.png'), // Optional pattern
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
                      _userName.isNotEmpty ? _userName[0].toUpperCase() : "B",
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
                          "ID: BUY-$_shortId",
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
                    widget.onTabChange(3); // Profile Tab
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Divider(height: 1, color: Colors.grey, thickness: 0.5),
                ),

                // Home
                _drawerItem(
                  icon: Icons.home_outlined,
                  text: "Home",
                  onTap: () {
                    Navigator.pop(context);
                    widget.onTabChange(0); // Home Tab
                  },
                ),

                // Market
                _drawerItem(
                  icon: Icons.storefront_outlined,
                  text: "Market",
                  onTap: () {
                    Navigator.pop(context);
                    widget.onTabChange(1); // Market Tab
                  },
                ),

                // My Bucket (Cart)
                _drawerItem(
                  icon: Icons.shopping_cart_outlined,
                  text: "My Bucket",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const BuyerCartScreen()),
                    );
                  },
                ),

                // My Orders
                _drawerItem(
                  icon: Icons.receipt_long_outlined,
                  text: "My Orders",
                  onTap: () {
                    Navigator.pop(context);
                    widget.onTabChange(2); // Orders Tab
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
                    // Navigate to Settings Screen if available
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
=======
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ✅ HEADER: Real Data
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(
              "Namaste, $_name",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_email, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "ID: $_displayId",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blue, size: 40),
            ),
          ),

          // ✅ MENU ORDER
          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.blue),
            title: const Text('My Profile'),
            onTap: () {
              widget.onTabChange(3); // Profile is Index 3
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined, color: Colors.blue),
            title: const Text('Home'),
            onTap: () {
              widget.onTabChange(0); // Home is Index 0
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.storefront_outlined, color: Colors.blue),
            title: const Text('Market'),
            onTap: () {
              widget.onTabChange(1); // Market is Index 1
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.shopping_cart_outlined, color: Colors.blue),
            title: const Text('My Bucket'),
            onTap: () {
              Navigator.pop(context);
              // ✅ Navigate to the Real Cart Screen
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const BuyerCartScreen()));
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.receipt_long_outlined, color: Colors.blue),
            title: const Text('My Orders'),
            onTap: () {
              widget.onTabChange(2); // Orders is Index 2
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: Colors.grey),
            title: const Text('Settings'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => _logout(context),
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
    );
  }
=======
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
}
