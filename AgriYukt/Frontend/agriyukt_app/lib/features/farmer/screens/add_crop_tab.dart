import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class AddCropTab extends StatefulWidget {
  final Map<String, dynamic>? cropToEdit;

  const AddCropTab({super.key, this.cropToEdit});

  @override
  State<AddCropTab> createState() => _AddCropTabState();
}

class _AddCropTabState extends State<AddCropTab> {
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isEditMode = false;

  // --- 1. DATA SOURCE ---
  final Map<String, Map<String, List<String>>> _cropData = {
    'Vegetables': {
      'Tomato': [
        'Hybrid Tomato',
        'Roma Tomato',
        'Local Desi',
        'Cherry Tomato',
        'Beefsteak'
      ],
      'Onion': [
        'Red Onion',
        'White Onion',
        'Yellow Onion',
        'Bhima Super',
        'N-53'
      ],
      'Potato': ['Kufri Jyoti', 'Kufri Lauvkar', 'Chipsona', 'Rosetta'],
      'Brinjal': ['Manjari Gota', 'Pusa Purple', 'Vengurla', 'Bharit'],
      'Chilli': ['Pusa Jwala', 'G-4', 'Sankeshwari', 'Byadgi', 'Sitara'],
      'Ladyfinger (Okra)': ['Arka Anamika', 'Parbhani Kranti', 'Hybrid Okra'],
      'Cabbage': ['Golden Acre', 'Green Express', 'Red Cabbage'],
    },
    'Fruits': {
      'Mango': ['Alphonso (Hapus)', 'Kesar', 'Dasheri', 'Langra', 'Totapuri'],
      'Banana': ['Grand Naine (G-9)', 'Robusta', 'Yellaki', 'Nendran'],
      'Grapes': ['Thompson Seedless', 'Sonaka', 'Manik Chaman', 'Red Globe'],
      'Orange': ['Nagpur Orange', 'Mosambi', 'Kinnow'],
      'Pomegranate': ['Bhagwa', 'Ganesh', 'Arakta'],
      'Papaya': ['Red Lady', 'Taiwan 786', 'Washington'],
    }
  };

  final List<String> _gradeOptions = [
    "Grade A (Premium)",
    "Grade B (Standard)",
    "Grade C (Fair)"
  ];
  final List<String> _statusOptions = ['Active', 'Sold', 'Inactive'];

  // --- 2. CONTROLLERS ---
  String _status = 'Active'; // Status Controller
  String _cropType = "Organic";
  String? _selectedCategory;
  String? _selectedCrop;
  String? _selectedVariety;
  String? _selectedGrade;
  String? _selectedUnit = "Quintal (q)";

  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime? _harvestDate;
  DateTime? _availableDate;

