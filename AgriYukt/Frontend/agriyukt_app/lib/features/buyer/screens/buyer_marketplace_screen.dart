import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ✅ Import the Details Screen
import 'package:agriyukt_app/features/buyer/screens/buyer_crop_details_screen.dart';

class BuyerMarketplaceScreen extends StatefulWidget {
  const BuyerMarketplaceScreen({super.key});

  @override
  State<BuyerMarketplaceScreen> createState() => _BuyerMarketplaceScreenState();
}

class _BuyerMarketplaceScreenState extends State<BuyerMarketplaceScreen> {
  final _client = Supabase.instance.client;

  String _searchQuery = "";
  String _selectedCategory = "All";
  bool _isLoading = true;

  List<Map<String, dynamic>> _allCrops = [];
  List<Map<String, dynamic>> _filteredCrops = [];

  final List<String> _categories = [
    "All",
    "Vegetables",
    "Fruits",
    "Grains",
    "Pulses",
    "Flowers",
    "Oils"
  ];

  @override
  void initState() {
    super.initState();
    _fetchMarketData();
  }

  // ✅ NEW: Fetch Data with Farmer Details
  Future<void> _fetchMarketData() async {
    try {
      final response = await _client
          .from('crops')
          .select('''
              *,
              profiles:farmer_id (first_name, last_name, district) 
          ''')
          .eq('status', 'Active') // Only show Active items
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _allCrops = List<Map<String, dynamic>>.from(response);
          _runFilter(); // Initial Filter
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Market Data Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ✅ NEW: Client-side Filtering
  void _runFilter() {
    setState(() {
      _filteredCrops = _allCrops.where((crop) {
        // ✅ Robust Null Safety
        final name =
            (crop['crop_name'] ?? crop['name'] ?? '').toString().toLowerCase();
        final category = (crop['category'] ?? '').toString();

        final matchesSearch = name.contains(_searchQuery);
        final matchesCategory =
            _selectedCategory == "All" || category == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // --- HEADER: Search & Filter ---
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (val) {
                    _searchQuery = val.toLowerCase();
                    _runFilter();
                  },
                  decoration: InputDecoration(
                    hintText: "Search wheat, tomato...",
                    prefixIcon: const Icon(Icons.search, color: Colors.blue),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 10),
                // Category Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      bool isSel = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSel,
                          onSelected: (val) {
                            setState(() => _selectedCategory = cat);
                            _runFilter();
                          },
                          selectedColor: Colors.blue,
                          labelStyle: TextStyle(
                              color: isSel ? Colors.white : Colors.black),
                          backgroundColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide.none),
                        ),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          ),

          // --- MARKET GRID ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCrops.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ✅ FIXED: Changed Icon to store_mall_directory_outlined
                            Icon(Icons.store_mall_directory_outlined,
                                size: 60, color: Colors.grey[400]),
                            const SizedBox(height: 10),
                            Text("No crops found.",
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredCrops.length,
                        itemBuilder: (ctx, i) =>
                            _buildMarketCard(_filteredCrops[i]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketCard(Map<String, dynamic> crop) {
    // ✅ Safe Data Extraction
    final String name = crop['crop_name'] ?? crop['name'] ?? "Unknown Crop";

    // Handle price being int or double or string
    final String price =
        crop['price']?.toString() ?? crop['price_per_qty']?.toString() ?? "0";
    final String quantity = crop['quantity']?.toString() ?? "N/A";

    // ✅ Handle Farmer Profile Data Safely
    final farmerData = crop['profiles'];
    String farmerName = "Farmer";
    if (farmerData != null) {
      farmerName =
          "${farmerData['first_name'] ?? ''} ${farmerData['last_name'] ?? ''}"
              .trim();
      if (farmerName.isEmpty) farmerName = "AgriYukt User";
    }

    // ✅ Image Logic (Supabase Path vs URL)
    ImageProvider imgProvider;
    String? imgUrl = crop['image_url'];
    if (imgUrl != null && imgUrl.isNotEmpty) {
      if (imgUrl.startsWith('http')) {
        imgProvider = NetworkImage(imgUrl);
      } else {
        // Construct Public URL from Bucket
        final fullUrl =
            _client.storage.from('crop_images').getPublicUrl(imgUrl);
        imgProvider = NetworkImage(fullUrl);
      }
    } else {
      imgProvider = const AssetImage('assets/images/placeholder_crop.png');
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => BuyerCropDetailsScreen(crop: crop)),
          );
        },
        child: Column(
          children: [
            // IMAGE SECTION
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: Image(
                      image: imgProvider,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: Colors.grey[200],
                        child:
                            const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                if (crop['crop_type'] == 'Organic')
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8)),
                      child: const Text("Organic",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  )
              ],
            ),

            // INFO SECTION
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                      Text("₹$price",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(farmerName,
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 13)),
                      const SizedBox(width: 10),
                      const Icon(Icons.scale, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(quantity,
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  BuyerCropDetailsScreen(crop: crop)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: const Text("VIEW & BUY",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
