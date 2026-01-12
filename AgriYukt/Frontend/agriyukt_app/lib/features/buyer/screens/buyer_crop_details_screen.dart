import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BuyerCropDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> cropData; // Passed from Marketplace
  const BuyerCropDetailsScreen({super.key, required this.cropData});

  @override
  State<BuyerCropDetailsScreen> createState() => _BuyerCropDetailsScreenState();
}

class _BuyerCropDetailsScreenState extends State<BuyerCropDetailsScreen> {
  bool isOrdering = false;
  final _currentUser = Supabase.instance.client.auth.currentUser;

  Future<void> _placeOrder() async {
    if (_currentUser == null) return;

    setState(() => isOrdering = true);

    try {
      // Create the order row
      await Supabase.instance.client.from('orders').insert({
        'buyer_id': _currentUser!.id,
        'farmer_id':
            widget.cropData['farmer_id'], // Assumes cropData has farmer_id
        'listing_id': widget.cropData['id'],
        'crop_name': widget.cropData['name'],
        'price_per_unit': widget.cropData['price'],
        'quantity': 1, // Defaulting to 1 for this example
        'total_price': widget.cropData['price'], // calc: price * qty
        'status': 'pending', // Initial status
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Order Placed Successfully!")));
        Navigator.pop(context); // Go back to marketplace
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Failed: $e")));
    } finally {
      if (mounted) setState(() => isOrdering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.cropData['name'] ?? "Details")),
      body: Column(
        children: [
          // Crop Image
          Expanded(
            child: widget.cropData['image_url'] != null
                ? Image.network(widget.cropData['image_url'],
                    fit: BoxFit.cover, width: double.infinity)
                : Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 100)),
          ),

          // Details Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("Price: ₹${widget.cropData['price']}/kg",
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green)),
                const SizedBox(height: 10),
                Text(widget.cropData['description'] ??
                    "No description provided."),
                const SizedBox(height: 20),

                // Buy Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: isOrdering ? null : _placeOrder,
                  child: isOrdering
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Buy Now",
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