  // --- IMAGE LOGIC ---
  File? _selectedImage;
  String? _existingImageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.cropToEdit != null) {
      _isEditMode = true;
      _prefillData(widget.cropToEdit!);
    }
  }

  void _prefillData(Map<String, dynamic> c) {
    // 1. Status Parsing
    String dbStatus = c['status'] ?? 'Active';
    if (dbStatus.isNotEmpty) {
      dbStatus =
          dbStatus[0].toUpperCase() + dbStatus.substring(1).toLowerCase();
    }
    _status = _statusOptions.contains(dbStatus) ? dbStatus : 'Active';

    // 2. Dropdowns (Safe Loading)
    _cropType = c['crop_type'] ?? "Organic";

    // Category
    String? dbCategory = c['category'];
    if (dbCategory != null && _cropData.containsKey(dbCategory)) {
      _selectedCategory = dbCategory;
    }

    // Crop
    String? dbCrop = c['crop_name'];
    if (_selectedCategory != null) {
      List<String> validCrops = _cropData[_selectedCategory]!.keys.toList();
      if (validCrops.contains(dbCrop)) _selectedCrop = dbCrop;
    }

    // Variety
    String? dbVariety = c['variety'];
    if (_selectedCategory != null && _selectedCrop != null) {
      List<String> validVarieties =
          _cropData[_selectedCategory]![_selectedCrop]!;
      if (validVarieties.contains(dbVariety)) _selectedVariety = dbVariety;
    }

    // Grade
    String? dbGrade = c['grade'];
    if (_gradeOptions.contains(dbGrade)) _selectedGrade = dbGrade;

    // 3. Quantity Parsing
    String rawQty = c['quantity'] ?? "0 Kg";
    List<String> qtyParts = rawQty.split(' ');
    if (qtyParts.length >= 2) {
      _qtyCtrl.text = qtyParts[0];
      String unit = qtyParts.sublist(1).join(' ');
      if (["Kg", "Quintal (q)", "Ton", "Crates"].contains(unit))
        _selectedUnit = unit;
    } else {
      _qtyCtrl.text = rawQty;
    }

    _priceCtrl.text = (c['price'] ?? 0).toString();
    _notesCtrl.text = c['description'] ?? "";
    _existingImageUrl = c['image_url'];

    if (c['harvest_date'] != null)
      _harvestDate = DateTime.parse(c['harvest_date']);
    if (c['available_from'] != null)
      _availableDate = DateTime.parse(c['available_from']);
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Upload Crop Photo",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _pickerOption(Icons.camera_alt, "Camera", ImageSource.camera),
                _pickerOption(
                    Icons.photo_library, "Gallery", ImageSource.gallery),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _pickerOption(IconData icon, String label, ImageSource src) {
    return InkWell(
      onTap: () => _pickImage(src),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!)),
        child: Column(
          children: [
            Icon(icon, size: 32, color: const Color(0xFF2E7D32)),
            const SizedBox(height: 8),
            Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))
          ],
        ),
      ),
    );
  }

  // --- SUBMIT ---
  Future<void> _submit() async {
    if (_selectedCrop == null ||
        _qtyCtrl.text.isEmpty ||
        _priceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please fill all required fields (*)"),
          backgroundColor: Colors.red));
      return;
    }

    if (!_isEditMode && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please upload a crop image."),
          backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw "User not logged in";

      // Verify Profile
      final profileData = await Supabase.instance.client
          .from('profiles')
          .select('verification_status')
          .eq('id', user.id)
          .single();
      final String status =
          profileData['verification_status'] ?? 'Not Uploaded';

      if (status != 'Verified') {
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Verification Required"),
              content: const Text(
                  "You must verify your identity before adding crops."),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("OK"))
              ],
            ),
          );
        }
        return;
      }

      String? imageUrl = _existingImageUrl;

      if (_selectedImage != null) {
        final ext = _selectedImage!.path.split('.').last;
        final fileName =
            '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$ext';
        await Supabase.instance.client.storage.from('crop_images').uploadBinary(
            fileName, await _selectedImage!.readAsBytes(),
            fileOptions: const FileOptions(upsert: true));
        imageUrl = fileName;
      }

      final Map<String, dynamic> cropData = {
        'farmer_id': user.id,
        'crop_name': _selectedCrop,
        'category': _selectedCategory,
        'variety': _selectedVariety,
        'grade': _selectedGrade,
        'quantity': "${_qtyCtrl.text} $_selectedUnit",
        'price': double.tryParse(_priceCtrl.text) ?? 0,
        'crop_type': _cropType,
        'status': _status, // ✅ Uses correct status
        'harvest_date': _harvestDate?.toIso8601String(),
        'available_from': _availableDate?.toIso8601String(),
        'description': _notesCtrl.text,
        'image_url': imageUrl,
        if (!_isEditMode) 'created_at': DateTime.now().toIso8601String(),
      };

      if (_isEditMode) {
        await Supabase.instance.client
            .from('crops')
            .update(cropData)
            .eq('id', widget.cropToEdit!['id']);
      } else {
        await Supabase.instance.client.from('crops').insert(cropData);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_isEditMode ? "Crop Updated!" : "Crop Listed!"),
            backgroundColor: Colors.green));
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
          title: Text(_isEditMode ? "Edit Crop" : "Add New Crop"),
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              elevation: 0,
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12)),
                          child: Text(
                              _currentStep == 2
                                  ? (_isEditMode ? "UPDATE" : "SUBMIT")
                                  : "NEXT",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      if (_currentStep > 0) ...[
                        const SizedBox(width: 10),
                        Expanded(
                            child: OutlinedButton(
                                onPressed: details.onStepCancel,
                                style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    side: const BorderSide(color: Colors.grey)),
                                child: const Text("BACK",
                                    style: TextStyle(color: Colors.grey)))),
                      ],
                    ],
                  ),
                );
              },
              onStepContinue: () {
                if (_currentStep < 2)
                  setState(() => _currentStep += 1);
                else
                  _submit();
              },
              onStepCancel: () {
                if (_currentStep > 0) setState(() => _currentStep -= 1);
              },
              steps: _getSteps(),
            ),
    );
  }

  List<Step> _getSteps() {
    return [
      Step(
        title: const Text("Info"),
        isActive: _currentStep >= 0,
        content: Column(
          children: [
            // ✅ STATUS DROPDOWN (Only visible in Edit Mode)
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
                  ],
                ),
              ),

            Row(children: [
              _typeButton("Organic", Colors.green),
              const SizedBox(width: 8),
              _typeButton("Inorganic", Colors.orange)
            ]),
            const SizedBox(height: 15),
            _dropdown("Category *", _selectedCategory, ['Vegetables', 'Fruits'],
                (val) {
              setState(() {
                _selectedCategory = val;
                _selectedCrop = null;
                _selectedVariety = null;
              });
            }),
            const SizedBox(height: 15),
            _dropdown(
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
            const SizedBox(height: 15),
            _dropdown("Grade", _selectedGrade, _gradeOptions,
                (v) => setState(() => _selectedGrade = v)),
          ],
        ),
      ),
      Step(
        title: const Text("Rate"),
        isActive: _currentStep >= 1,
        content: Column(
          children: [
            _inputField("Quantity *", _qtyCtrl, type: TextInputType.number),
            const SizedBox(height: 15),
            _dropdown(
                "Unit",
                _selectedUnit,
                ["Kg", "Quintal (q)", "Ton", "Crates"],
                (v) => setState(() => _selectedUnit = v)),
            const SizedBox(height: 15),
            _inputField("Price/Unit (₹) *", _priceCtrl,
                type: TextInputType.number, prefix: "₹"),
            const SizedBox(height: 10),
            if (_priceCtrl.text.isNotEmpty && _qtyCtrl.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.calculate, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                        child: Text(
                            "Total: ₹${(double.tryParse(_qtyCtrl.text) ?? 0 * (double.tryParse(_priceCtrl.text) ?? 0)).toStringAsFixed(0)}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                            overflow: TextOverflow.ellipsis)),
                  ],
                ),
              )
          ],
        ),
      ),
      Step(
        title: const Text("Pic"),
        isActive: _currentStep >= 2,
        content: Column(
          children: [
            _datePicker("Harvest Date", _harvestDate,
                (d) => setState(() => _harvestDate = d)),
            const SizedBox(height: 15),
            // ✅ AVAILABLE FROM DATE
            _datePicker("Available From", _availableDate,
                (d) => setState(() => _availableDate = d)),
            const SizedBox(height: 15),
            _inputField("Notes", _notesCtrl, maxLines: 2),
            const SizedBox(height: 15),

            // ✅ CLICKABLE IMAGE BOX (Opens Bottom Sheet)
            InkWell(
              onTap: _showImagePickerOptions,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400)),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
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
                          child: _existingImageUrl!.startsWith('http')
                              ? Image.network(_existingImageUrl!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover)
                              : Image.network(
                                  Supabase.instance.client.storage
                                      .from('crop_images')
                                      .getPublicUrl(_existingImageUrl!),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover))
                    else
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text("Tap to add photo",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _typeButton(String t, Color c) => Expanded(
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

  Widget _dropdown(String l, String? v, List<String> i, Function(String?) c) {
    // 🔥 Safety Check: If DB value is invalid, prevent crash
    if (v != null && !i.contains(v)) v = null;

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
            fillColor: Colors.grey[50]));
  }

  Widget _inputField(String l, TextEditingController c,
          {TextInputType type = TextInputType.text,
          int maxLines = 1,
          String? prefix}) =>
      TextField(
          controller: c,
          keyboardType: type,
          maxLines: maxLines,
          decoration: InputDecoration(
              labelText: l,
              prefixText: prefix,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.grey[50]));

  Widget _datePicker(String l, DateTime? d, Function(DateTime) op) => InkWell(
      onTap: () async {
        final p = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2030));
        if (p != null) op(p);
      },
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            Expanded(
                child: Text(d == null ? l : "${d.day}/${d.month}/${d.year}")),
            const Icon(Icons.calendar_today, color: Colors.green, size: 20)
          ])));
}
