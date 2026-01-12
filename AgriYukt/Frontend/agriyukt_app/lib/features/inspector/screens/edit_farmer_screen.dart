import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:agriyukt_app/core/services/location_service.dart'; // Ensure this path is correct

class EditFarmerScreen extends StatefulWidget {
  final Map<String, dynamic> farmer; // Data passed from the list

  const EditFarmerScreen({super.key, required this.farmer});

  @override
  State<EditFarmerScreen> createState() => _EditFarmerScreenState();
}

class _EditFarmerScreenState extends State<EditFarmerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  // Controllers
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addr1Ctrl;
  late TextEditingController _pinCtrl;

  // Dropdowns
  String? _farmerType;
  String? _landSizeCategory;
  String? _productionCapacity;

  // Location
  String? _selectedStateId;
  String? _selectedDistrictId;
  String? _selectedTalukaId;
  String? _selectedVillageId;

  // Lists
  List<LocalizedItem> _stateList = [];
  List<LocalizedItem> _districtList = [];
  List<LocalizedItem> _talukaList = [];
  List<LocalizedItem> _villageList = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final f = widget.farmer;

    // 1. Fill Text Fields
    _firstNameCtrl = TextEditingController(text: f['first_name']);
    _lastCtrl = TextEditingController(text: f['last_name']);
    _phoneCtrl = TextEditingController(text: f['phone']);
    _addr1Ctrl = TextEditingController(text: f['address_line_1']);
    _pinCtrl = TextEditingController(text: f['pincode']);

    // 2. Fill Dropdowns
    _farmerType = f['farmer_type'];
    _landSizeCategory = f['land_size'];
    _productionCapacity = f['production_capacity'];

    // 3. Fill Location (Basic logic - assumes IDs are stored)
    _selectedStateId = f['state'];
    _selectedDistrictId = f['district'];
    _selectedTalukaId = f['taluka'];
    _selectedVillageId = f['village'];

    // Load States initially
    _stateList = LocationService.getStates();

    // (Optional) If you want to pre-load districts based on saved state,
    // you would call LocationService.getDistricts(_selectedStateId) here.
  }

  Future<void> _updateFarmer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final updates = {
        'first_name': _firstNameCtrl.text.trim(),
        'last_name': _lastCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'farmer_type': _farmerType,
        'land_size': _landSizeCategory,
        'production_capacity': _productionCapacity,
        'address_line_1': _addr1Ctrl.text.trim(),
        'pincode': _pinCtrl.text.trim(),
        'state': _selectedStateId,
        'district': _selectedDistrictId,
        'taluka': _selectedTalukaId,
        'village': _selectedVillageId,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', widget.farmer['id']); // Update specifically THIS farmer

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("✅ Farmer Updated Successfully!"),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Return true to refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Update Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Edit Farmer Details"),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _input("First Name", _firstNameCtrl),
              const SizedBox(height: 10),
              _input("Last Name", _lastCtrl),
              const SizedBox(height: 10),
              _input("Phone", _phoneCtrl, type: TextInputType.phone),
              const SizedBox(height: 10),
              _input("Address", _addr1Ctrl),
              const SizedBox(height: 10),

              // Dropdowns
              DropdownButtonFormField<String>(
                value: _farmerType,
                decoration: _deco("Farmer Type"),
                items: ['Individual', 'Family', 'FPO', 'SHG']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _farmerType = v),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _landSizeCategory,
                decoration: _deco("Land Size"),
                items: ['< 1 Acre', '1-2 Acres', '2-5 Acres', '> 5 Acres']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _landSizeCategory = v),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateFarmer,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("SAVE CHANGES",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController ctrl,
      {TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      decoration: _deco(label),
      validator: (v) => v!.isEmpty ? "Required" : null,
    );
  }

  InputDecoration _deco(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }
}
