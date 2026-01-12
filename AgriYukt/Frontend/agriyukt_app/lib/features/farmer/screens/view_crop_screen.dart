import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Required for image path handling

class ViewCropScreen extends StatelessWidget {
  final Map<String, dynamic> crop;

  const ViewCropScreen({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    // --- 1. SMART DATA PARSING ---
    // Handles both new and old schema keys to ensure real values show up.

    final String name = crop['crop_name'] ?? crop['name'] ?? 'Unknown Crop';
    final String variety = crop['variety'] ?? 'Generic';
    final String status = crop['status'] ?? 'Active';
    final String category = crop['category'] ?? 'General';
    final String grade = crop['grade'] ?? 'Standard';

    // Price: Check 'price' first, fall back to 'price_per_qty'
    final String price =
        crop['price']?.toString() ?? crop['price_per_qty']?.toString() ?? '0';

    // Quantity: Check 'quantity' (text), fall back to combined available+unit
    final String quantity = crop['quantity']?.toString() ??
        "${crop['quantity_available'] ?? 0} ${crop['quantity_unit'] ?? ''}";

    // Description: Check 'description' first, fall back to 'health_notes'
    final String description = crop['description'] ??
        crop['health_notes'] ??
        "No specific notes provided for this crop.";

    // Image Logic: Handle full URLs vs Storage Paths
    ImageProvider? imageProvider;
    if (crop['image_url'] != null) {
      final String url = crop['image_url'];
      if (url.startsWith('http')) {
        imageProvider = NetworkImage(url);
      } else {
        // ✅ Load from 'crop_images' bucket if it's a path
        imageProvider = NetworkImage(Supabase.instance.client.storage
            .from('crop_images')
            .getPublicUrl(url));
      }
    }

    return Scaffold(
      appBar: AppBar(
          title: const Text("Crop Details"),
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- IMAGE SECTION ---
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey[200],
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10)
                ],
                image: imageProvider != null
                    ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                    : null,
              ),
              child: imageProvider == null
                  ? const Center(
                      child: Icon(Icons.image, size: 80, color: Colors.grey))
                  : null,
            ),
            const SizedBox(height: 20),

            // --- TITLE & STATUS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    "$name ($variety)",
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _getStatusColor(status))),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                )
              ],
            ),
            const SizedBox(height: 5),
            Text("$category • $grade",
                style: TextStyle(color: Colors.grey[600], fontSize: 16)),

            const Divider(height: 40, thickness: 1),

            // --- DETAILS GRID ---
            _detailRow(Icons.currency_rupee, "Price", "₹$price"),
            _detailRow(Icons.scale, "Quantity", quantity),
            _detailRow(
                Icons.eco, "Farming Mode", crop['crop_type'] ?? 'Organic'),
            _detailRow(Icons.event_available, "Harvest Date",
                _formatDate(crop['harvest_date'])),
            _detailRow(Icons.local_shipping, "Available From",
                _formatDate(crop['available_from'])),

            const SizedBox(height: 30),

            // --- DESCRIPTION ---
            const Text("Farmer's Notes / Description",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade100)),
              child: Text(
                description,
                style: const TextStyle(
                    fontSize: 16, height: 1.5, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 20, color: Colors.green),
          ),
          const SizedBox(width: 12),
          Text("$label:",
              style: TextStyle(color: Colors.grey[700], fontSize: 16)),
          const Spacer(),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "Not Specified";
    try {
      final d = DateTime.parse(dateStr);
      return "${d.day}/${d.month}/${d.year}";
    } catch (e) {
      return "N/A";
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'sold':
        return Colors.red;
      case 'inactive':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}
