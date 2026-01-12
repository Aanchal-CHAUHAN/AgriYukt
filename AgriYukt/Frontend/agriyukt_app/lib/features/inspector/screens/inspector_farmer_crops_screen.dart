import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
<<<<<<< HEAD

// Adjust imports based on your exact file paths
import 'package:agriyukt_app/features/inspector/screens/inspector_add_crop_tab.dart';
import 'package:agriyukt_app/features/farmer/screens/view_crop_screen.dart';
import 'package:agriyukt_app/features/inspector/screens/manage_crops/inspector_crop_card.dart';
=======
import 'package:agriyukt_app/features/inspector/screens/inspector_add_crop_tab.dart'; // ✅ Import Add/Edit Screen
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416

class InspectorFarmerCropsScreen extends StatefulWidget {
  final String farmerId;
  final String farmerName;

  const InspectorFarmerCropsScreen({
    super.key,
    required this.farmerId,
    required this.farmerName,
  });

  @override
  State<InspectorFarmerCropsScreen> createState() =>
      _InspectorFarmerCropsScreenState();
}

class _InspectorFarmerCropsScreenState
    extends State<InspectorFarmerCropsScreen> {
  final _client = Supabase.instance.client;
<<<<<<< HEAD

  bool _showActive = true;
=======
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
  bool _isLoading = true;
  List<Map<String, dynamic>> _crops = [];

  @override
  void initState() {
    super.initState();
    _fetchCrops();
  }

  Future<void> _fetchCrops() async {
<<<<<<< HEAD
    if (!mounted) return;
    setState(() => _isLoading = true);

=======
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
    try {
      final response = await _client
          .from('crops')
          .select()
          .eq('farmer_id', widget.farmerId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _crops = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
<<<<<<< HEAD
      debugPrint("Error: $e");
      if (mounted) {
=======
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
        setState(() => _isLoading = false);
      }
    }
  }

<<<<<<< HEAD
  void _navigateToEditScreen(Map<String, dynamic>? crop) async {
    final dummyFarmerMap = {
      'id': widget.farmerId,
      'first_name': widget.farmerName,
=======
  // ✅ NEW: Navigate to the Full Edit Screen instead of a Dialog
  void _navigateToEditScreen(Map<String, dynamic> crop) async {
    // We construct a temporary farmer object because the Add Screen expects it
    final dummyFarmerMap = {
      'id': widget.farmerId,
      'first_name': widget.farmerName.split(' ')[0], // Approximate
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
      'last_name': '',
    };

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InspectorAddCropTab(
<<<<<<< HEAD
            preSelectedFarmer: dummyFarmerMap,
            cropToEdit: crop // Pass null for new, map for edit
            ),
      ),
    );

=======
          preSelectedFarmer: dummyFarmerMap,
          cropToEdit: crop, // ✅ Passing the crop triggers "Edit Mode"
        ),
      ),
    );

    // If update happened (returned true), refresh list
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
    if (result == true) {
      _fetchCrops();
    }
  }

  Future<void> _deleteCrop(String cropId) async {
<<<<<<< HEAD
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Crop?"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("CANCEL")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("DELETE", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _client.from('crops').delete().eq('id', cropId);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Crop Deleted")));
        _fetchCrops();
=======
    try {
      await _client.from('crops').delete().eq('id', cropId);
      _fetchCrops();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Crop Deleted")));
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
<<<<<<< HEAD
            .showSnackBar(SnackBar(content: Text("Error: $e")));
=======
            .showSnackBar(SnackBar(content: Text("Delete Failed: $e")));
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: Colors.grey[100],
=======
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
<<<<<<< HEAD
            const Text("Manage Crops",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("${widget.farmerName}'s Inventory",
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.white70)),
          ],
        ),
        backgroundColor: const Color(0xFF387C2B),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // --- 1. SEARCH BAR ---
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
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search your crops...",
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF387C2B)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // --- 2. CUSTOM TOGGLE BUTTONS ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _buildTabButton("Active Crops", true)),
                const SizedBox(width: 12),
                Expanded(child: _buildTabButton("Inactive/Sold", false)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // --- 3. CROP LIST ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildCropList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToEditScreen(null),
        backgroundColor: const Color(0xFF387C2B),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Crop", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildTabButton(String text, bool isActiveTab) {
    bool isSelected = _showActive == isActiveTab;
    return GestureDetector(
      onTap: () {
        setState(() {
          _showActive = isActiveTab;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF387C2B) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ]
              : null,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCropList() {
    final displayList = _crops.where((c) {
      final status = c['status']?.toString().toLowerCase() ?? 'active';
      return _showActive ? status == 'active' : status != 'active';
    }).toList();

    if (displayList.isEmpty) {
      return Center(
          child: Text(_showActive ? "No active crops" : "No inactive crops"));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        return _buildCropCard(displayList[index]);
      },
    );
  }

  Widget _buildCropCard(Map<String, dynamic> crop) {
    final name = crop['crop_name'] ?? crop['name'] ?? 'Unnamed';
    final price = crop['price'] ?? 0;
    final qty = crop['quantity'] ?? 0;
    final imgUrl = crop['image_url'];
    final harvestDate = crop['harvest_date'] ?? '--';

    // ✅ FIXED: Read from 'available_from' instead of 'available_date'
    final availableDate = crop['available_from'] ?? '--';

    final isCropActive =
        (crop['status']?.toString().toLowerCase() ?? 'active') == 'active';

    return InspectorCropCard(
      cropName: name,
      price: "₹$price",
      quantity: "$qty",
      harvestDate: harvestDate,
      availableDate: availableDate,
      imageUrl: imgUrl ?? 'https://via.placeholder.com/150',
      isActive: isCropActive,
      onViewTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ViewCropScreen(crop: crop)),
        );
      },
      onEditTap: () => _navigateToEditScreen(crop),
      onDeleteTap: () => _deleteCrop(crop['id']),
=======
            const Text("Manage Crops", style: TextStyle(fontSize: 16)),
            Text(widget.farmerName,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _crops.isEmpty
              ? const Center(child: Text("No crops added for this farmer."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _crops.length,
                  itemBuilder: (context, index) {
                    final crop = _crops[index];

                    // Safe accessors
                    final cropName = crop['name'] ?? 'Unnamed Crop';
                    final cropPrice = crop['price'] ?? 0;
                    final cropQty = crop['quantity'] ?? 'N/A';
                    final imageUrl = crop['image_url'];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: imageUrl != null
                            ? Image.network(imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image,
                                        color: Colors.grey))
                            : const Icon(Icons.grass,
                                size: 40, color: Colors.green),
                        title: Text(cropName.toString(),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Price: ₹$cropPrice | Qty: $cropQty"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _navigateToEditScreen(
                                  crop), // ✅ Opens Full Screen
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCrop(crop['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
    );
  }
}
