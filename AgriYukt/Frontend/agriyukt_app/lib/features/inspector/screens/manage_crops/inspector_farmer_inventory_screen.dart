import 'package:flutter/material.dart';
import 'inspector_crop_card.dart'; // Import the card widget below

class InspectorFarmerInventoryScreen extends StatefulWidget {
  final String farmerName; // Pass the farmer's name to display

  const InspectorFarmerInventoryScreen({Key? key, required this.farmerName})
      : super(key: key);

  @override
  State<InspectorFarmerInventoryScreen> createState() =>
      _InspectorFarmerInventoryScreenState();
}

class _InspectorFarmerInventoryScreenState
    extends State<InspectorFarmerInventoryScreen> {
  bool showActive = true; // State to toggle between Active and Inactive tabs

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF387C2B), // AgriYukt Green
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Manage Crops",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Text("${widget.farmerName}'s Inventory",
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // --- 1. Search Bar ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search your crops...",
                  prefixIcon: Icon(Icons.search, color: Colors.green),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // --- 2. Custom Toggle Tabs ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _buildTabButton("Active Crops", true)),
                const SizedBox(width: 10),
                Expanded(child: _buildTabButton("Inactive/Sold", false)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // --- 3. Crop List ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // Demo Data: InspectorCropCard
                InspectorCropCard(
                  cropName: "Cauliflower - white",
                  price: "₹10 / Unit",
                  quantity: "1000",
                  harvestDate: "3/1/2026",
                  availableDate: "4/1/2026",
                  imageUrl: "https://via.placeholder.com/150",
                  isActive: true,
                  onViewTap: () {
                    print("Inspector viewing details");
                  },
                  onEditTap: () {
                    print("Inspector editing crop");
                  },
                ),

                const SizedBox(height: 16),

                InspectorCropCard(
                  cropName: "Tomato - Red",
                  price: "₹25 / kg",
                  quantity: "500",
                  harvestDate: "2/28/2026",
                  availableDate: "3/5/2026",
                  imageUrl: "https://via.placeholder.com/150",
                  isActive: true,
                  onViewTap: () {},
                  onEditTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
      // --- 4. Floating Action Button (Optional for Inspector) ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Logic to add crop on behalf of farmer
        },
        backgroundColor: const Color(0xFF387C2B),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Crop", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // Helper for the Toggle Buttons
  Widget _buildTabButton(String text, bool isActiveTab) {
    bool isSelected = showActive == isActiveTab;
    return GestureDetector(
      onTap: () {
        setState(() {
          showActive = isActiveTab;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF387C2B) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
