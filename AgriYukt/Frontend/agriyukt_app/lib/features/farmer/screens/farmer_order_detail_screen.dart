import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:agriyukt_app/features/common/screens/chat_screen.dart';

class FarmerOrderDetailScreen extends StatefulWidget {
  final String orderId;
  const FarmerOrderDetailScreen({super.key, required this.orderId});

  @override
  State<FarmerOrderDetailScreen> createState() =>
      _FarmerOrderDetailScreenState();
}

class _FarmerOrderDetailScreenState extends State<FarmerOrderDetailScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  Map<String, dynamic>? _order;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    try {
      // ✅ Fetch Order + Buyer + Crop
      final data = await _supabase
          .from('orders')
          .select('*, buyer:profiles!buyer_id(*), crop:crops!crop_id(*)')
          .eq('id', widget.orderId)
          .single();

      if (mounted)
        setState(() {
          _order = data;
          _isLoading = false;
        });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isLoading = true);
    Map<String, dynamic> updateData = {'tracking_status': newStatus};

    // Auto-complete logic
    if (newStatus == 'Delivered') {
      updateData['status'] = 'Completed';
      updateData['payment_status'] = 'paid_released';
    }

    await _supabase.from('orders').update(updateData).eq('id', widget.orderId);
    await _fetchOrderDetails();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Order Marked as $newStatus"),
          backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_order == null)
      return const Scaffold(body: Center(child: Text("Order not found")));

    final buyer = _order!['buyer'] ?? {};
    final crop = _order!['crop'] ?? {};
    final status = _order!['tracking_status'] ?? 'Pending';
    final isHistory =
        ['Delivered', 'Completed', 'Rejected', 'Cancelled'].contains(status);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("Order Details"), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. SUMMARY CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  if (crop['image_url'] != null)
                    ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(crop['image_url'],
                            height: 150, fit: BoxFit.cover)),
                  const SizedBox(height: 10),
                  Text(crop['crop_name'] ?? 'Crop',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(
                      "Qty: ${_order!['quantity_kg']} Kg • Price: ₹${_order!['price_offered']}/kg",
                      style: TextStyle(color: Colors.grey[700])),
                  const SizedBox(height: 15),
                  _buildStatusBadge(status),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. BUYER & CHAT
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading:
                    CircleAvatar(child: Text(buyer['first_name']?[0] ?? "B")),
                title: Text("${buyer['first_name']} ${buyer['last_name']}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Buyer • ${buyer['city'] ?? ''}"),
                trailing: IconButton(
                  icon: const Icon(Icons.chat, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ChatScreen(
                                  targetUserId: _order!['buyer_id'],
                                  targetName: "${buyer['first_name']}",
                                  orderId: widget.orderId,
                                  cropName: crop['crop_name'] ?? 'Crop',
                                  orderStatus: status,
                                )));
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 3. ACTIONS
            if (!isHistory) ...[
              if (status == 'Pending' || status == 'Ordered')
                Row(
                  children: [
                    Expanded(
                        child: _btn("Reject", Colors.red,
                            () => _updateStatus('Rejected'))),
                    const SizedBox(width: 15),
                    Expanded(
                        child: _btn("Accept Order", Colors.green,
                            () => _updateStatus('Accepted'))),
                  ],
                ),
              if (status == 'Accepted')
                _btn("Mark as Packed", Colors.blue,
                    () => _updateStatus('Packed')),
              if (status == 'Packed')
                _btn("Mark as Shipped", Colors.orange,
                    () => _updateStatus('Shipped')),
              if (status == 'Shipped')
                _btn("Mark as Delivered", Colors.green,
                    () => _updateStatus('Delivered')),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: status == 'Rejected'
                        ? Colors.red[50]
                        : Colors.green[50],
                    borderRadius: BorderRadius.circular(8)),
                child: Text(
                    status == 'Rejected'
                        ? "❌ Order Rejected"
                        : "✅ Order Completed",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: status == 'Rejected' ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold)),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'Rejected' ? Colors.red : Colors.green;
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(5)),
        child: Text(status.toUpperCase(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold)));
  }

  Widget _btn(String label, Color color, VoidCallback onTap) {
    return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(backgroundColor: color),
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))));
  }
}
