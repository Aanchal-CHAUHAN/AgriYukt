import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class InspectorAddCropTab extends StatefulWidget {
<<<<<<< HEAD
  final Map<String, dynamic>? preSelectedFarmer;
=======
  // ✅ Accepts a specific farmer if navigated from the list
  final Map<String, dynamic>? preSelectedFarmer;
  // ✅ Allows editing existing crops
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
  final Map<String, dynamic>? cropToEdit;

  const InspectorAddCropTab(
      {super.key, this.preSelectedFarmer, this.cropToEdit});

  @override
  State<InspectorAddCropTab> createState() => _InspectorAddCropTabState();
}

class _InspectorAddCropTabState extends State<InspectorAddCropTab> {
  final _client = Supabase.instance.client;

  int _currentStep = 0;
  bool _isLoading = false;
  bool _isEditMode = false;

<<<<<<< HEAD
  // --- FARMER SELECTION ---
  List<Map<String, dynamic>> _myFarmers = [];
  String? _selectedFarmerId;
  bool _isFarmerLocked = false;
  bool _isLoadingFarmers = true;

  // --- DATA SOURCE (From your request) ---
  final Map<String, Map<String, List<String>>> _cropData = {
    'Vegetables': {
      'Tomato': ['Hybrid', 'Roma', 'Local Desi', 'Cherry', 'Beefsteak'],
      'Onion': ['Red', 'White', 'Yellow', 'Bhima Super', 'N-53'],
      'Potato': ['Kufri Jyoti', 'Kufri Lauvkar', 'Chipsona', 'Rosetta'],
      'Brinjal': ['Manjari Gota', 'Pusa Purple', 'Vengurla', 'Bharit'],
      'Chilli': ['Pusa Jwala', 'G-4', 'Sankeshwari', 'Byadgi', 'Sitara'],
      'Ladyfinger (Okra)': ['Arka Anamika', 'Parbhani Kranti', 'Hybrid'],
      'Cabbage': ['Golden Acre', 'Green Express', 'Red Cabbage'],
    },
    'Fruits': {
      'Mango': ['Alphonso (Hapus)', 'Kesar', 'Dasheri', 'Langra'],
      'Banana': ['Grand Naine (G-9)', 'Robusta', 'Yellaki', 'Nendran'],
      'Grapes': ['Thompson Seedless', 'Sonaka', 'Manik Chaman', 'Red Globe'],
      'Orange': ['Nagpur Orange', 'Mosambi', 'Kinnow'],
      'Pomegranate': ['Bhagwa', 'Ganesh', 'Arakta'],
      'Papaya': ['Red Lady', 'Taiwan 786', 'Washington'],
    }
=======
  // --- FARMER SELECTION LOGIC ---
  List<Map<String, dynamic>> _myFarmers = [];
  String? _selectedFarmerId;
  bool _isFarmerLocked = false;

  // --- DATA LISTS ---
  final List<String> _categories = [
    'Vegetables',
    'Fruits',
    'Grains',
    'Pulses',
    'Flowers',
    'Spices',
    'Commercial'
  ];

  //
  final Map<String, List<String>> _cropSuggestions = {
    'Vegetables': [
      'Tomato',
      'Onion',
      'Potato',
      'Brinjal',
      'Chilli',
      'Okra',
      'Cabbage',
      'Cauliflower'
    ],
    'Fruits': [
      'Mango',
      'Banana',
      'Grapes',
      'Pomegranate',
      'Papaya',
      'Guava',
      'Apple',
      'Watermelon'
    ],
    'Grains': ['Wheat', 'Rice', 'Maize', 'Bajra', 'Jowar'],
    'Pulses': ['Chickpea', 'Lentil', 'Peas', 'Soybean'],
    'Spices': ['Turmeric', 'Ginger', 'Garlic', 'Cumin'],
    'Commercial': ['Cotton', 'Sugarcane', 'Tobacco']
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
  };

  final List<String> _gradeOptions = [
    "Grade A (Premium)",
    "Grade B (Standard)",
    "Grade C (Fair)",
    "Organic"
  ];

<<<<<<< HEAD
  final List<String> _statusOptions = ['Active', 'Sold', 'Inactive'];

  // --- CONTROLLERS ---
  String _status = 'Active';
  String _cropType = "Organic";
  String? _selectedCategory;
  String? _selectedCrop;
  String? _selectedVariety;
  String? _selectedGrade;
  String? _selectedUnit = "Quintal (q)";

=======
  // --- CONTROLLERS ---
  String _cropType = "Organic";
  String _status = "Active";
  String? _selectedCategory;
  String? _selectedCrop;
  String? _selectedGrade;
  String? _selectedUnit = "Quintal (q)";

  final _varietyCtrl = TextEditingController();
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime? _harvestDate;
<<<<<<< HEAD
  DateTime? _availableDate; // DB: available_from

=======
  DateTime? _availableDate;

  // --- IMAGE LOGIC ---
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
  File? _selectedImage;
  String? _existingImageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

<<<<<<< HEAD
    // 1. Handle Farmer Selection
=======
    // 1. Handle Pre-selected Farmer (From List)
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
    if (widget.preSelectedFarmer != null) {
      _selectedFarmerId = widget.preSelectedFarmer!['id'];
      _isFarmerLocked = true;
      _myFarmers = [widget.preSelectedFarmer!];
<<<<<<< HEAD
      _isLoadingFarmers = false;
    } else {
      _fetchMappedFarmers();
    }

    // 2. Handle Edit Mode
=======
    } else {
      // 2. Otherwise fetch all mapped farmers
      _fetchMappedFarmers();
    }

