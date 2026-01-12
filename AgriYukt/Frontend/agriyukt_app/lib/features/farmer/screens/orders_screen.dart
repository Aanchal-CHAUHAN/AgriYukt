import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:agriyukt_app/features/farmer/screens/farmer_order_detail_screen.dart';

// ✅ CLASS NAME MATCHES LAYOUT
class FarmerOrdersScreen extends StatefulWidget {
  const FarmerOrdersScreen({super.key});

  @override
  State<FarmerOrdersScreen> createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends State<FarmerOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _supabase = Supabase.instance.client;

  bool _isLoading = true;
  List<Map<String, dynamic>> _allOrders = [];

  @override
  void initState() {
    super.initState();
    // 3 Tabs: Pending, Active, History
    _tabController = TabController(length: 3, vsync: this);
    _fetchOrders();
  }

  // ✅ CRITICAL FIX: Joins 'profiles' for Buyer Name and 'crops' for Image
  Future<void> _fetchOrders() async {
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);

      final myId = _supabase.auth.currentUser!.id;

      // 🔍 DEBUG: Fetching Orders with Foreign Keys
      final response = await _supabase
          .from('orders')
          .select(
              '*, buyer:profiles!buyer_id(first_name, last_name, city), crop:crops!crop_id(image_url, crop_name)')
          .eq('farmer_id', myId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _allOrders = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error fetching orders: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Incoming Orders",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchOrders)
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2E7D32),
          indicatorColor: const Color(0xFF2E7D32),
          tabs: const [
            Tab(text: "Pending"),
            Tab(text: "Active"),
            Tab(text: "History"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _OrderList(
                    orders: _allOrders,
                    statusFilter: const ['Ordered', 'Pending'],
                    onRefresh: _fetchOrders),
                _OrderList(
                    orders: _allOrders,
                    statusFilter: const ['Accepted', 'Packed', 'Shipped'],
                    onRefresh: _fetchOrders),
                _OrderList(
                    orders: _allOrders,
                    statusFilter: const [
                      'Delivered',
                      'Completed',
                      'Rejected',
                      'Cancelled'
                    ],
                    onRefresh: _fetchOrders),
              ],
            ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  final List<String> statusFilter;
  final VoidCallback onRefresh;

  const _OrderList(
      {required this.orders,
      required this.statusFilter,
      required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    // Filter logic
    final filtered = orders
        .where((o) => statusFilter.contains(o['tracking_status'] ?? 'Ordered'))
        .toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text("No orders in this tab",
                style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _FarmerOrderCard(order: filtered[index], onTap: onRefresh);
        },
      ),
    );
  }
}

class _FarmerOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onTap;

  const _FarmerOrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Safe Data Extraction
    final status = order['tracking_status'] ?? 'Ordered';
    final dateStr = order['created_at'] ?? order['order_date'];
    final date = dateStr != null
        ? DateFormat('dd MMM').format(DateTime.parse(dateStr).toLocal())
        : "";

    // Joined Data (Handle Nulls)
    final buyer = order['buyer'] ?? {};
    final buyerName =
        "${buyer['first_name'] ?? 'Buyer'} ${buyer['last_name'] ?? ''}".trim();
    final crop = order['crop'] ?? {};
    final cropName = order['crop_name'] ?? crop['crop_name'] ?? 'Crop';
    final imageUrl = crop['image_url'];

    return InkWell(
      onTap: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    FarmerOrderDetailScreen(orderId: order['id'].toString())));
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // Image
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                image: (imageUrl != null)
                    ? DecorationImage(
                        image: NetworkImage(imageUrl), fit: BoxFit.cover)
                    : null,
              ),
              child: imageUrl == null
                  ? const Icon(Icons.grass, color: Colors.green)
                  : null,
            ),
            const SizedBox(width: 15),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cropName,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("Buyer: $buyerName",
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 4),
                  _StatusChip(status: status),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    switch (status) {
      case 'Ordered':
      case 'Pending':
        color = Colors.orange;
        break;
      case 'Accepted':
        color = Colors.blue;
        break;
      case 'Packed':
        color = Colors.purple;
        break;
      case 'Shipped':
        color = Colors.indigo;
        break;
      case 'Delivered':
      case 'Completed':
        color = Colors.green;
        break;
      case 'Rejected':
        color = Colors.red;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4)),
      child: Text(status.toUpperCase(),
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
