import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
<<<<<<< HEAD
// Ensure your package name matches exactly (agriyukt_app)
import 'package:agriyukt_app/features/inspector/screens/inspector_add_crop_tab.dart';
import 'package:agriyukt_app/features/inspector/screens/add_farmer_screen.dart';
import 'package:agriyukt_app/features/inspector/screens/edit_farmer_screen.dart';
import 'package:agriyukt_app/features/inspector/screens/inspector_farmer_crops_screen.dart';
=======
import 'package:agriyukt_app/features/inspector/screens/inspector_add_crop_tab.dart';
import 'package:agriyukt_app/features/inspector/screens/add_farmer_screen.dart';
import 'package:agriyukt_app/features/inspector/screens/inspector_farmer_crops_screen.dart'; // ✅ Correctly imported now
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416

class InspectorFarmersTab extends StatefulWidget {
  const InspectorFarmersTab({super.key});

  @override
  State<InspectorFarmersTab> createState() => _InspectorFarmersTabState();
}

class _InspectorFarmersTabState extends State<InspectorFarmersTab> {
  final _client = Supabase.instance.client;
  String _searchQuery = "";
  final _searchCtrl = TextEditingController();

<<<<<<< HEAD
  // State for fetching
  List<Map<String, dynamic>> _farmers = [];
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _fetchFarmers();
  }

  // --- 1. ROBUST FETCH FUNCTION ---
  Future<void> _fetchFarmers() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final user = _client.auth.currentUser;
      if (user == null) throw "User not logged in";

      final response = await _client
          .from('profiles')
          .select()
          .eq('role', 'Farmer')
          // .eq('onboarded_by', user.id) // Uncomment later for strict filtering
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _farmers = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMsg = e.toString();
        });
      }
    }
  }

  // --- DELETE LOGIC ---
  Future<void> _deleteFarmer(String farmerId, String farmerName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Farmer?"),
        content: Text(
            "Delete $farmerName? This cannot be undone and will remove all their orders/crops."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child:
                  const Text("CANCEL", style: TextStyle(color: Colors.grey))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("DELETE",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _client.from('profiles').delete().eq('id', farmerId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Deleted successfully"),
            backgroundColor: Colors.red));
        _fetchFarmers(); // Refresh list after delete
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter locally based on Search
    final filteredFarmers = _farmers.where((f) {
      final name =
          "${f['first_name'] ?? ''} ${f['last_name'] ?? ''}".toLowerCase();
      return name.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Wait for result, then refresh
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddFarmerScreen()));
          _fetchFarmers();
=======
  @override
  Widget build(BuildContext context) {
    final user = _client.auth.currentUser;
    if (user == null) return const SizedBox();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      // ✅ FAB: Inspector creates the account manually
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFarmerScreen()),
          );
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
        },
        backgroundColor: const Color(0xFFE65100),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text("Add Farmer", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            alignment: Alignment.centerLeft,
<<<<<<< HEAD
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Managed Farmers",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE65100))),
                IconButton(
                    onPressed: _fetchFarmers,
                    icon: const Icon(Icons.refresh, color: Colors.orange))
              ],
            ),
          ),

=======
            child: const Text("Managed Farmers",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE65100))),
          ),

          // Search Bar
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search Name...",
                prefixIcon: const Icon(Icons.search, color: Colors.orange),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 10),