    // 3. Handle Edit Mode
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
    if (widget.cropToEdit != null) {
      _isEditMode = true;
      _loadExistingData(widget.cropToEdit!);
    }
  }

  Future<void> _fetchMappedFarmers() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return;

<<<<<<< HEAD
      // Filter by 'onboarded_by' OR 'inspector_id' to find farmers this inspector added
      final response = await _client
          .from('profiles')
          .select('id, first_name, last_name')
          .or('role.eq.farmer,role.eq.Farmer')
          .or('onboarded_by.eq.${user.id},inspector_id.eq.${user.id}');
=======
      final response = await _client
          .from('profiles')
          .select('id, first_name, last_name')
          .eq('role', 'Farmer')
          .eq('inspector_id', user.id); // Filter by current inspector
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416

      final List<Map<String, dynamic>> sorted =
          List<Map<String, dynamic>>.from(response);

<<<<<<< HEAD
      // Sort alphabetically
=======
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
      sorted.sort((a, b) {
        final nameA = "${a['first_name']} ${a['last_name']}".toLowerCase();
        final nameB = "${b['first_name']} ${b['last_name']}".toLowerCase();
        return nameA.compareTo(nameB);
      });

      if (mounted) {
<<<<<<< HEAD
        setState(() {
          _myFarmers = sorted;
          _isLoadingFarmers = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) setState(() => _isLoadingFarmers = false);
=======
        setState(() => _myFarmers = sorted);
      }
    } catch (e) {
      debugPrint("Error fetching farmers: $e");
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
    }
  }

  void _loadExistingData(Map<String, dynamic> c) {
    _selectedFarmerId = c['farmer_id'];
    _isFarmerLocked = true;

<<<<<<< HEAD
    // Status
    String dbStatus = c['status'] ?? 'Active';
    // Capitalize first letter to match options
    if (dbStatus.isNotEmpty) {
      dbStatus =
          dbStatus[0].toUpperCase() + dbStatus.substring(1).toLowerCase();
    }
    _status = _statusOptions.contains(dbStatus) ? dbStatus : 'Active';

    _cropType = c['crop_type'] ?? "Organic";

    // Category & Crop
    if (c['category'] != null && _cropData.containsKey(c['category'])) {
      _selectedCategory = c['category'];
      String? dbCrop = c['crop_name'] ?? c['name'];
      if (dbCrop != null && _cropData[_selectedCategory]!.containsKey(dbCrop)) {
        _selectedCrop = dbCrop;
        // Variety
        if (c['variety'] != null &&
            _cropData[_selectedCategory]![_selectedCrop]!
                .contains(c['variety'])) {
          _selectedVariety = c['variety'];
=======
    // Database mapping (Handling potential nulls)
    _cropType = c['crop_type'] ?? "Organic";
    _status = c['status'] ?? "Active";
    _selectedCategory = c['category'];
    _selectedCrop = c['name']; // DB Column is 'name'
    _varietyCtrl.text = c['variety'] ?? "";
    _selectedGrade = c['grade'];
    _notesCtrl.text = c['description'] ?? ""; // DB Column is 'description'
    _priceCtrl.text = (c['price'] ?? 0).toString();
    _existingImageUrl = c['image_url'];

    // Handle Quantity Splitting (e.g., "50 Quintal" -> 50, Quintal)
    final qtyString = (c['quantity'] ?? "").toString();
    final parts = qtyString.split(' ');
    if (parts.isNotEmpty) {
      _qtyCtrl.text = parts[0];
      if (parts.length > 1) {
        String unit = parts.sublist(1).join(' '); // Rejoin remaining parts
        if (["Quintal (q)", "Kg", "Ton", "Crates"].contains(unit)) {
          _selectedUnit = unit;
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
        }
      }
    }

<<<<<<< HEAD
    if (_gradeOptions.contains(c['grade'])) _selectedGrade = c['grade'];

    // FIX: Handle Quantity safely (DB is numeric, but might have old text data)
    // We treat it as a number here.
    _qtyCtrl.text = (c['quantity'] ?? "").toString();

    // Extract unit from description if we saved it there previously,
    // or just default to Quintal. (Since DB doesn't have unit column)
    if ((c['description'] ?? "").contains("(Unit:")) {
      // logic to extract could go here, but keeping it simple
    }

    _priceCtrl.text = (c['price'] ?? 0).toString();
    _notesCtrl.text = c['description'] ?? "";
    _existingImageUrl = c['image_url'];

    if (c['harvest_date'] != null) {
      _harvestDate = DateTime.tryParse(c['harvest_date'].toString());
    }
    // Correct column name
    if (c['available_from'] != null) {
      _availableDate = DateTime.tryParse(c['available_from'].toString());
    }
  }

  // --- IMAGE PICKER ---
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: source, imageQuality: 70);
      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          children: [
            ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => _pickImage(ImageSource.camera)),
            ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => _pickImage(ImageSource.gallery)),
          ],
        ),
      ),
    );
  }

  // --- SUBMIT ---
  Future<void> _submit() async {
    if (_selectedFarmerId == null) {
      _showSnack("Please select a Farmer", Colors.red);
=======
    if (c['harvest_date'] != null) {
      _harvestDate = DateTime.tryParse(c['harvest_date']);
    }
    if (c['available_from'] != null) {
      _availableDate = DateTime.tryParse(c['available_from']);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: source, imageQuality: 60);
      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    } catch (e) {
      debugPrint("Image Error: $e");
    }
  }

  // --- SUBMIT LOGIC ---
  Future<void> _submit() async {
    if (_selectedFarmerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please select a Farmer"),
          backgroundColor: Colors.red));
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
      return;
    }
    if (_selectedCrop == null ||
        _qtyCtrl.text.isEmpty ||
        _priceCtrl.text.isEmpty) {
<<<<<<< HEAD
      _showSnack("Please fill all required fields (*)", Colors.red);
=======
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please fill Crop Name, Price, and Quantity."),
          backgroundColor: Colors.red));
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _client.auth.currentUser;
      if (user == null) throw "User not logged in";

      String? imageUrl = _existingImageUrl;

