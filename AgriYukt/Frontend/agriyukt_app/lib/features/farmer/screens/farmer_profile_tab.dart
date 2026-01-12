import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ SCREEN IMPORTS
import 'package:agriyukt_app/features/auth/screens/login_screen.dart';
import 'package:agriyukt_app/features/farmer/screens/edit_profile_screen.dart';
import 'package:agriyukt_app/features/common/screens/verification_screen.dart';
import 'package:agriyukt_app/features/onboarding/screens/language_screen.dart';
import 'package:agriyukt_app/features/common/screens/settings_screen.dart';
import 'package:agriyukt_app/features/common/screens/wallet_screen.dart';
import 'package:agriyukt_app/features/common/screens/support_chat_screen.dart';
import 'package:agriyukt_app/features/common/screens/invite_friend_screen.dart';

class FarmerProfileTab extends StatefulWidget {
  const FarmerProfileTab({super.key});

  @override
  State<FarmerProfileTab> createState() => _FarmerProfileTabState();
}

class _FarmerProfileTabState extends State<FarmerProfileTab> {
  // State Variables
  bool _isLoading = true;
  String _name = "";
  String _location = "India";
  double _walletBalance = 0.0;
  bool _isVerified = false;
  String _activeListings = "0";
  String _rating = "N/A";

  // Modern Palette
  final Color _darkGreen = const Color(0xFF1B5E20);
  final Color _themeColor = const Color(0xFF2E7D32);
  final Color _bgOffWhite = const Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    await Future.wait([
      _fetchProfile(),
      _fetchWalletBalance(),
      _fetchStats(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final data = await Supabase.instance.client
            .from('profiles')
            .select('first_name, last_name, is_verified, city, state')
            .eq('id', user.id)
            .maybeSingle();

        if (mounted && data != null) {
          setState(() {
            String fName = data['first_name'] ?? '';
            String lName = data['last_name'] ?? '';
            _name = "$fName $lName".trim();
            if (_name.isEmpty) _name = "Farmer";

            _isVerified = data['is_verified'] ?? false;

            String city = data['city'] ?? '';
            String state = data['state'] ?? '';
            if (city.isNotEmpty && state.isNotEmpty) {
              _location = "$city, $state";
            } else if (state.isNotEmpty) {
              _location = state;
            }
          });
        }
      } catch (e) {
        debugPrint("Error fetching profile: $e");
      }
    }
  }

  Future<void> _fetchWalletBalance() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final data = await Supabase.instance.client
            .from('wallets')
            .select('balance')
            .eq('user_id', user.id)
            .maybeSingle();

