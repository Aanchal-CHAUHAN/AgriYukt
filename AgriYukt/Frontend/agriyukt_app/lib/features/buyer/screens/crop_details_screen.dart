import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CropDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> crop;
  const CropDetailsScreen({super.key, required this.crop});

  @override
  State<CropDetailsScreen> createState() => _CropDetailsScreenState();
}

class _CropDetailsScreenState extends State<CropDetailsScreen> {
  bool _isOrdering = false;

  Future<void> _addToBucket() async {
    // Simulate adding to a "Bucket"
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Added to My Bucket! Check the menu.")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.crop;

    // ✅ FIX: Map Old Keys to New Database Keys
    final String name = c['name'] ?? "Unknown Crop";
    final String price = (c['price'] ?? 0).toString();
    // Quantity is now a single text string (e.g., "50 Quintal")
    final String quantity = c['quantity'] ?? "N/A";
    final String description = c['description'] ?? "No description provided.";
    final String imageUrl = c['image_url'] ?? "";
    final String category = c['category'] ?? "Crop";
    final String cropType = c['crop_type'] ?? "Standard";
    final String grade = c['grade'] ?? "N/A";

    // Date formatting helper
    String harvestDate = "N/A";
    if (c['harvest_date'] != null) {
      try {
        harvestDate = c['harvest_date'].substring(0, 10);
      } catch (_) {}
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large Image
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[200],
              child: imageUrl.isNotEmpty
                  ? Image.network(imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.broken_image,
                          size: 100,
                          color: Colors.grey))
                  : const Icon(Icons.agriculture,
                      size: 100, color: Colors.grey),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(name,
                            style: const TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold)),
                      ),
                      Text("₹$price",
                          style: const TextStyle(
                              fontSize: 22,
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Chips
                  Row(
                    children: [
                      _chip(category, Colors.blue),
                      const SizedBox(width: 10),
                      _chip(cropType, Colors.green),
                      const SizedBox(width: 10),
                      _chip("Grade: $grade", Colors.orange),
                    ],
                  ),
                  const Divider(height: 30),

                  // Description
                  const Text("About this Crop",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                        fontSize: 16, color: Colors.black87, height: 1.5),
                  ),

                  const SizedBox(height: 20),

                  // Quantity
                  Row(
                    children: [
                      const Icon(Icons.inventory_2, color: Colors.grey),
                      const SizedBox(width: 10),
                      Text("Available Quantity: $quantity",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Harvest Date
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey),
                      const SizedBox(width: 10),
                      Text("Harvested: $harvestDate",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
                offset: const Offset(0, -5))
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _addToBucket,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[800],
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.shopping_cart, color: Colors.white),
          label: const Text("ADD TO BUCKET",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