<<<<<<< HEAD
      if (_selectedImage != null) {
        final ext = _selectedImage!.path.split('.').last;
        final fileName =
            '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$ext';
        await _client.storage.from('crop_images').uploadBinary(
            fileName, await _selectedImage!.readAsBytes(),
=======
      // 1. Upload Image
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        final fileExt = _selectedImage!.path.split('.').last;
        final fileName =
            '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

        // Upload logic
        await _client.storage.from('crop_images').uploadBinary(fileName, bytes,
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
            fileOptions: const FileOptions(upsert: true));
        imageUrl = _client.storage.from('crop_images').getPublicUrl(fileName);
      }

<<<<<<< HEAD
      // ✅ FIX: The Database 'quantity' is numeric.
      // We send ONLY the number to 'quantity'.
      // We append the Unit to 'description' so it's not lost.

      final double qtyNum = double.tryParse(_qtyCtrl.text) ?? 0;
      final String notesWithUnit = "${_notesCtrl.text} (Unit: $_selectedUnit)";

      final Map<String, dynamic> cropData = {
        'farmer_id': _selectedFarmerId,
        'inspector_id': user.id, // Track who added it
        'crop_name': _selectedCrop,
        'category': _selectedCategory,
        'variety': _selectedVariety,
        'grade': _selectedGrade,

        // ✅ CRITICAL FIX: Send Number, not String
        'quantity': qtyNum,

        'price': double.tryParse(_priceCtrl.text) ?? 0,
        'crop_type': _cropType,
        'status': _status,
        'harvest_date': _harvestDate?.toIso8601String().split('T')[0],
        'available_from':
            _availableDate?.toIso8601String().split('T')[0], // correct column
        'description': notesWithUnit, // Saving unit here
=======
      // 2. Prepare Data (Mapped to Standard Schema)
      final fullQuantity = "${_qtyCtrl.text} $_selectedUnit";

      final Map<String, dynamic> cropData = {
        'farmer_id': _selectedFarmerId,
        'inspector_id': user.id,
        'name': _selectedCrop, // Standard Column: name
        'category': _selectedCategory,
        'variety': _varietyCtrl.text,
        'grade': _selectedGrade,
        'quantity': fullQuantity, // Standard Column: quantity (text)
        'price':
            double.tryParse(_priceCtrl.text) ?? 0, // Standard Column: price
        'crop_type': _cropType,
        'status': _isEditMode ? _status : 'Active',
        'harvest_date': _harvestDate?.toIso8601String(),
        'available_from': _availableDate?.toIso8601String(),
        'description': _notesCtrl.text, // Standard Column: description
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
        'image_url': imageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

<<<<<<< HEAD
      if (!_isEditMode) {
        cropData['created_at'] = DateTime.now().toIso8601String();
        await _client.from('crops').insert(cropData);
      } else {
=======
      // 3. DB Ops
      if (_isEditMode) {
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
        await _client
            .from('crops')
            .update(cropData)
            .eq('id', widget.cropToEdit!['id']);
<<<<<<< HEAD
      }

      if (mounted) {
        Navigator.pop(context, true);
        _showSnack(
            _isEditMode ? "Crop Updated!" : "Crop Listed!", Colors.green);
      }
    } catch (e) {
      if (mounted) _showSnack("Error: $e", Colors.red);
=======
      } else {
        cropData['created_at'] = DateTime.now().toIso8601String();
        await _client.from('crops').insert(cropData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                _isEditMode ? "Crop Updated!" : "Crop Listed Successfully!"),
            backgroundColor: Colors.green));

        // Return true to refresh previous screen
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

<<<<<<< HEAD
  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

=======
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
<<<<<<< HEAD
          title: Text(_isEditMode ? "Edit Crop" : "Add New Crop"),
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
=======
        title: Text(_isEditMode ? "Edit Crop" : "Add Crop for Farmer"),
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE65100)))
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
          : Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              elevation: 0,
              controlsBuilder: (context, details) => _buildButtons(details),
              onStepContinue: () =>
                  _currentStep < 2 ? setState(() => _currentStep++) : _submit(),
              onStepCancel: () =>
                  _currentStep > 0 ? setState(() => _currentStep--) : null,
              steps: _getSteps(),
            ),
    );
  }

  Widget _buildButtons(ControlsDetails details) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(children: [
        Expanded(
            child: ElevatedButton(
                onPressed: details.onStepContinue,
                style: ElevatedButton.styleFrom(
<<<<<<< HEAD
                    backgroundColor: const Color(0xFF2E7D32),
=======
                    backgroundColor: const Color(0xFFE65100),
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: Text(
                    _currentStep == 2
                        ? (_isEditMode ? "UPDATE CROP" : "SUBMIT CROP")
                        : "NEXT",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)))),
        if (_currentStep > 0) ...[
          const SizedBox(width: 10),
          Expanded(
              child: OutlinedButton(
                  onPressed: details.onStepCancel,
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.grey)),
                  child: const Text("BACK",
                      style: TextStyle(color: Colors.grey)))),
        ],
      ]),
    );
  }

  List<Step> _getSteps() {
    return [
      // STEP 1: INFO
      Step(
        title: const Text("Info"),
        isActive: _currentStep >= 0,
<<<<<<< HEAD
        content: Column(children: [
          // Status Dropdown (Edit Mode)
          if (_isEditMode)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange[200]!)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Current Status",
                        style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                    const SizedBox(height: 5),
                    _dropdown("Status", _status, _statusOptions,
                        (v) => setState(() => _status = v!)),
                  ]),
            ),

          // Farmer Select
          const Align(
              alignment: Alignment.centerLeft,
              child: Text("Select Farmer",
                  style: TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(height: 5),
          _isLoadingFarmers
              ? const LinearProgressIndicator(color: Colors.green)
              : _myFarmers.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8)),
                      child: const Text("No farmers found under your ID.",
                          style: TextStyle(color: Colors.red)))
                  : DropdownButtonFormField<String>(
                      value: _selectedFarmerId,
                      hint: const Text("Select Farmer"),
                      items: _myFarmers
                          .map((f) => DropdownMenuItem(
                              value: f['id'].toString(),
                              child: Text(
                                  "${f['first_name']} ${f['last_name'] ?? ''}")))
                          .toList(),
                      onChanged: _isFarmerLocked
                          ? null
                          : (v) => setState(() => _selectedFarmerId = v),
                      decoration: _inputDeco("Select Farmer").copyWith(
                          fillColor: _isFarmerLocked
                              ? Colors.grey[200]
                              : Colors.white),
                    ),

          const SizedBox(height: 15),
          Row(children: [
            _typeButton("Organic", Colors.green),
            const SizedBox(width: 8),
            _typeButton("Inorganic", Colors.orange)
          ]),
          const SizedBox(height: 15),

          _dropdown("Category *", _selectedCategory, _cropData.keys.toList(),
              (val) {
            setState(() {
              _selectedCategory = val;
              _selectedCrop = null;
              _selectedVariety = null;
=======
        content:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Select Farmer
          _sectionLabel("Select Farmer"),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            value: _selectedFarmerId,
            hint: const Text("Select Farmer"),
            items: _myFarmers
                .map((f) => DropdownMenuItem(
                    value: f['id'].toString(),
                    child: Text("${f['first_name']} ${f['last_name']}",
                        overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: _isFarmerLocked
                ? null
                : (v) => setState(() => _selectedFarmerId = v),
            decoration: _inputDeco("Select Farmer").copyWith(
              fillColor: _isFarmerLocked ? Colors.grey.shade200 : Colors.white,
            ),
          ),
          const SizedBox(height: 15),

          _sectionLabel("Farming Type"),
          const SizedBox(height: 5),
          Row(children: [
            _typeBtn("Organic", Colors.green),
            const SizedBox(width: 8),
            _typeBtn("Inorganic", Colors.orange)
          ]),
          const SizedBox(height: 15),

          _dropdown("Category *", _selectedCategory, _categories, (val) {
            setState(() {
              _selectedCategory = val;
              _selectedCrop = null;
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
            });
          }),
          const SizedBox(height: 15),

          _dropdown(
<<<<<<< HEAD
              "Crop *",
              _selectedCrop,
              _selectedCategory == null
                  ? []
                  : _cropData[_selectedCategory]!.keys.toList(), (val) {
            setState(() {
              _selectedCrop = val;
              _selectedVariety = null;
            });
          }),
          const SizedBox(height: 15),

          _dropdown(
              "Variety",
              _selectedVariety,
              (_selectedCategory != null && _selectedCrop != null)
                  ? _cropData[_selectedCategory]![_selectedCrop]!
                  : [],
              (val) => setState(() => _selectedVariety = val)),
=======
            "Crop Name *",
            _selectedCrop,
            (_selectedCategory != null &&
                    _cropSuggestions.containsKey(_selectedCategory))
                ? _cropSuggestions[_selectedCategory!]!
                : [],
            (val) => setState(() => _selectedCrop = val),
          ),
          const SizedBox(height: 15),

          _txt("Variety", _varietyCtrl, TextInputType.text),
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
          const SizedBox(height: 15),

          _dropdown("Grade", _selectedGrade, _gradeOptions,
              (v) => setState(() => _selectedGrade = v)),
        ]),
      ),

<<<<<<< HEAD
      // STEP 2: RATE
      Step(
        title: const Text("Rate"),
        isActive: _currentStep >= 1,
        content: Column(children: [
          Row(children: [
            Expanded(
                flex: 2,
                child: _inputField("Quantity *", _qtyCtrl,
                    type: TextInputType.number)),
            const SizedBox(width: 10),
            Expanded(
                flex: 2,
                child: _dropdown(
                    "Unit",
                    _selectedUnit,
                    ["Quintal (q)", "Kg", "Ton", "Crates"],
                    (v) => setState(() => _selectedUnit = v))),
          ]),
          const SizedBox(height: 15),
          _inputField("Price/Unit (₹) *", _priceCtrl,
              type: TextInputType.number, prefix: "₹"),
          const SizedBox(height: 10),
          if (_priceCtrl.text.isNotEmpty && _qtyCtrl.text.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                const Icon(Icons.calculate, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                    "Total: ₹${((double.tryParse(_qtyCtrl.text) ?? 0) * (double.tryParse(_priceCtrl.text) ?? 0)).toStringAsFixed(0)}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green))
              ]),
            )
        ]),
      ),

      // STEP 3: PIC
=======
      // STEP 2: PRICE
      Step(
        title: const Text("Price"),
        isActive: _currentStep >= 1,
        content: Column(children: [
          Row(
            children: [
              Expanded(
                  flex: 2,
                  child: _txt("Quantity *", _qtyCtrl, TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(
                  flex: 2,
                  child: _dropdown(
                      "Unit",
                      _selectedUnit,
                      ["Quintal (q)", "Kg", "Ton", "Crates"],
                      (v) => setState(() => _selectedUnit = v))),
            ],
          ),
          const SizedBox(height: 15),
          _txt("Price per Unit (₹) *", _priceCtrl, TextInputType.number),
          const SizedBox(height: 10),

          // Total Calculation
          if (_priceCtrl.text.isNotEmpty && _qtyCtrl.text.isNotEmpty)
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  const Icon(Icons.calculate, color: Colors.orange),
                  const SizedBox(width: 8),
                  Flexible(
                      child: Text(
                          "Total Expected: ₹${((double.tryParse(_qtyCtrl.text) ?? 0) * (double.tryParse(_priceCtrl.text) ?? 0)).toStringAsFixed(0)}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange),
                          overflow: TextOverflow.ellipsis))
                ]))
        ]),
      ),

      // STEP 3: PIC & DATES
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
      Step(
        title: const Text("Pic"),
        isActive: _currentStep >= 2,
        content: Column(children: [
<<<<<<< HEAD
          _datePicker("Harvest Date", _harvestDate,
              (d) => setState(() => _harvestDate = d)),
          const SizedBox(height: 15),
          _datePicker("Available From", _availableDate,
              (d) => setState(() => _availableDate = d)),
          const SizedBox(height: 15),
          _inputField("Notes", _notesCtrl, maxLines: 2),
          const SizedBox(height: 15),
          InkWell(
            onTap: _showImagePickerOptions,
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!)),
              child: Stack(alignment: Alignment.center, children: [
                if (_selectedImage != null)
                  ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_selectedImage!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover))
                else if (_existingImageUrl != null)
                  ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(_existingImageUrl!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) =>
                              const Icon(Icons.broken_image)))
                else
                  const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text("Tap to add photo",
                            style: TextStyle(color: Colors.grey))
                      ])
              ]),
