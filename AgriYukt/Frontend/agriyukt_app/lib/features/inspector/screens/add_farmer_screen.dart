<<<<<<< HEAD
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

=======
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
import 'package:agriyukt_app/core/services/location_service.dart';

class AddFarmerScreen extends StatefulWidget {
  const AddFarmerScreen({super.key});

  @override
  State<AddFarmerScreen> createState() => _AddFarmerScreenState();
}

class _AddFarmerScreenState extends State<AddFarmerScreen> {
  final _formKey = GlobalKey<FormState>();
<<<<<<< HEAD
  final _supabase = Supabase.instance.client;
=======
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416

  // --- 1. CONTROLLERS ---
  final _firstNameCtrl = TextEditingController();
  final _middleNameCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

<<<<<<< HEAD
=======
  // Address
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
  final _addr1Ctrl = TextEditingController();
  final _addr2Ctrl = TextEditingController();
  final _pinCtrl = TextEditingController();

<<<<<<< HEAD
  // --- 2. FARMING DETAILS ---
  String? _farmerType;
  String? _landSizeCategory;
=======
  // --- 2. FARMING DETAILS STATE ---
  String? _farmerType;
  String? _landSizeCategory;

  // ✅ NEW: Multi-Select Crop Categories
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
  final List<String> _cropCategoriesOptions = [
    'Fruits',
    'Vegetables',
    'Cereals & Millets',
    'Pulses',
    'Oilseeds',
    'Spices',
    'Commercial / Cash Crops'
  ];
<<<<<<< HEAD
  List<String> _selectedCropCategories = [];

=======
  List<String> _selectedCropCategories = []; // Stores selected values

  // ✅ NEW: Quantity Capacity
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
  String? _productionCapacity;
  final List<String> _quantityOptions = [
    'Less than 5 quintals',
    '5 – 10 quintals',
    '10 – 25 quintals',
    '25 – 50 quintals',
    'More than 50 quintals'
  ];

  // --- 3. LOCATION STATE ---
  String? _selectedStateId;
  String? _selectedDistrictId;
  String? _selectedTalukaId;
  String? _selectedVillageId;

  List<LocalizedItem> _stateList = [];
  List<LocalizedItem> _districtList = [];
  List<LocalizedItem> _talukaList = [];
  List<LocalizedItem> _villageList = [];

<<<<<<< HEAD
  // --- 4. ID VERIFICATION ---
  File? _frontImage;
  File? _backImage;
  String _frontMsg = "Tap to Scan Front";
  String _backMsg = "Tap to Scan Back";
  bool _isFrontValid = false;
  bool _isBackValid = false;
  String? _extractedAadharNumber;

=======
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  void _loadStates() {
    setState(() {
      _stateList = LocationService.getStates();
    });
  }

<<<<<<< HEAD
=======
  // --- 4. MULTI-SELECT DIALOG HELPER ---
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
  void _showCategoryMultiSelect() async {
    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return _MultiSelectDialog(
          items: _cropCategoriesOptions,
          initialSelected: _selectedCropCategories,
        );
      },
    );
