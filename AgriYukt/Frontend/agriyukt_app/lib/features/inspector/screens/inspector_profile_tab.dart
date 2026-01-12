import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
<<<<<<< HEAD

// ✅ SCREEN IMPORTS
import 'package:agriyukt_app/features/auth/screens/login_screen.dart';
import 'package:agriyukt_app/features/farmer/screens/edit_profile_screen.dart';
import 'package:agriyukt_app/features/onboarding/screens/language_screen.dart';
import 'package:agriyukt_app/features/common/screens/settings_screen.dart';
import 'package:agriyukt_app/features/common/screens/wallet_screen.dart';
import 'package:agriyukt_app/features/common/screens/support_chat_screen.dart';
import 'package:agriyukt_app/features/inspector/screens/order_history_screen.dart';

// ✅ NEW INSPECTOR IMPORTS
import 'package:agriyukt_app/features/inspector/screens/add_farmer_screen.dart';
import 'package:agriyukt_app/features/inspector/screens/audit_history_screen.dart';
import 'package:agriyukt_app/features/inspector/screens/inspector_orders_tab.dart';
=======
import 'package:agriyukt_app/features/farmer/screens/edit_profile_screen.dart';
import 'package:agriyukt_app/features/common/screens/verification_screen.dart'; // ✅ Import Verification Screen
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416

class InspectorProfileTab extends StatefulWidget {
  const InspectorProfileTab({super.key});

  @override
  State<InspectorProfileTab> createState() => _InspectorProfileTabState();
}

class _InspectorProfileTabState extends State<InspectorProfileTab> {
<<<<<<< HEAD
  // State Variables
  bool _isLoading = true;
  String _name = "Inspector";
  String _location = "India";
  double _walletBalance = 0.0;
  bool _isVerified = true;

  // Stats
  String _pendingAudits = "0";
  String _completedAudits = "0";

  // ✅ EXACT INSPECTOR ORANGE THEME
  final Color _darkTheme = const Color(0xFFBF360C);
  final Color _themeColor = const Color(0xFFE65100);
  final Color _bgOffWhite = const Color(0xFFF5F7FA);
=======
  String _name = "Inspector";
  String _role = "Field Officer";
  String _email = "";
  String _verificationStatus = "Pending"; // ✅ Track Status
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
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
            if (_name.isEmpty) _name = "Inspector";

            _isVerified = data['is_verified'] ?? true;

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
        final pendingData = await Supabase.instance.client
            .from('inspections')
            .select('id')
            .eq('inspector_id', user.id)
            .eq('status', 'pending');

        final completedData = await Supabase.instance.client
            .from('inspections')
            .select('id')
            .eq('inspector_id', user.id)
            .eq('status', 'completed');

