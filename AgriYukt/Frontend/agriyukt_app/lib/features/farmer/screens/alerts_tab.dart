import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:agriyukt_app/features/farmer/screens/farmer_profile_tab.dart';

// ✅ CORRECT IMPORT
import 'package:agriyukt_app/features/farmer/screens/orders_screen.dart';

class AlertsTab extends StatefulWidget {
  const AlertsTab({super.key});

  @override
  State<AlertsTab> createState() => _AlertsTabState();
}

class _AlertsTabState extends State<AlertsTab> {
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _markAllAsRead();
  }

  Future<void> _markAllAsRead() async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  void _handleNotificationTap(Map<String, dynamic> notif) {
    final type = notif['type'] ?? 'system';

    if (type == 'order' || type == 'order_update') {
      // ✅ CORRECT CLASS CALL
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const FarmerOrdersScreen()));
    } else if (type == 'payment') {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const FarmerProfileTab()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _supabase.auth.currentUser!.id;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title:
            const Text("Notifications", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _supabase
            .from('notifications')
            .stream(primaryKey: ['id'])
            .eq('user_id', userId)
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final notifications = snapshot.data!;
          if (notifications.isEmpty)
            return const Center(child: Text("No notifications yet"));

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return Card(
                child: ListTile(
                  onTap: () => _handleNotificationTap(notif),
                  leading: const Icon(Icons.notifications, color: Colors.green),
                  title: Text(notif['title']),
                  subtitle: Text(notif['body']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
