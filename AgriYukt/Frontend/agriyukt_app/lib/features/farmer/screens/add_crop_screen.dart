import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class AddCropScreen extends StatefulWidget {
  final Map<String, dynamic>? cropToEdit; // If not null, we are Editing

  const AddCropScreen({super.key, this.cropToEdit});

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isEditMode = false;

  // --- DATA LISTS ---
  final List<String> _categories = [
    'Vegetables',
    'Fruits',
    'Grains',
    'Pulses',
    'Flowers'
  ];

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
  };

  final List<String> _gradeOptions = [
    "Grade A (Premium)",
    "Grade B (Standard)",
    "Grade C (Fair)"
  ];

  // Matches SQL Comment: 'Active', 'Sold', 'Inactive'
  final List<String> _statusOptions = ["Active", "Sold", "Inactive"];

  // --- CONTROLLERS ---
  String _cropType = "Organic";
  String _status = "Active";
  String? _selectedCategory;
  String? _selectedCrop;
  String? _selectedGrade;
  String? _selectedUnit = "Quintal (q)";

  // Text Controllers
  final _varietyCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime? _harvestDate;
  DateTime? _availableDate;

  File? _selectedImage;
  String? _existingImageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.cropToEdit != null) {
      _isEditMode = true;
      _loadExistingData(widget.cropToEdit!);
    }
  }

  void _loadExistingData(Map<String, dynamic> c) {
    _cropType = c['crop_type'] ?? "Organic";

    // Status Logic: Ensure it matches one of our options
    String dbStatus = c['status'] ?? "Active";
    _status = _statusOptions.contains(dbStatus) ? dbStatus : "Active";

    _selectedCategory = c['category'];
    _selectedCrop = c['crop_name'];
    _varietyCtrl.text = c['variety'] ?? "";

    // Grade Logic
    String dbGrade = c['grade'] ?? _gradeOptions[1];
    _selectedGrade =
        _gradeOptions.contains(dbGrade) ? dbGrade : _gradeOptions[1];

    _selectedUnit = c['quantity_unit'] ?? "Quintal (q)";
    _qtyCtrl.text = c['quantity_available'].toString();
    _priceCtrl.text = c['price_per_qty'].toString();
    _notesCtrl.text = c['health_notes'] ?? "";
    _existingImageUrl = c['image_url'];

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
    // 1. Basic Validation
    if (_selectedCrop == null ||
        _qtyCtrl.text.isEmpty ||
        _priceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please fill Crop Name, Price, and Quantity."),
          backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw "User not logged in";

      String? imageUrl = _existingImageUrl;

      // 2. Upload Image (if changed)
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        final fileExt = _selectedImage!.path.split('.').last;
        final fileName =
            '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

        await Supabase.instance.client.storage.from('crop_images').uploadBinary(
            fileName, bytes,
            fileOptions: const FileOptions(upsert: true));
        imageUrl = Supabase.instance.client.storage
            .from('crop_images')
            .getPublicUrl(fileName);
      }

      // 3. Prepare Data Packet (Matches SQL Schema)
      final Map<String, dynamic> cropData = {
        'farmer_id': user.id,
        'crop_name': _selectedCrop,
        'category': _selectedCategory,
        'variety': _varietyCtrl.text,
        'grade': _selectedGrade,
        'quantity_available': double.tryParse(_qtyCtrl.text) ?? 0,
        'quantity_unit': _selectedUnit,
        'price_per_qty': double.tryParse(_priceCtrl.text) ?? 0,
        'crop_type': _cropType,
        // Force 'Active' for new crops, allow Status change for edits
        'status': _isEditMode ? _status : 'Active',
        'harvest_date': _harvestDate?.toIso8601String(),
        'available_from': _availableDate?.toIso8601String(),
        'health_notes': _notesCtrl.text,
        'image_url': imageUrl,
        'updated_at': DateTime.now().toIso8601String(), // ✅ Syncs with SQL
      };

      // 4. Database Operation
      if (_isEditMode) {
        // UPDATE
        await Supabase.instance.client
            .from('crops')
            .update(cropData)
            .eq('id', widget.cropToEdit!['id']);
      } else {
        // INSERT
        cropData['created_at'] = DateTime.now().toIso8601String();
        await Supabase.instance.client.from('crops').insert(cropData);
      }

      if (mounted) {
        Navigator.pop(context, true); // Close screen & signal refresh
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_isEditMode ? "Changes Saved!" : "Crop Listed!"),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? "Edit Crop" : "Add Crop"),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          // ✅ INSTANT SAVE BUTTON (For Edit Mode)
          if (_isEditMode && !_isLoading)
            TextButton(
                onPressed: _submit,
                child: const Text("SAVE",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)))
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              elevation: 0,
              controlsBuilder: (ctx, details) => _buildButtons(details),
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
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(vertical: 12)),
                child: Text(
                    _currentStep == 2
                        ? (_isEditMode ? "UPDATE & SAVE" : "SUBMIT")
                        : "NEXT",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)))),
        if (_currentStep > 0) ...[
          const SizedBox(width: 10),
          Expanded(
              child: OutlinedButton(
                  onPressed: details.onStepCancel, child: const Text("BACK")))
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
          content:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // STATUS DROPDOWN (Edit Only)
            if (_isEditMode) ...[
              _sectionLabel("Status"),
              Container(
                margin: const EdgeInsets.only(bottom: 15, top: 5),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _status,
                    items: _statusOptions
                        .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold))))
                        .toList(),
                    onChanged: (v) => setState(() => _status = v!),
                  ),
                ),
              ),
            ],

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
              });
            }),
            const SizedBox(height: 15),

            // Smart Crop Dropdown or Text Entry
            _dropdown(
                "Crop Name *",
                _selectedCrop,
                (_selectedCategory != null &&
                        _cropSuggestions.containsKey(_selectedCategory))
                    ? _cropSuggestions[_selectedCategory!]!
                    : [],
                (val) => setState(() => _selectedCrop = val),
                allowCustom: true // Treat selection as final
                ),
            const SizedBox(height: 15),

            _txt("Variety (e.g. Lokwan)", _varietyCtrl, TextInputType.text),
            const SizedBox(height: 15),
            _dropdown("Grade", _selectedGrade, _gradeOptions,
                (v) => setState(() => _selectedGrade = v)),
          ])),

      // STEP 2: PRICE
      Step(
          title: const Text("Price"),
          isActive: _currentStep >= 1,
          content: Column(children: [
            _txt("Quantity *", _qtyCtrl, TextInputType.number),
            const SizedBox(height: 15),
            _dropdown(
                "Unit",
                _selectedUnit,
                ["Quintal (q)", "Kg", "Ton", "Crates"],
                (v) => setState(() => _selectedUnit = v)),
            const SizedBox(height: 15),
            _txt("Price (₹) *", _priceCtrl, TextInputType.number),
            const SizedBox(height: 10),
            if (_priceCtrl.text.isNotEmpty && _qtyCtrl.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  const Icon(Icons.calculate, color: Colors.green),
                  const SizedBox(width: 8),
                  Flexible(
                      child: Text(
                          "Total: ₹${(double.tryParse(_qtyCtrl.text) ?? 0 * (double.tryParse(_priceCtrl.text) ?? 0)).toStringAsFixed(0)}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.green),
                          overflow: TextOverflow.ellipsis)),
                ]),
              )
          ])),

      // STEP 3: PHOTO
      Step(
          title: const Text("Pic"),
          isActive: _currentStep >= 2,
          content: Column(children: [
            _dateBtn("Harvest Date", _harvestDate,
                (d) => setState(() => _harvestDate = d)),
            const SizedBox(height: 15),
            _dateBtn("Available From", _availableDate,
                (d) => setState(() => _availableDate = d)),
            const SizedBox(height: 15),
            _txt("Notes", _notesCtrl, TextInputType.text, max: 2),
            const SizedBox(height: 15),
            InkWell(
              onTap: () => _showImagePicker(),
              child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
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
                                ]))),
            ),
          ])),
    ];
  }

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

  // --- HELPERS ---
  Widget _sectionLabel(String l) => Text(l,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16));

  // Safe Dropdown Helper
  Widget _dropdown(String l, String? v, List<String> i, Function(String?) c,
      {bool allowCustom = false}) {
    if (v != null && !i.contains(v)) v = null; // Auto-fix invalid selection
    return DropdownButtonFormField(
        isExpanded: true,
        value: v,
        items: i
            .map((e) => DropdownMenuItem(
                value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
            .toList(),
        onChanged: c,
        decoration: InputDecoration(
            labelText: l,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white));
  }

  Widget _txt(String l, TextEditingController ctrl, TextInputType t,
          {int max = 1}) =>
      TextField(
          controller: ctrl,
          keyboardType: t,
          maxLines: max,
          decoration: InputDecoration(
              labelText: l,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.white));
  Widget _dateBtn(String l, DateTime? d, Function(DateTime) op) => InkWell(
      onTap: () async {
        final p = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2030));
        if (p != null) op(p);
      },
      child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(d == null ? l : "${d.day}/${d.month}/${d.year}"),
            const Icon(Icons.calendar_today, size: 18)
          ])));
  Widget _typeBtn(String t, Color c) => Expanded(
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