<<<<<<< HEAD
          // LIST VIEW
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.orange))
                : _errorMsg != null
                    ? Center(
                        child: Text("Error: $_errorMsg",
                            style: const TextStyle(color: Colors.red)))
                    : filteredFarmers.isEmpty
                        ? const Center(
                            child: Text("No farmers found.",
                                style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                            itemCount: filteredFarmers.length,
                            itemBuilder: (ctx, i) =>
                                _buildFarmerCard(filteredFarmers[i]),
                          ),
=======
          // THE LIST
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _client.from('profiles').stream(primaryKey: ['id']),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.orange));
                }

                // Filter Logic: STRICTLY show only farmers managed by THIS Inspector
                final farmers = snapshot.data!.where((f) {
                  // 1. Must be a Farmer
                  final isFarmer =
                      f['role'] == 'Farmer' || f['role'] == 'farmer';

                  // 2. Must be managed by ME (Inspector ID matches my ID)
                  final isManagedByMe = f['inspector_id'] == user.id;

                  // Search
                  final name = (f['first_name'] ?? "").toString().toLowerCase();
                  final matchesSearch = name.contains(_searchQuery);

                  return isFarmer && isManagedByMe && matchesSearch;
                }).toList();

                if (farmers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.folder_shared_outlined,
                            size: 60, color: Colors.grey),
                        const SizedBox(height: 10),
                        const Text("No managed farmers yet.",
                            style: TextStyle(color: Colors.grey, fontSize: 16)),
                        const SizedBox(height: 5),
                        const Text("Tap 'Add Farmer' to create a profile.",
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 16, bottom: 80),
                  itemCount: farmers.length,
                  itemBuilder: (ctx, i) => _buildFarmerCard(farmers[i]),
                );
              },
            ),
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerCard(Map<String, dynamic> farmer) {
<<<<<<< HEAD
    final name =
        "${farmer['first_name'] ?? 'Unknown'} ${farmer['last_name'] ?? ''}"
            .trim();

=======
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: const Icon(Icons.verified_user, color: Colors.green),
        ),
<<<<<<< HEAD
        title: Text(name.isEmpty ? "Unknown" : name,
=======
        title: Text(
            "${farmer['first_name'] ?? 'Unknown'} ${farmer['last_name'] ?? ''}",
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
<<<<<<< HEAD
            Text("Phone: ${farmer['phone'] ?? 'N/A'}"),
            if (farmer['village'] != null)
              Text("Village: ${farmer['village']}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'add') {
=======
            Text("Phone: ${farmer['phone'] ?? 'No Number'}"),
            Text("Region: ${farmer['region_id'] ?? 'Assigned'}",
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        // ✅ Popup Menu for Add vs View
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'add') {
              // Action: Add New Crop
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          InspectorAddCropTab(preSelectedFarmer: farmer)));
            } else if (value == 'view') {
<<<<<<< HEAD
              // ✅ NAVIGATE TO VIEW CROPS SCREEN
=======
              // Action: View/Edit Existing Crops
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => InspectorFarmerCropsScreen(
<<<<<<< HEAD
                          farmerId: farmer['id'], farmerName: name)));
            } else if (value == 'edit') {
              // ✅ NAVIGATE TO EDIT SCREEN
              bool? updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditFarmerScreen(farmer: farmer)));
              if (updated == true) _fetchFarmers();
            } else if (value == 'delete') {
              _deleteFarmer(farmer['id'], name);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
                value: 'add',
                child: Row(children: [
                  Icon(Icons.add_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Add Crop')
                ])),
            const PopupMenuItem(
                value: 'view',
                child: Row(children: [
                  Icon(Icons.visibility, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('View Crops')
                ])),
            const PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  Icon(Icons.edit, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Edit Details')
                ])),
            const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete')
                ])),
          ],
=======
                          farmerId: farmer['id'], 
                          farmerName: "${farmer['first_name']} ${farmer['last_name']}"
                      )));
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'add',
              child: Row(children: [
                Icon(Icons.add_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Add New Crop')
              ]),
            ),
            const PopupMenuItem<String>(
              value: 'view',
              child: Row(children: [
                Icon(Icons.edit_document, color: Colors.blue),
                SizedBox(width: 8),
                Text('View/Edit Crops')
              ]),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: const Color(0xFFE65100),
                borderRadius: BorderRadius.circular(8)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("ACTIONS",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Icon(Icons.arrow_drop_down, color: Colors.white),
              ],
            ),
          ),
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