<<<<<<< HEAD
    if (results != null) {
      setState(() => _selectedCropCategories = results);
    }
  }

  // ===========================================================================
  // IMAGE PICKER LOGIC (Camera + Gallery)
  // ===========================================================================
  Future<void> _pickImage(bool isFront) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFE65100)),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: Color(0xFFE65100)),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final img = await picker.pickImage(source: source);
    if (img == null) return;

    CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: img.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: isFront ? 'Crop Front Side' : 'Crop Back Side',
          toolbarColor: const Color(0xFFE65100),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.ratio16x9,
          lockAspectRatio: false,
        ),
      ],
    );

    if (cropped != null) {
      setState(() {
        if (isFront) {
          _frontImage = File(cropped.path);
          _frontMsg = "Processing...";
        } else {
          _backImage = File(cropped.path);
          _backMsg = "Processing...";
        }
      });
      await _processImage(File(cropped.path), isFront);
    }
  }

  Future<void> _processImage(File image, bool isFront) async {
    final input = InputImage.fromFile(image);
    final recognizer = TextRecognizer();

    try {
      final text = await recognizer.processImage(input);
      String fullText = text.text.toLowerCase().replaceAll("\n", " ");

      if (isFront) {
        bool hasKeywords = fullText.contains("government") ||
            fullText.contains("india") ||
            fullText.contains("dob");
        RegExp digitRegex = RegExp(r'[2-9]{1}[0-9]{3}\s[0-9]{4}\s[0-9]{4}');
        var match = digitRegex.firstMatch(text.text);

        if (match != null || hasKeywords) {
          setState(() {
            _isFrontValid = true;
            _frontMsg = "✅ Valid ID Detected";
            if (match != null) _extractedAadharNumber = match.group(0);
          });
        } else {
          setState(() {
            _isFrontValid = false;
            _frontMsg = "❌ Invalid / Unclear ID";
          });
        }
      } else {
        if (fullText.contains("address") || fullText.contains("pincode")) {
          setState(() {
            _isBackValid = true;
            _backMsg = "✅ Address Detected";
          });
        } else {
          setState(() {
            _isBackValid = false;
            _backMsg = "⚠️ Address Unclear";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("OCR Error: $e")));
      }
    } finally {
      recognizer.close();
    }
  }

  // ===========================================================================
  // SUBMIT LOGIC
  // ===========================================================================
=======

    if (results != null) {
      setState(() {
        _selectedCropCategories = results;
      });
    }
  }

  // --- 5. SUBMIT LOGIC ---
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
  Future<void> _registerFarmer() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedStateId == null || _selectedDistrictId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please select State and District"),
          backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    try {
<<<<<<< HEAD
      final inspector = _supabase.auth.currentUser;
      if (inspector == null) throw "Inspector not logged in";

      // 1. Check for Duplicate Phone Number
      final existingFarmer = await _supabase
          .from('profiles')
          .select('id')
          .eq('phone', _phoneCtrl.text.trim())
          .maybeSingle();

      if (existingFarmer != null) {
        throw "Farmer with this phone number already exists!";
      }

      // 2. Upload Images
      String time = DateTime.now().millisecondsSinceEpoch.toString();
      String frontPath = 'farmers_docs/${_phoneCtrl.text}_front_$time.jpg';
      String backPath = 'farmers_docs/${_phoneCtrl.text}_back_$time.jpg';

      String frontUrl = "";
      String backUrl = "";

      if (_frontImage != null) {
        await _supabase.storage
            .from('verification_docs')
            .upload(frontPath, _frontImage!);
        frontUrl =
            _supabase.storage.from('verification_docs').getPublicUrl(frontPath);
      }

      if (_backImage != null) {
        await _supabase.storage
            .from('verification_docs')
            .upload(backPath, _backImage!);
        backUrl =
            _supabase.storage.from('verification_docs').getPublicUrl(backPath);
      }

      // 3. Create Farmer Profile
      // ✅ FIX: Removed 'const' because Uuid() is not constant
      final newFarmerId = Uuid().v4();

      final Map<String, dynamic> farmerData = {
        'id': newFarmerId,
        'onboarded_by': inspector.id,
        'role': 'farmer',
        'is_verified': true,
        'verification_status': 'Verified',
        'wallet_balance': 0.0,
        'created_at': DateTime.now().toIso8601String(),
=======
      final client = Supabase.instance.client;
      final inspector = client.auth.currentUser;

      if (inspector == null) throw "Inspector not logged in";

      final newFarmerId = const Uuid().v4();

      final Map<String, dynamic> farmerData = {
        'id': newFarmerId,
        'inspector_id': inspector.id,
        'role': 'Farmer',
        'is_verified': true,
        'wallet_balance': 0.0,
        'created_at': DateTime.now().toIso8601String(),

        // Personal Info
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
        'first_name': _firstNameCtrl.text.trim(),
        'middle_name': _middleNameCtrl.text.trim(),
        'last_name': _lastCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
<<<<<<< HEAD
        'aadhar_number': _extractedAadharNumber ?? "MANUAL-VERIFIED",
        'aadhar_front_url': frontUrl,
        'aadhar_back_url': backUrl,
        'farmer_type': _farmerType,
        'land_size': _landSizeCategory,
        'crop_categories': _selectedCropCategories,
        'production_capacity': _productionCapacity,
=======

        // ✅ NEW: Farming Details
        'farmer_type': _farmerType,
        'land_size': _landSizeCategory,
        'crop_categories': _selectedCropCategories, // Saved as List<String>
        'production_capacity': _productionCapacity,

        // Address & Location
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
        'address_line_1': _addr1Ctrl.text.trim(),
        'address_line_2': _addr2Ctrl.text.trim(),
        'pincode': _pinCtrl.text.trim(),
        'state': _selectedStateId,
        'district': _selectedDistrictId,
        'taluka': _selectedTalukaId,
        'village': _selectedVillageId,
        'region_id': _selectedVillageId ?? _selectedDistrictId,
      };

<<<<<<< HEAD
      await _supabase.from('profiles').insert(farmerData);
=======
      await client.from('profiles').insert(farmerData);
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
<<<<<<< HEAD
              content: Text("✅ Farmer Account Created & Verified!"),
=======
              content: Text("Farmer Account Created Successfully!"),
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
              backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("Register New Farmer"),
            backgroundColor: const Color(0xFFE65100),
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionHeader("1. Personal Information"),
                  Row(
                    children: [
                      Expanded(child: _input("First Name *", _firstNameCtrl)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _input("Middle Name", _middleNameCtrl,
                              required: false)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _input("Last Name *", _lastCtrl)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _input("Mobile Number *", _phoneCtrl,
                              type: TextInputType.phone)),
                    ],
                  ),
                  const SizedBox(height: 25),
                  _sectionHeader("2. Identity Verification (Aadhar)"),
                  const Text("Scan document using camera or gallery.",
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                          child: _buildIdCard("Front Side", _frontImage,
                              _frontMsg, _isFrontValid, true)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _buildIdCard("Back Side", _backImage, _backMsg,
                              _isBackValid, false)),
                    ],
                  ),
                  if (_extractedAadharNumber != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text("Detected ID: $_extractedAadharNumber",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                    ),
                  const SizedBox(height: 25),
                  _sectionHeader("3. Farming Details"),
                  DropdownButtonFormField<String>(
                    value: _farmerType,
                    decoration: _inputDeco("Farmer Type"),
                    items: ['Individual', 'Family', 'FPO', 'SHG']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _farmerType = v),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _landSizeCategory,
                    decoration: _inputDeco("Land Size"),
                    items: ['< 1 Acre', '1-2 Acres', '2-5 Acres', '> 5 Acres']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _landSizeCategory = v),
                  ),
                  const SizedBox(height: 15),
                  InkWell(
                    onTap: _showCategoryMultiSelect,
                    child: InputDecorator(
                      decoration: _inputDeco("Crop Categories"),
                      child: _selectedCropCategories.isEmpty
                          ? const Text("Select Categories",
                              style: TextStyle(color: Colors.grey))
                          : Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: _selectedCropCategories
                                  .map((e) => Chip(
                                        label: Text(e,
                                            style:
                                                const TextStyle(fontSize: 12)),
                                        backgroundColor: Colors.orange.shade100,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ))
                                  .toList(),
                            ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _productionCapacity,
                    decoration: _inputDeco("Typical Production Capacity"),
                    items: _quantityOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _productionCapacity = v),
                  ),
                  const SizedBox(height: 25),
                  _sectionHeader("4. Address & Location"),
                  _input("Address Line 1 *", _addr1Ctrl),
                  const SizedBox(height: 15),
                  _input("Address Line 2", _addr2Ctrl, required: false),
                  const SizedBox(height: 15),
                  _input("Pincode *", _pinCtrl, type: TextInputType.number),
                  const SizedBox(height: 15),
                  _locDD("State *", _selectedStateId, _stateList, (val) {
                    setState(() {
                      _selectedStateId = val;
                      _districtList = LocationService.getDistricts(val!);
                      _selectedDistrictId = null;
                      _talukaList = [];
                      _villageList = [];
                    });
                  }),
                  const SizedBox(height: 15),
                  _locDD("District *", _selectedDistrictId, _districtList,
                      (val) {
                    setState(() {
                      _selectedDistrictId = val;
                      _talukaList =
                          LocationService.getTalukas(_selectedStateId!, val!);
                      _selectedTalukaId = null;
                      _villageList = [];
                    });
                  }),
                  const SizedBox(height: 15),
                  _locDD("Taluka *", _selectedTalukaId, _talukaList, (val) {
                    setState(() {
                      _selectedTalukaId = val;
                      _villageList = LocationService.getVillages(
                          _selectedStateId!, _selectedDistrictId!, val!);
                      _selectedVillageId = null;
                    });
                  }),
                  const SizedBox(height: 15),
                  _locDD("Village *", _selectedVillageId, _villageList, (val) {
                    setState(() => _selectedVillageId = val);
                  }),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _registerFarmer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE65100),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("CREATE FARMER ACCOUNT",
=======
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register New Farmer"),
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionHeader("Personal Information"),
              Row(
                children: [
                  Expanded(child: _input("First Name *", _firstNameCtrl)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _input("Middle Name", _middleNameCtrl,
                          required: false)),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _input("Last Name *", _lastCtrl)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _input("Mobile Number *", _phoneCtrl,
                          type: TextInputType.phone)),
                ],
              ),

              const SizedBox(height: 25),
              _sectionHeader("Farming Details"),

              // Farmer Type
              DropdownButtonFormField<String>(
                value: _farmerType,
                decoration: _inputDeco("Farmer Type"),
                items: ['Individual', 'Family', 'FPO', 'SHG']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _farmerType = v),
              ),
              const SizedBox(height: 15),

              // Land Size
              DropdownButtonFormField<String>(
                value: _landSizeCategory,
                decoration: _inputDeco("Land Size"),
                items: ['< 1 Acre', '1-2 Acres', '2-5 Acres', '> 5 Acres']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _landSizeCategory = v),
              ),
              const SizedBox(height: 15),

              // ✅ NEW: Multi-Select Crop Categories
              InkWell(
                onTap: _showCategoryMultiSelect,
                child: InputDecorator(
                  decoration: _inputDeco("Crop Categories (Multi-select)"),
                  child: _selectedCropCategories.isEmpty
                      ? const Text("Select Categories",
                          style: TextStyle(color: Colors.grey))
                      : Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _selectedCropCategories
                              .map((e) => Chip(
                                    label: Text(e,
                                        style: const TextStyle(fontSize: 12)),
                                    backgroundColor: Colors.orange.shade100,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ))
                              .toList(),
                        ),
                ),
              ),
              const SizedBox(height: 15),

              // ✅ NEW: Quantity Capacity
              DropdownButtonFormField<String>(
                value: _productionCapacity,
                decoration: _inputDeco("Typical Production Capacity"),
                items: _quantityOptions
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _productionCapacity = v),
              ),

              const SizedBox(height: 25),
              _sectionHeader("Address Details"),
              _input("Address Line 1 (House/Street) *", _addr1Ctrl),
              const SizedBox(height: 15),
              _input("Address Line 2 (Landmark)", _addr2Ctrl, required: false),
              const SizedBox(height: 15),
              _input("Pincode *", _pinCtrl, type: TextInputType.number),

              const SizedBox(height: 25),
              _sectionHeader("Location (Village/Region)"),

              // 1. State
              _locDD("State *", _selectedStateId, _stateList, (val) {
                setState(() {
                  _selectedStateId = val;
                  _districtList = LocationService.getDistricts(val!);
                  _selectedDistrictId = null;
                  _talukaList = [];
                  _villageList = [];
                });
              }),
              const SizedBox(height: 15),

              // 2. District
              _locDD("District *", _selectedDistrictId, _districtList, (val) {
                setState(() {
                  _selectedDistrictId = val;
                  _talukaList =
                      LocationService.getTalukas(_selectedStateId!, val!);
                  _selectedTalukaId = null;
                  _villageList = [];
                });
              }),
              const SizedBox(height: 15),

              // 3. Taluka
              _locDD("Taluka *", _selectedTalukaId, _talukaList, (val) {
                setState(() {
                  _selectedTalukaId = val;
                  _villageList = LocationService.getVillages(
                      _selectedStateId!, _selectedDistrictId!, val!);
                  _selectedVillageId = null;
                });
              }),
              const SizedBox(height: 15),

              // 4. Village
              _locDD("Village *", _selectedVillageId, _villageList, (val) {
                setState(() => _selectedVillageId = val);
              }),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _isLoading ? null : _registerFarmer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE65100),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("CREATE FARMER ACCOUNT",
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
<<<<<<< HEAD
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
        // Loading Overlay
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          )
      ],
