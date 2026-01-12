import 'package:flutter/material.dart';
<<<<<<< HEAD

class InspectorOrdersTab extends StatelessWidget {
  const InspectorOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("My Orders"),
        automaticallyImplyLeading:
            false, // Hide back button (managed by Layout)
        backgroundColor: const Color(0xFFE65100), // Inspector Orange
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text("No orders assigned yet",
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
=======
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // Add url_launcher to pubspec.yaml

class InspectorOrdersTab extends StatefulWidget {
  const InspectorOrdersTab({super.key});

  @override
  State<InspectorOrdersTab> createState() => _InspectorOrdersTabState();
}

class _InspectorOrdersTabState extends State<InspectorOrdersTab> {
  final _client = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final inspectorId = _client.auth.currentUser!.id;

      // 1. Get IDs of farmers managed by this inspector
      final farmersResponse = await _client
          .from('profiles')
          .select('id')
          .eq('inspector_id', inspectorId);

      final List<dynamic> farmerIds =
          farmersResponse.map((e) => e['id']).toList();

      if (farmerIds.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      // 2. Fetch orders for these farmers
      final ordersResponse = await _client
          .from('orders')
          .select(
              '*, buyer:buyer_id(first_name, last_name, phone), farmer:farmer_id(first_name, last_name)')
          .inFilter('farmer_id', farmerIds)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _orders = List<Map<String, dynamic>>.from(ordersResponse);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String orderId, String newStatus) async {
    await _client
        .from('orders')
        .update({'status': newStatus}).eq('id', orderId);
    _fetchOrders(); // Refresh list
  }

  void _callBuyer(String? phone) async {
    if (phone == null) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Center(
          child: CircularProgressIndicator(color: Colors.orange));
    if (_orders.isEmpty)
      return const Center(child: Text("No orders found for your farmers."));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
          title: const Text("Manage Orders"), backgroundColor: Colors.orange),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          final buyer = order['buyer'] ?? {};
          final farmer = order['farmer'] ?? {};
          final status = order['status'] ?? 'Pending';

          return Card(
            margin: const EdgeInsets.only(bottom: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Crop Name & Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(order['crop_name'] ?? 'Crop',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      _statusChip(status),
                    ],
                  ),
                  const Divider(),

                  // Details
                  Text(
                      "For Farmer: ${farmer['first_name']} ${farmer['last_name']}"),
                  const SizedBox(height: 5),
                  Text("Buyer: ${buyer['first_name']} ${buyer['last_name']}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      "Quantity: ${order['quantity']} • Price: ₹${order['total_price']}"),

                  const SizedBox(height: 15),

                  // Action Buttons
                  Row(
                    children: [
                      // Call Button
                      IconButton(
                        onPressed: () => _callBuyer(buyer['phone']),
                        icon: const Icon(Icons.phone, color: Colors.green),
                        tooltip: "Call Buyer",
                      ),
                      const Spacer(),

                      // Accept / Reject Buttons (Only show if Pending)
                      if (status == 'Pending') ...[
                        OutlinedButton(
                          onPressed: () =>
                              _updateStatus(order['id'], 'Rejected'),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red),
                          child: const Text("Reject"),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () =>
                              _updateStatus(order['id'], 'Accepted'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          child: const Text("Accept",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ] else
                        Text("Order is $status",
                            style: const TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic)),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color = Colors.blue;
    if (status == 'Accepted') color = Colors.green;
    if (status == 'Rejected') color = Colors.red;
    return Chip(
      label: Text(status,
          style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
}
