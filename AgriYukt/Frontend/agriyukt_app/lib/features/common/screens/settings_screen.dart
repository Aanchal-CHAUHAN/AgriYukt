import 'package:flutter/material.dart';
import 'package:agriyukt_app/features/common/screens/change_password_screen.dart';
import 'package:agriyukt_app/features/common/screens/support_screens.dart';
import 'package:agriyukt_app/features/common/screens/legal_screens.dart';
// ✅ Import the Chatbot Screen
import 'package:agriyukt_app/features/common/screens/support_chat_screen.dart';

class SettingsScreen extends StatefulWidget {
  final Color themeColor;
  // ✅ Added 'role' to pass to the Chatbot (e.g., 'farmer', 'buyer', 'inspector')
  final String role;

  const SettingsScreen({
    super.key,
    required this.themeColor,
    this.role =
        'farmer', // Default to farmer if not passed, but better to pass it
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Notification Toggles
  bool _notifyCrops = true;
  bool _notifyOrders = true;
  bool _notifyInspector = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- 1. PREFERENCES ---
          _sectionHeader("Preferences"),
          _buildContainer([
            ListTile(
              leading: Icon(Icons.language, color: widget.themeColor),
              title: const Text("Language"),
              trailing:
                  const Text("English", style: TextStyle(color: Colors.grey)),
              onTap: () {
                // Future: Show Language Dialog
              },
            ),
            const Divider(height: 1),
            ExpansionTile(
              leading:
                  Icon(Icons.notifications_outlined, color: widget.themeColor),
              title: const Text("Notifications"),
              iconColor: widget.themeColor,
              children: [
                SwitchListTile(
                  activeColor: widget.themeColor,
                  title: const Text("Crop Alerts"),
                  value: _notifyCrops,
                  onChanged: (v) => setState(() => _notifyCrops = v),
                ),
                SwitchListTile(
                  activeColor: widget.themeColor,
                  title: const Text("Order Updates"),
                  value: _notifyOrders,
                  onChanged: (v) => setState(() => _notifyOrders = v),
                ),
                SwitchListTile(
                  activeColor: widget.themeColor,
                  title: const Text("Inspector Updates"),
                  value: _notifyInspector,
                  onChanged: (v) => setState(() => _notifyInspector = v),
                ),
              ],
            ),
          ]),

          const SizedBox(height: 24),

          // --- 2. SECURITY & PRIVACY ---
          _sectionHeader("Security & Privacy"),
          _buildContainer([
            ListTile(
              leading: const Icon(Icons.lock_outline, color: Colors.grey),
              title: const Text("Change Password"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ChangePasswordScreen(themeColor: widget.themeColor),
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading:
                  const Icon(Icons.privacy_tip_outlined, color: Colors.grey),
              title: const Text("Privacy Policy"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StaticContentScreen(
                    title: "Privacy Policy",
                    content: kPrivacyPolicy,
                    themeColor: widget.themeColor,
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading:
                  const Icon(Icons.description_outlined, color: Colors.grey),
              title: const Text("Terms & Conditions"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StaticContentScreen(
                    title: "Terms & Conditions",
                    content: kTermsConditions,
                    themeColor: widget.themeColor,
                  ),
                ),
              ),
            ),
          ]),

          const SizedBox(height: 24),

          // --- 3. SUPPORT ---
          _sectionHeader("Support"),
          _buildContainer([
            // ✅ Chatbot Enabled Here
            ListTile(
              leading:
                  Icon(Icons.chat_bubble_outline, color: widget.themeColor),
              title: const Text("Chatbot (AI Assistant)"),
              subtitle: const Text("Get instant help & FAQs",
                  style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to Chatbot with the specific role
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SupportChatScreen(role: widget.role),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading:
                  const Icon(Icons.headset_mic_outlined, color: Colors.grey),
              title: const Text("Contact Support"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ContactSupportScreen(themeColor: widget.themeColor),
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading:
                  const Icon(Icons.bug_report_outlined, color: Colors.grey),
              title: const Text("Report an Issue"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ReportIssueScreen(themeColor: widget.themeColor),
                ),
              ),
            ),
          ]),

          const SizedBox(height: 24),

          // --- 4. ABOUT ---
          _sectionHeader("About"),
          _buildContainer([
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.grey),
              title: const Text("About App"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StaticContentScreen(
                    title: "About AgriYukt",
                    content: kAboutApp,
                    themeColor: widget.themeColor,
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            const ListTile(
              leading: Icon(Icons.android, color: Colors.grey),
              title: Text("App Version"),
              trailing:
                  Text("1.0.0", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ]),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
            color: widget.themeColor,
            fontWeight: FontWeight.bold,
            fontSize: 14),
      ),
    );
  }

  Widget _buildContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)
        ],
      ),
      child: Column(children: children),
    );
  }
}