        if (mounted) {
          setState(() {
            _walletBalance =
                data != null ? (data['balance'] as num).toDouble() : 0.0;
          });
        }
      } catch (e) {
        // debugPrint("Error fetching wallet: $e");
      }
    }
  }

  Future<void> _fetchStats() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final countResponse = await Supabase.instance.client
            .from('products')
            .select('*')
            .eq('farmer_id', user.id)
            .eq('status', 'active')
            .count(CountOption.exact);

        if (mounted) {
          setState(() {
            _activeListings = countResponse.count.toString();
          });
        }
      } catch (e) {
        // debugPrint("Stats fetch info: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _name.isEmpty) {
      return Scaffold(
        backgroundColor: _bgOffWhite,
        body: Center(child: CircularProgressIndicator(color: _themeColor)),
      );
    }

    return Scaffold(
      backgroundColor: _bgOffWhite,
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        color: _themeColor,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // --- 1. HEADER SECTION ---
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Gradient Background
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_darkGreen, _themeColor],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -60,
                          right: -60,
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                        ),
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                            child: Column(
                              children: [
                                // Top Profile Row
                                Row(
                                  children: [
                                    _buildProfileImage(),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _greetingMessage(),
                                            style: TextStyle(
                                              color: Colors.green.shade100,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 25),

                                // Glass Stats Row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _glassStatCard(Icons.inventory_2_outlined,
                                        _activeListings, "Listings"),
                                    const SizedBox(width: 8),
                                    _glassStatCard(Icons.star_border_rounded,
                                        _rating, "Rating"),
                                    const SizedBox(width: 8),
                                    _glassStatCard(Icons.location_on_outlined,
                                        _location, "Region"),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Floating Wallet Card (Overlapping)
                  Positioned(
                    bottom: -10,
                    left: 20,
                    right: 20,
                    child: _buildWalletCard(),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // --- 2. BODY CONTENT ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quick Actions",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Grid Menu
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: [
                        _modernGridItem(
                          icon: Icons.person_outline,
                          title: "Edit Profile",
                          subtitle: "Update details",
                          color: Colors.blue,
                          onTap: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const EditProfileScreen()));
                            _loadAllData();
                          },
                        ),
                        _modernGridItem(
                          icon: Icons.verified_user_outlined,
                          title: "Verification",
                          subtitle: _isVerified ? "Verified" : "Pending",
                          color: _isVerified ? _themeColor : Colors.orange,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const VerificationScreen())),
                        ),
                        _modernGridItem(
                          icon: Icons.translate,
                          title: "Language",
                          subtitle: "Eng / मराठी",
                          color: Colors.purple,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LanguageScreen())),
                        ),
                        _modernGridItem(
                          icon: Icons.support_agent,
                          title: "AgriBot",
                          subtitle: "24/7 Support",
                          color: Colors.teal,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const SupportChatScreen(role: 'farmer'))),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Settings List
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Column(
                        children: [
                          _modernListOption(
                            icon: Icons.settings_outlined,
                            title: "Settings",
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => SettingsScreen(
                                        themeColor: _themeColor))),
                          ),
                          const Divider(height: 1, indent: 60, endIndent: 20),
                          _modernListOption(
                            icon: Icons.history,
                            title: "Order History",
                            onTap: () {},
                          ),
                          const Divider(height: 1, indent: 60, endIndent: 20),
                          _modernListOption(
                            icon: Icons.share_outlined,
                            title: "Invite Farmers",
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const InviteFriendScreen())),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await Supabase.instance.client.auth.signOut();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/login', (route) => false);
                          }
                        },
                        icon: Icon(Icons.logout, color: Colors.red[400]),
                        label: Text(
                          "Log Out",
                          style: TextStyle(
                              color: Colors.red[400],
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red.shade100),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          backgroundColor: Colors.red.shade50.withOpacity(0.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Center(
                        child: Text("AgriYukt v1.0.0",
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 12))),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER METHODS ---

  Widget _glassStatCard(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.green.shade100, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
          ),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Text(
              _name.isNotEmpty ? _name[0].toUpperCase() : "F",
              style: TextStyle(
                  color: _themeColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        if (_isVerified)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.verified, color: Colors.blue, size: 16),
            ),
          ),
      ],
    );
  }

  Widget _buildWalletCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: _bgOffWhite,
                        borderRadius: BorderRadius.circular(16)),
                    child: Icon(Icons.account_balance_wallet_rounded,
                        color: _themeColor, size: 26),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Wallet Balance",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text("₹${_walletBalance.toStringAsFixed(2)}",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.grey[900])),
                    ],
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  // ✅ FIXED: Pass themeColor instead of balance
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  WalletScreen(themeColor: _themeColor)))
                      .then((_) => _fetchWalletBalance());
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _themeColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                          color: _themeColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: const Text("View",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modernGridItem(
      {required IconData icon,
      required String title,
      required String subtitle,
      required Color color,
      required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modernListOption(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.grey[800], size: 20),
      ),
      title: Text(title,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87)),
      trailing: Icon(Icons.chevron_right, size: 20, color: Colors.grey[400]),
    );
  }

  String _greetingMessage() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }
}
