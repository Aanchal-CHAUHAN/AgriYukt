import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:agriyukt_app/features/common/screens/chat_screen.dart';
import 'package:agriyukt_app/features/common/services/payment_service.dart';

class BuyerOrderDetailScreen extends StatefulWidget {
  final String orderId;
  const BuyerOrderDetailScreen({super.key, required this.orderId});

  @override
  State<BuyerOrderDetailScreen> createState() => _BuyerOrderDetailScreenState();
}

class _BuyerOrderDetailScreenState extends State<BuyerOrderDetailScreen> {
  final _supabase = Supabase.instance.client;
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = true;
  Map<String, dynamic>? _order;
  bool _isFarmerInfoMissing = false;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  Future<void> _fetchOrderDetails() async {
    try {
      final data = await _supabase
          .from('orders')
          .select(
              '*, farmer:profiles!farmer_id(first_name, last_name, phone, city, rating)')
          .eq('id', widget.orderId)
          .single();

      if (mounted) {
        setState(() {
          _order = data;
          _isLoading = false;
          _isFarmerInfoMissing = false;
        });
      }
    } catch (e) {
      try {
        final simpleData = await _supabase
            .from('orders')
            .select()
            .eq('id', widget.orderId)
            .single();
        if (mounted) {
          setState(() {
            _order = simpleData;
            _isLoading = false;
            _isFarmerInfoMissing = true;
          });
        }
      } catch (e2) {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickSchedule() async {
    final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(const Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 30)));
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
        context: context, initialTime: const TimeOfDay(hour: 10, minute: 0));
    if (time == null) return;
    final fullDateTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);

    await _supabase
        .from('orders')
        .update({'scheduled_pickup_time': fullDateTime.toIso8601String()}).eq(
            'id', widget.orderId);
    _fetchOrderDetails();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("✅ Schedule Updated"), backgroundColor: Colors.green));
    }
  }

  // ✅ UPDATED: Connects to the Smart Payment Service
  void _triggerPayment() {
    if (_order == null) return;

    // Safely calculate amount
    final quantity = (_order!['quantity_kg'] ?? 0).toDouble();
    final price = (_order!['price_offered'] ?? 0).toDouble();
    final totalAmount = quantity * price;

    if (totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("❌ Error: Total amount is zero."),
          backgroundColor: Colors.red));
      return;
    }

    _paymentService.processPayment(
      context: context,
      orderId: widget.orderId,
      farmerId: _order!['farmer_id'],
      amount: totalAmount,
      onResult: (success) {
        if (success) {
          _fetchOrderDetails();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_order == null) {
      return const Scaffold(body: Center(child: Text("Order not found")));
    }

    final farmer = (_isFarmerInfoMissing ? {} : _order!['farmer']) ?? {};
    final farmerName = _isFarmerInfoMissing
        ? "Farmer"
        : "${farmer['first_name'] ?? 'Unknown'} ${farmer['last_name'] ?? ''}"
            .trim();

    final status = _order!['tracking_status'] ?? 'Pending';
    final paymentStatus = _order!['payment_status'] ?? 'Pending';
    final isPaid = paymentStatus == 'paid_confirmed';
    final quantity = (_order!['quantity_kg'] ?? 0).toDouble();
    final price = (_order!['price_offered'] ?? 0).toDouble();
    final totalAmount = quantity * price;

    // STATE LOGIC
    final isPending = status == 'Pending' || status == 'Ordered';
    final isRejected = status == 'Rejected';
    final isActive = !isPending && !isRejected;

    final scheduleTime = _order!['scheduled_pickup_time'];
    final scheduleText = scheduleTime != null
        ? DateFormat('dd MMM, hh:mm a')
            .format(DateTime.parse(scheduleTime).toLocal())
        : "Tap to Schedule";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("Order Details"), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. ORDER SUMMARY
            _buildSummaryCard(totalAmount),
            const SizedBox(height: 20),

            // 2. WARNING BANNER (If Pending/Rejected)
            if (isPending)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200)),
                child: const Row(children: [
                  Icon(Icons.hourglass_empty, color: Colors.orange),
                  SizedBox(width: 10),
                  Expanded(
                      child: Text(
                          "Waiting for Farmer Acceptance.\nFeatures are locked.",
                          style: TextStyle(
                              color: Colors.deepOrange, fontSize: 12)))
                ]),
              ),

            if (isRejected)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                color: Colors.red[50],
                child: const Text("❌ Order Rejected by Farmer",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
              ),

            // 3. SCHEDULE (Locked if Pending)
            Opacity(
              opacity: isActive ? 1.0 : 0.5,
              child: IgnorePointer(
                ignoring: !isActive,
                child: InkWell(
                  onTap: _pickSchedule,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200)),
                    child: Row(children: [
                      const Icon(Icons.calendar_month,
                          color: Colors.blue, size: 30),
                      const SizedBox(width: 15),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            const Text("Scheduled Pickup",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue)),
                            Text(scheduleText,
                                style: TextStyle(
                                    color: Colors.blue[900], fontSize: 16)),
                          ])),
                      if (isActive)
                        const Icon(Icons.edit, color: Colors.blue, size: 18)
                    ]),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 4. TRACKING (If Active)
            if (isActive)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Shipment Status",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      _buildStatusTracker(status),
                    ]),
              ),
            const SizedBox(height: 20),

            // 5. FARMER INFO & CHAT (Locked if Pending)
            Opacity(
              opacity: isActive ? 1.0 : 0.5,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                      child: Text(farmerName.isNotEmpty ? farmerName[0] : 'F')),
                  title: Text(farmerName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Farmer"),
                  // 🚀 CHAT BUTTON (Updated with Safety)
                  trailing: IconButton(
                    icon: const Icon(Icons.chat_bubble_outline,
                        color: Colors.blue),
                    onPressed: !isActive
                        ? null
                        : () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                          targetUserId: _order!['farmer_id'],
                                          targetName: farmerName,
                                          orderId: widget.orderId,
                                          // ✅ SAFETY FIX: Default to 'Crop' if null
                                          cropName:
                                              _order!['crop_name'] ?? 'Crop',
                                          orderStatus: status,
                                        )));
                          },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 6. PAY BUTTON (Locked if Pending or Paid)
            if (!isPaid && !isRejected)
              Opacity(
                opacity: isActive ? 1.0 : 0.5,
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: !isActive ? null : _triggerPayment,
                    icon: const Icon(Icons.payment, color: Colors.white),
                    label: const Text("PAY NOW",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700]),
                  ),
                ),
              )
            else if (isPaid)
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12)),
                  child: const Center(
                      child: Text("✅ Order Paid - Money Secured",
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold))))
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.grass, color: Colors.green)),
        const SizedBox(width: 15),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_order!['crop_name'] ?? 'Crop',
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text("${_order!['quantity_kg']} Kg",
              style: TextStyle(color: Colors.grey[600])),
        ]),
        const Spacer(),
        Text("₹${total.toStringAsFixed(0)}",
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green)),
      ]),
    );
  }

  Widget _buildStatusTracker(String current) {
    const steps = ['Accepted', 'Packed', 'Shipped', 'Delivered'];
    int idx = steps.indexOf(current);
    if (idx == -1) idx = 0;
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
            steps.length,
            (i) => Icon(
                i <= idx ? Icons.check_circle : Icons.radio_button_unchecked,
                color: i <= idx ? Colors.green : Colors.grey)));
  }
}