        if (mounted) {
          setState(() {
            _pendingAudits = (pendingData as List).length.toString();
            _completedAudits = (completedData as List).length.toString();
          });
        }
      } catch (e) {
        // Fail silently
=======
    _fetchProfile();
  }

  // ✅ Fetch Real Inspector Data + Verification Status
  Future<void> _fetchProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _email = user.email ?? "";
      final data = await Supabase.instance.client
          .from('profiles')
          .select('first_name, last_name, role, verification_status')
          .eq('id', user.id)
          .maybeSingle();

      if (mounted && data != null) {
        setState(() {
          _name = "${data['first_name']} ${data['last_name']}";
          _role = data['role'] ?? "Inspector";
          _verificationStatus = data['verification_status'] ?? "Pending";
        });
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
      }
    }
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    if (_isLoading && _name == "Inspector") {
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
                    height: 290,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_darkTheme, _themeColor],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: SafeArea(
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _greetingMessage(),
                                        style: TextStyle(
                                          color: Colors.orange.shade100,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _glassStatCard(Icons.pending_actions,
                                    _pendingAudits, "Pending"),
                                const SizedBox(width: 8),
                                _glassStatCard(Icons.task_alt, _completedAudits,
                                    "Completed"),
                                const SizedBox(width: 8),
                                _glassStatCard(Icons.location_on_outlined,
                                    _location, "Region"),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Floating Wallet Card - FIXED
                  Positioned(
                    bottom: -10,
                    left: 16,
                    right: 16,
                    child: _buildWalletCard(),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // --- 2. MENU GRID ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Audit Management",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: [
                        _modernGridItem(
                          icon: Icons.person_outline,
                          title: "Edit Profile",
                          subtitle: "Update info",
                          color: Colors.blue,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            );
                            _fetchProfile();
                          },
                        ),
                        // FUNCTIONAL NEW AUDITS
                        _modernGridItem(
                          icon: Icons.fact_check_outlined,
                          title: "New Audits",
                          subtitle: "Check requests",
                          color: _themeColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const InspectorOrdersTab()),
                            );
                          },
                        ),
                        _modernGridItem(
                          icon: Icons.translate,
                          title: "Language",
                          subtitle: "Eng / मराठी",
                          color: Colors.purple,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LanguageScreen()),
                          ),
                        ),
                        _modernGridItem(
                          icon: Icons.support_agent,
                          title: "Support HQ",
                          subtitle: "Admin Help",
                          color: Colors.teal,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const SupportChatScreen(role: 'inspector')),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // --- 3. LIST MENU ---
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // MAPPED FARMERS
                          _modernListOption(
                            icon: Icons.groups_outlined,
                            title: "Mapped Farmers",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const AddFarmerScreen()),
                              );
                            },
                          ),
                          const Divider(height: 1, indent: 60, endIndent: 20),

                          // AUDIT HISTORY
                          _modernListOption(
                            icon: Icons.history_edu,
                            title: "Audit History",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const AuditHistoryScreen()),
                              );
                            },
                          ),
                          const Divider(height: 1, indent: 60, endIndent: 20),

                          // ✅ ORDER HISTORY
                          _modernListOption(
                            icon: Icons.receipt_long,
                            title: "Order History",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const OrderHistoryScreen()),
                              );
                            },
                          ),
                          const Divider(height: 1, indent: 60, endIndent: 20),

                          // SETTINGS
                          _modernListOption(
                            icon: Icons.settings_outlined,
                            title: "Settings",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => SettingsScreen(
                                      themeColor: _themeColor,
                                      role: 'inspector')),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await Supabase.instance.client.auth.signOut();
                          if (context.mounted) {
                            Navigator.of(context, rootNavigator: true)
                                .pushNamedAndRemoveUntil(
                                    '/login', (route) => false);
                          }
                        },
                        icon: Icon(Icons.logout, color: Colors.red[400]),
                        label: Text(
                          "Log Out",
                          style: TextStyle(
                            color: Colors.red[400],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red.shade100),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          backgroundColor: Colors.red.shade50.withOpacity(0.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        "AgriYukt Inspector v1.0.0",
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 40),
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
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 10,
              ),
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
              _name.isNotEmpty ? _name[0].toUpperCase() : "I",
              style: TextStyle(
                color: _themeColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
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
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified, color: Colors.blue, size: 16),
            ),
          ),
      ],
    );
  }

  Widget _buildWalletCard() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width - 32,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left side with icon and text
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _bgOffWhite,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.account_balance_wallet_rounded,
                        color: _themeColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Earnings",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "₹${_walletBalance.toStringAsFixed(2)}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey[900],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Withdraw button
            InkWell(
              onTap: () {
                // ✅ FIXED: Correct parameters
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WalletScreen(
                      themeColor: _themeColor,
                    ),
                  ),
                ).then((_) => _fetchWalletBalance());
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _themeColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _themeColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Text(
                  "Withdraw",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
=======
    bool isVerified = _verificationStatus == 'Verified';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header Section (Orange for Inspector)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFE65100), // Inspector Orange Theme
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.admin_panel_settings,
                              size: 40, color: Color(0xFFE65100)),
                        ),
                        // Verified Badge on Avatar
                        if (isVerified)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.check_circle,
                                  color: Colors.blue, size: 20),
                            ),
                          )
                      ],
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(_name,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ),
                              if (isVerified)
                                const Padding(
                                  padding: EdgeInsets.only(left: 6),
                                  child: Icon(Icons.verified,
                                      color: Colors.white, size: 18),
                                )
                            ],
                          ),
                          Text("$_role | $_email",
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: isVerified
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(
                              isVerified ? "✅ ID Verified" : "⚠️ ID Pending",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 2. Menu Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // ✅ NEW: Verification / Digital ID Option
                  _profileOption(
                      icon: Icons.verified_user,
                      title: "My Digital ID",
                      subtitle: "Aadhar Verification Status",
                      isHighlighted: !isVerified, // Highlight if not verified
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const VerificationScreen()));
                        _fetchProfile(); // Refresh status on return
                      }),

                  _profileOption(
                      icon: Icons.edit,
                      title: "Edit Profile",
                      subtitle: "Personal & Region Details",
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const EditProfileScreen()));
                        _fetchProfile();
                      }),

                  _profileOption(
                      icon: Icons.map,
                      title: "Assigned Areas",
                      subtitle: "View your jurisdiction",
                      onTap: () {
                        // Navigate to Map
                      }),

                  _profileOption(
                      icon: Icons.history,
                      title: "Audit Logs",
                      subtitle: "View your past verifications",
                      onTap: () {
                        // Navigate to Audit
                      }),

                  _profileOption(
                      icon: Icons.settings,
                      title: "Settings",
                      subtitle: "App preferences",
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
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
              ),
            ),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _modernGridItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
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
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modernListOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.grey[800], size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      trailing: Icon(Icons.chevron_right, size: 20, color: Colors.grey[400]),
    );
  }

  String _greetingMessage() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }
=======
  Widget _profileOption(
      {required IconData icon,
      required String title,
      required String subtitle,
      bool isHighlighted = false,
      required VoidCallback onTap}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: isHighlighted ? Colors.orange : Colors.grey.shade200)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.orange[50], borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: Colors.deepOrange),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: isHighlighted
            ? const Icon(Icons.warning, color: Colors.orange, size: 20)
            : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
}