=======
          _dateBtn("Harvest Date", _harvestDate,
              (d) => setState(() => _harvestDate = d)),
          const SizedBox(height: 15),
          _dateBtn("Available From", _availableDate,
              (d) => setState(() => _availableDate = d)),
          const SizedBox(height: 15),
          _txt("Description / Notes", _notesCtrl, TextInputType.text, max: 2),
          const SizedBox(height: 15),

          // Image Picker UI
          InkWell(
            onTap: _showImagePicker,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400)),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover))
                  : (_existingImageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(_existingImageUrl!,
                              fit: BoxFit.cover))
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Icon(Icons.add_a_photo,
                                  size: 40, color: Colors.grey),
                              Text("Upload Image")
                            ])),
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
            ),
          ),
        ]),
      ),
    ];
  }

<<<<<<< HEAD
  // --- HELPERS ---
=======
  void _showImagePicker() {
    showModalBottomSheet(
        context: context,
        builder: (_) => SafeArea(
                child: Wrap(children: [
              ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () {
                    _pickImage(ImageSource.camera);
                    Navigator.pop(context);
                  }),
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.pop(context);
                  }),
            ])));
  }

  // --- WIDGET HELPERS ---
  Widget _sectionLabel(String l) => Text(l,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16));

>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
  InputDecoration _inputDeco(String label) {
    return InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14));
  }

  Widget _dropdown(String l, String? v, List<String> i, Function(String?) c) {
<<<<<<< HEAD
=======
    // Prevent crash if value is not in list
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
    if (v != null && !i.contains(v)) v = null;
    return DropdownButtonFormField(
        isExpanded: true,
        value: v,
        items: i
            .map((e) => DropdownMenuItem(
                value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
            .toList(),
        onChanged: c,
        decoration: _inputDeco(l));
  }

<<<<<<< HEAD
  Widget _inputField(String l, TextEditingController c,
          {TextInputType type = TextInputType.text,
          int maxLines = 1,
          String? prefix}) =>
      TextField(
          controller: c,
          keyboardType: type,
          maxLines: maxLines,
          decoration: _inputDeco(l).copyWith(prefixText: prefix));

  Widget _datePicker(String l, DateTime? d, Function(DateTime) op) => InkWell(
=======
  Widget _txt(String l, TextEditingController ctrl, TextInputType t,
          {int max = 1}) =>
      TextField(
          controller: ctrl,
          keyboardType: t,
          maxLines: max,
          decoration: _inputDeco(l));

  Widget _dateBtn(String l, DateTime? d, Function(DateTime) op) => InkWell(
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
      onTap: () async {
        final p = await showDatePicker(
            context: context,
            initialDate: d ?? DateTime.now(),
<<<<<<< HEAD
            firstDate: DateTime.now(),
=======
            firstDate: DateTime(2020),
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
            lastDate: DateTime(2030));
        if (p != null) op(p);
      },
      child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white),
<<<<<<< HEAD
          child: Row(children: [
            Expanded(
                child: Text(d == null ? l : "${d.day}/${d.month}/${d.year}")),
            const Icon(Icons.calendar_today, color: Colors.green, size: 20)
          ])));

  Widget _typeButton(String t, Color c) => Expanded(
=======
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(d == null ? l : "${d.day}/${d.month}/${d.year}"),
            const Icon(Icons.calendar_today, size: 18)
          ])));

  Widget _typeBtn(String t, Color c) => Expanded(
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
      child: GestureDetector(
          onTap: () => setState(() => _cropType = t),
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  color: _cropType == t ? c : Colors.white,
                  border: Border.all(color: c),
                  borderRadius: BorderRadius.circular(8)),
              child: Center(
                  child: Text(t,
                      style: TextStyle(
                          color: _cropType == t ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold))))));
}