=======
              ),
            ],
          ),
        ),
      ),
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
    );
  }

  // --- HELPERS ---
<<<<<<< HEAD
=======

>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE65100))),
    );
  }

  Widget _input(String label, TextEditingController ctrl,
      {TextInputType type = TextInputType.text, bool required = true}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      validator: (val) {
        if (!required) return null;
        return val == null || val.isEmpty ? "Required" : null;
      },
      decoration: _inputDeco(label),
    );
  }

  Widget _locDD(String label, String? val, List<LocalizedItem> items,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: val,
      isExpanded: true,
      decoration: _inputDeco(label),
      items: items
          .map((e) => DropdownMenuItem(value: e.id, child: Text(e.nameEn)))
          .toList(),
      onChanged: onChanged,
    );
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      isDense: true,
    );
  }
<<<<<<< HEAD

  Widget _buildIdCard(
      String title, File? img, String msg, bool isValid, bool isFront) {
    Color borderColor = Colors.grey.shade300;
    if (isValid)
      borderColor = Colors.green;
    else if (msg.contains("❌") || msg.contains("⚠️")) borderColor = Colors.red;

    return GestureDetector(
      onTap: () => _pickImage(isFront),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Column(
          children: [
            Expanded(
              child: img == null
                  ? Icon(Icons.add_a_photo,
                      color: Colors.orange.shade200, size: 35)
                  : ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(6)),
                      child: Image.file(img,
                          width: double.infinity, fit: BoxFit.cover)),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: isValid
                    ? Colors.green
                    : (img != null ? Colors.orange : Colors.grey.shade100),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(6)),
              ),
              child: Text(isValid ? "Verified" : title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: (isValid || img != null)
                          ? Colors.white
                          : Colors.black54)),
            )
          ],
        ),
      ),
    );
  }
}

