import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ✅ CORRECT IMPORT PATH: Points to lib/core/services/cart_service.dart
import 'package:agriyukt_app/core/services/cart_service.dart';

class BuyerCartScreen extends StatefulWidget {
  const BuyerCartScreen({super.key});

  @override
  State<BuyerCartScreen> createState() => _BuyerCartScreenState();
}

class _BuyerCartScreenState extends State<BuyerCartScreen> {
  bool _isLoading = false;

  Future<void> _placeOrder() async {
    final cart = CartService(); // Access the singleton
    if (cart.items.isEmpty) return;

    setState(() => _isLoading = true);
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    try {
      if (user == null) throw "User not logged in";

      // 🔒 SECURITY CHECK: Check Verification Status
      final verificationCheck = await client
          .from('profiles')
          .select('verification_status')
          .eq('id', user.id)
          .single();

      final String status =
          verificationCheck['verification_status'] ?? 'Not Uploaded';

      if (status != 'Verified') {
        if (mounted) {
          // Show Alert Dialog
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Action Restricted"),
              content: Text(status == 'Pending'
                  ? "Your verification is Pending. Please wait for Admin approval."
                  : "You must verify your identity (Aadhar Card) in the Profile tab to place orders."),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("OK")),
              ],
            ),
          );
        }
        throw "Account not verified"; // Stop execution
      }

      // 1. Fetch Buyer Name (Required by 'orders' table schema)
      final profile = await client
          .from('profiles')
          .select('first_name, last_name')
          .eq('id', user.id)
          .single();

      final String buyerName =
          "${profile['first_name']} ${profile['last_name']}".trim();

      // 2. Insert each item into 'orders' table
      for (var item in cart.items) {
        await client.from('orders').insert({
          'buyer_id': user.id,
          'farmer_id': item['farmer_id'], // ✅ Correct Farmer ID from Cart
          'crop_name': item['name'], // ✅ Correct Column
          'quantity_kg': item['quantity_kg'], // ✅ Correct Column
          'price_offered':
              item['total_price'], // ✅ Correct Column (Total Price)
          'buyer_name':
              buyerName.isEmpty ? 'Buyer' : buyerName, // ✅ Required Column
          'status': 'Pending',
          'order_date': DateTime.now().toIso8601String(),
        });
      }

      // 3. Success Logic
      setState(() {
        cart.clearCart(); // Empty the local cart
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("Order Placed Successfully! Track it in 'My Orders'."),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Close cart and return to dashboard
      }
    } catch (e) {
      if (mounted && e.toString() != "Account not verified") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Order Failed: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartService(); // Access the singleton

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bucket"),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: "Clear Cart",
              onPressed: () {
                setState(() => cart.clearCart());
              },
            )
        ],
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text("Your bucket is empty",
                      style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                ],
              ),
            )
          : Column(
              children: [
                // Cart List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[100],
                            ),
                            child: item['image_url'] != null &&
                                    item['image_url'].isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(item['image_url'],
                                        fit: BoxFit.cover))
                                : const Icon(Icons.agriculture,
                                    color: Colors.green),
                          ),
                          title: Text(item['name'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              "${item['quantity_kg']} units x ₹${item['price_per_unit']}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("₹${item['total_price'].toStringAsFixed(0)}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.green)),
                              IconButton(
                                icon: const Icon(Icons.remove_circle,
                                    color: Colors.redAccent),
                                onPressed: () {
                                  setState(() => cart.removeFromCart(index));
                                },
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Total & Checkout Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, -5))
                  ]),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Grand Total:",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500)),
                          Text("₹${cart.grandTotal.toStringAsFixed(0)}",
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _placeOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text("CONFIRM ORDER",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
