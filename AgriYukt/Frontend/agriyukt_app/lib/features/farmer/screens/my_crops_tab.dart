import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_crop_tab.dart';
import 'view_crop_screen.dart';

class MyCropsTab extends StatefulWidget {
  const MyCropsTab({super.key});

  @override
  State<MyCropsTab> createState() => _MyCropsTabState();
}

class _MyCropsTabState extends State<MyCropsTab> {
  final _client = Supabase.instance.client;
  bool _showActive = true;
  String _searchQuery = "";
  final _searchCtrl = TextEditingController();
  int _refreshTrigger = 0;

  // --- DELETE LOGIC ---
  Future<void> _deleteCrop(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Listing?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("CANCEL")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("DELETE",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _client.from('crops').delete().eq('id', id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Crop deleted"), backgroundColor: Colors.red));
          setState(() => _refreshTrigger++);
        }
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _client.auth.currentUser;

    if (user == null) {
      return const Center(child: Text("Please log in"));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
              context, MaterialPageRoute(builder: (_) => const AddCropTab()));
          setState(() => _refreshTrigger++);
        },
        label: const Text("Add Crop",
            style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Text("My Crops Inventory",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20))),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search your crops...",
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = "");
                        })
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(child: _tabBtn("Active Crops", true)),
                const SizedBox(width: 10),
                Expanded(child: _tabBtn("Inactive/Sold", false)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              key: ValueKey(_refreshTrigger),
              stream: _client
                  .from('crops')
                  .stream(primaryKey: ['id'])
                  .eq('farmer_id', user.id)
                  .order('created_at', ascending: false),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.green));

                final filtered = snapshot.data!.where((c) {
                  final status = c['status'] ?? 'Active';
                  final isActiveGroup =
                      ['Active', 'Verified', 'Growing'].contains(status);
                  final matchesTab =
                      _showActive ? isActiveGroup : !isActiveGroup;
                  final name = c['crop_name'] ?? '';
                  final matchesSearch =
                      name.toString().toLowerCase().contains(_searchQuery);
                  return matchesTab && matchesSearch;
                }).toList();

                if (filtered.isEmpty)
                  return Center(
                      child: Text("No crops found.",
                          style: TextStyle(color: Colors.grey[600])));

                return ListView.builder(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 80),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) => _buildLargeCard(filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabBtn(String label, bool target) {
    bool isSel = _showActive == target;
    return GestureDetector(
      onTap: () => setState(() => _showActive = target),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFF2E7D32) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isSel ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(label,
            style: TextStyle(
                color: isSel ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildLargeCard(Map<String, dynamic> crop) {
    ImageProvider imgProvider;
    String? imgUrl = crop['image_url'];
    if (imgUrl != null && imgUrl.isNotEmpty) {
      if (imgUrl.startsWith('http')) {
        imgProvider = NetworkImage(imgUrl);
      } else {
        imgProvider = NetworkImage(
            _client.storage.from('crop_images').getPublicUrl(imgUrl));
      }
    } else {
      imgProvider = const AssetImage('assets/images/placeholder_crop.png');
    }

    final String name = crop['crop_name'] ?? 'Unknown Crop';
    final String variety = crop['variety'] ?? 'Generic';
    final String status = crop['status']?.toUpperCase() ?? "ACTIVE";

    // ✅ FIX: Remove .0 from Quantity
    String qty = crop['quantity']?.toString() ??
        "${crop['quantity_available'] ?? 0} ${crop['quantity_unit'] ?? ''}";
    qty = qty.replaceAll(
        RegExp(r"([.]*0)(?!.*\d)"), ""); // Regex to remove trailing .0

    // ✅ FIX: Remove .0 from Price
    String priceVal =
        crop['price']?.toString() ?? crop['price_per_qty']?.toString() ?? '0';
    priceVal = priceVal.replaceAll(
        RegExp(r"([.]*0)(?!.*\d)"), ""); // Regex to remove trailing .0

    String unit = crop['quantity_unit'] ?? 'Unit';
    if (unit == 'Unit' && qty.contains(' ')) {
      unit = qty.split(' ').sublist(1).join(' ');
    }
    final String displayPrice = "₹$priceVal / $unit";

    final String harvestDate = _formatDate(crop['harvest_date']);
    final String availDate = _formatDate(crop['available_from']);

    Color statusColor = Colors.green;
    if (status == 'SOLD')
      statusColor = Colors.red;
    else if (status == 'INACTIVE')
      statusColor = Colors.grey;
    else if (status == 'VERIFIED') statusColor = Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- IMAGE HEADER with STATUS and DELETE Button ---
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    image:
                        DecorationImage(image: imgProvider, fit: BoxFit.cover),
                  ),
                ),
              ),

              // DELETE BUTTON (Top Left)
              Positioned(
                top: 10,
                left: 10,
                child: InkWell(
                  onTap: () => _deleteCrop(crop['id']),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4)
                        ]),
                    child: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 20),
                  ),
                ),
              ),

              // STATUS BADGE (Top Right)
              Positioned(
                  top: 15,
                  right: 15,
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4)
                          ]),
                      child: Text(status,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)))),
            ],
          ),

          // --- INFO SECTION ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text("$name - $variety",
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis)),
                    Text(displayPrice,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32))),
                  ],
                ),
                const SizedBox(height: 12),

                Row(children: [
                  const Icon(Icons.scale, size: 16, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(qty,
                      style: const TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 15),
                  const Icon(Icons.agriculture, size: 16, color: Colors.grey),
                  const SizedBox(width: 5),
                  Expanded(
                      child: Text("Harvest: $harvestDate",
                          style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis)),
                ]),

                const SizedBox(height: 8),

                Row(children: [
                  const Icon(Icons.event_available,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text("Available: $availDate",
                      style: const TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.w500)),
                ]),

                const SizedBox(height: 20),

                // --- ACTION BUTTONS (View & Edit Only) ---
                Row(
                  children: [
                    Expanded(
                        child: ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        ViewCropScreen(crop: crop))),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8))),
                            icon: const Icon(Icons.visibility,
                                color: Colors.white, size: 18),
                            label: const Text("View",
                                style: TextStyle(color: Colors.white)))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: OutlinedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          AddCropTab(cropToEdit: crop)));
                              setState(() => _refreshTrigger++);
                            },
                            style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.orange),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8))),
                            icon: const Icon(Icons.edit,
                                color: Colors.orange, size: 18),
                            label: const Text("Edit",
                                style: TextStyle(color: Colors.orange)))),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "N/A";
    try {
      final d = DateTime.parse(dateStr);
      return "${d.day}/${d.month}/${d.year}";
    } catch (e) {
      return "N/A";
    }
  }
}
