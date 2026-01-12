import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agriyukt_app/core/services/location_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // --- 1. CONTROLLERS ---
  final _fnameCtrl = TextEditingController();
  final _mnameCtrl = TextEditingController();
  final _lnameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  // Role & Specifics
  String _role = "farmer";

  // Farmer Fields
  String? _farmerType;
  String? _landSize;

  // Buyer Fields
  String? _buyerType;
  String? _buyerCategory;
  String? _gstNumber;
  String? _bizRegistration;

  // Inspector Fields
  String? _inspectorCategory;
  String? _empIdCtrl;

  // --- 2. LOCATION STATE ---
  String? _selectedStateId;
  String? _selectedDistrictId;
  String? _selectedTalukaId;
  String? _selectedVillageId;
  final _pinCtrl = TextEditingController();
  final _subVillageCtrl = TextEditingController();
  bool _showSubVillage = false;

  List<LocalizedItem> _stateList = [];
  List<LocalizedItem> _districtList = [];
  List<LocalizedItem> _talukaList = [];
  List<LocalizedItem> _villageList = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStates();
    _loadUserProfile();
  }

  void _loadStates() {
    setState(() {
      _stateList = LocationService.getStates();
    });
  }

  // --- 3. FETCH & PRE-FILL DATA ---
  Future<void> _loadUserProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final data = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (data != null && mounted) {
          setState(() {
            // 1. Personal Data
            _fnameCtrl.text = data['first_name'] ?? "";
            _mnameCtrl.text = data['middle_name'] ?? "";
            _lnameCtrl.text = data['last_name'] ?? "";
            _phoneCtrl.text = data['phone'] ?? "";
            _emailCtrl.text = user.email ?? "";

            // 2. READ FROM META_DATA (This bypasses the column error)
            final meta = data['meta_data'] ?? {};

            // 3. Role Data
            _role = data['role'] ?? "farmer";

            if (_role == 'farmer') {
              _farmerType = meta['farmer_type'] ?? data['farmer_type'];
              _landSize = meta['land_size'] ?? data['land_size'];
            } else if (_role == 'buyer') {
              _buyerType = meta['buyer_type'] ?? data['buyer_type'];
              _buyerCategory = meta['buyer_category'] ?? data['buyer_category'];
              _bizRegistration = meta['business_registration'] ??
                  data['business_registration'];
              _gstNumber = meta['gst_number'] ?? data['gst_number'];
            } else if (_role == 'inspector') {
              _inspectorCategory =
                  meta['inspector_category'] ?? data['inspector_category'];
              _empIdCtrl = meta['employee_id'] ?? data['employee_id'];
            }

            // 4. Location Data
            _selectedStateId = data['state'];
            _pinCtrl.text = data['pincode'] ?? "";
            _subVillageCtrl.text = data['sub_village'] ?? "";
            if (_subVillageCtrl.text.isNotEmpty) _showSubVillage = true;

            // 5. Chain Load Location Dropdowns
            if (_selectedStateId != null) {
              _districtList = LocationService.getDistricts(_selectedStateId!);
              _selectedDistrictId = data['district'];

              if (_selectedDistrictId != null) {
                _talukaList = LocationService.getTalukas(
                    _selectedStateId!, _selectedDistrictId!);
                _selectedTalukaId = data['taluka'];

                if (_selectedTalukaId != null) {
                  _villageList = LocationService.getVillages(_selectedStateId!,
                      _selectedDistrictId!, _selectedTalukaId!);
                  _selectedVillageId = data['village'];
                }
              }
            }
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 4. SAVE CHANGES (THE FIX) ---
  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // ✅ STEP 1: Put the problematic fields INSIDE this map
        final Map<String, dynamic> metaDataToSave = {};

        if (_role == 'farmer') {
          metaDataToSave['farmer_type'] = _farmerType;
          metaDataToSave['land_size'] = _landSize;
        } else if (_role == 'buyer') {
          metaDataToSave['buyer_type'] = _buyerType;
          metaDataToSave['buyer_category'] = _buyerCategory;
          metaDataToSave['business_registration'] = _bizRegistration;
          metaDataToSave['gst_number'] = _gstNumber;
        } else if (_role == 'inspector') {
          metaDataToSave['inspector_category'] = _inspectorCategory;
          metaDataToSave['employee_id'] = _empIdCtrl;
        }

        // ✅ STEP 2: Only send safe columns to the top level
        // We do NOT send 'farmer_type' here, avoiding the crash.
        final Map<String, dynamic> updates = {
          'first_name': _fnameCtrl.text,
          'middle_name': _mnameCtrl.text,
          'last_name': _lnameCtrl.text,
          'phone': _phoneCtrl.text,
          'state': _selectedStateId,
          'district': _selectedDistrictId,
          'taluka': _selectedTalukaId,
          'village': _selectedVillageId,
          'pincode': _pinCtrl.text,
          'sub_village': _subVillageCtrl.text,
          'meta_data': metaDataToSave, // <--- Saving to JSON column instead
          'updated_at': DateTime.now().toIso8601String(),
        };

        await Supabase.instance.client
            .from('profiles')
            .update(updates)
            .eq('id', user.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Profile Saved Successfully!"),
              backgroundColor: Colors.green));
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Edit Profile"),
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader("Personal Details", Icons.person),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _txt("First Name", _fnameCtrl)),
                      const SizedBox(width: 10),
                      Expanded(child: _txt("Middle Name", _mnameCtrl)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _txt("Last Name", _lnameCtrl),
                  const SizedBox(height: 15),
                  _txt("Phone Number", _phoneCtrl, type: TextInputType.phone),
                  const SizedBox(height: 15),
                  _txt("Email", _emailCtrl, isReadOnly: true),

                  const SizedBox(height: 30),

                  if (_role == 'farmer') _buildFarmerFields(),
                  if (_role == 'buyer') _buildBuyerFields(),
                  if (_role == 'inspector') _buildInspectorFields(),

                  const SizedBox(height: 30),

                  _sectionHeader("Location Details", Icons.location_on),
                  const SizedBox(height: 15),

                  // State -> District
                  _locDD("State", _selectedStateId, _stateList, (val) {
                    setState(() {
                      _selectedStateId = val;
                      _districtList = LocationService.getDistricts(val!);
                      _selectedDistrictId = null;
                      _talukaList = [];
                      _villageList = [];
                    });
                  }),
                  const SizedBox(height: 15),

                  // District -> Taluka
                  _locDD("District", _selectedDistrictId, _districtList, (val) {
                    setState(() {
                      _selectedDistrictId = val;
                      _talukaList =
                          LocationService.getTalukas(_selectedStateId!, val!);
                      _selectedTalukaId = null;
                      _villageList = [];
                    });
                  }),
                  const SizedBox(height: 15),

                  // Taluka -> Village
                  _locDD(
                      LocationService.isUrban(_selectedDistrictId ?? "")
                          ? "Ward"
                          : "Taluka",
                      _selectedTalukaId,
                      _talukaList, (val) {
                    setState(() {
                      _selectedTalukaId = val;
                      _villageList = LocationService.getVillages(
                          _selectedStateId!, _selectedDistrictId!, val!);
                      _selectedVillageId = null;
                    });
                  }),
                  const SizedBox(height: 15),

                  // Village
                  _locDD(
                      LocationService.isUrban(_selectedDistrictId ?? "")
                          ? "Locality"
                          : "Village",
                      _selectedVillageId,
                      _villageList,
                      (val) => setState(() => _selectedVillageId = val)),
                  const SizedBox(height: 15),

                  _txt("Pincode", _pinCtrl, type: TextInputType.number),

                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _showSubVillage = !_showSubVillage),
                    child: Row(children: [
                      Icon(
                          _showSubVillage
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: Colors.green),
                      const SizedBox(width: 8),
                      const Text("Add Sub-Village / Landmark",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                  ),
                  if (_showSubVillage) ...[
                    const SizedBox(height: 10),
                    _txt("Sub-Village Name", _subVillageCtrl),
                  ],

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32)),
                      child: const Text("SAVE CHANGES",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  // --- Widgets ---
  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.green, size: 22),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20))),
      ],
    );
  }

  Widget _txt(String label, TextEditingController c,
      {TextInputType type = TextInputType.text, bool isReadOnly = false}) {
    return TextField(
      controller: c,
      keyboardType: type,
      readOnly: isReadOnly,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isReadOnly ? Colors.grey[200] : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      ),
    );
  }

  Widget _simpleDD(
      String label, String? val, List<String> items, Function(String?) ch) {
    return DropdownButtonFormField<String>(
      value: val,
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: ch,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      ),
    );
  }

  Widget _locDD(String label, String? val, List<LocalizedItem> items,
      Function(String?) ch) {
    return DropdownButtonFormField<String>(
      value: val,
      // Using getName(false) to match your service's English request
      items: items
          .map((e) =>
              DropdownMenuItem(value: e.id, child: Text(e.getName(false))))
          .toList(),
      onChanged: ch,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      ),
    );
  }

  Widget _buildFarmerFields() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader("Farmer Details", Icons.agriculture),
      const SizedBox(height: 15),
      _simpleDD(
          "Farmer Type",
          _farmerType,
          ['Individual', 'Family', 'FPO', 'SHG'],
          (v) => setState(() => _farmerType = v)),
      const SizedBox(height: 15),
      _simpleDD(
          "Land Size",
          _landSize,
          ['< 1 Acre', '1-2 Acres', '2-5 Acres', '> 5 Acres'],
          (v) => setState(() => _landSize = v)),
    ]);
  }

  Widget _buildBuyerFields() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader("Buyer Details", Icons.shopping_bag),
      const SizedBox(height: 15),
      _simpleDD(
          "Buyer Type",
          _buyerType,
          ['Retailer', 'Wholesaler', 'Trader', 'Exporter'],
          (v) => setState(() => _buyerType = v)),
      const SizedBox(height: 15),
      _simpleDD(
          "Category",
          _buyerCategory,
          ['Small Business', 'Medium Business', 'Enterprise'],
          (v) => setState(() => _buyerCategory = v)),
      const SizedBox(height: 15),
      _simpleDD(
          "Registration",
          _bizRegistration,
          ['Not Registered', 'GST Registered', 'MSME'],
          (v) => setState(() => _bizRegistration = v)),
    ]);
  }

  Widget _buildInspectorFields() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader("Inspector Details", Icons.verified),
      const SizedBox(height: 15),
      _simpleDD(
          "Category",
          _inspectorCategory,
          ['Government', 'Private', 'NGO'],
          (v) => setState(() => _inspectorCategory = v)),
    ]);
  }
}