class _MultiSelectDialog extends StatefulWidget {
  final List<String> items;
  final List<String> initialSelected;
  const _MultiSelectDialog(
      {required this.items, required this.initialSelected});
=======
}

// --- INTERNAL WIDGET: Multi-Select Dialog ---
class _MultiSelectDialog extends StatefulWidget {
  final List<String> items;
  final List<String> initialSelected;

  const _MultiSelectDialog(
      {required this.items, required this.initialSelected});

>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
  @override
  State<_MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<_MultiSelectDialog> {
  late List<String> _tempSelected;
<<<<<<< HEAD
=======

>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.initialSelected);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
<<<<<<< HEAD
      title: const Text("Select Categories"),
=======
      title: const Text("Select Crop Categories"),
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items.map((item) {
            return CheckboxListTile(
              value: _tempSelected.contains(item),
              title: Text(item),
              activeColor: const Color(0xFFE65100),
              onChanged: (bool? checked) {
                setState(() {
<<<<<<< HEAD
                  if (checked == true)
                    _tempSelected.add(item);
                  else
                    _tempSelected.remove(item);
=======
                  if (checked == true) {
                    _tempSelected.add(item);
                  } else {
                    _tempSelected.remove(item);
                  }
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
<<<<<<< HEAD
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL")),
        ElevatedButton(
            onPressed: () => Navigator.pop(context, _tempSelected),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE65100)),
            child: const Text("OK", style: TextStyle(color: Colors.white))),
=======
          onPressed: () => Navigator.pop(context),
          child: const Text("CANCEL"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _tempSelected),
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE65100)),
          child: const Text("OK", style: TextStyle(color: Colors.white)),
        ),
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
      ],
    );
  }
}
