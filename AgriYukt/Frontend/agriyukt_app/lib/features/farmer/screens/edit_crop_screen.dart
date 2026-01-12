import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class EditCropScreen extends StatefulWidget {
  final Map<String, dynamic> cropData;

  const EditCropScreen({super.key, required this.cropData});

  @override
  State<EditCropScreen> createState() => _EditCropScreenState();
}

class _EditCropScreenState extends State<EditCropScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  // --- DATA SOURCE ---
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

  // --- CONTROLLERS ---
  String _status = 'Active';
  String _cropType = "Organic";
  String? _selectedCategory;
  String? _selectedCrop;
  String? _selectedVariety;
  String? _selectedGrade;
  String? _selectedUnit = "Quintal (q)";

  late TextEditingController _qtyCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _notesCtrl;

  DateTime? _harvestDate;
  DateTime? _availableDate;

  // --- IMAGE ---
  File? _selectedImage;
  String? _existingImageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _prefillData();
  }

  void _prefillData() {
    final c = widget.cropData;

    // --- 1. SANITIZE STATUS ---
    String dbStatus = c['status'] ?? 'Active';
    // Fix casing (e.g. "active" -> "Active")
    if (dbStatus.isNotEmpty) {
      dbStatus =
          dbStatus[0].toUpperCase() + dbStatus.substring(1).toLowerCase();
    }
    // Only set if valid, otherwise default to Active
    _status = _statusOptions.contains(dbStatus) ? dbStatus : 'Active';

    // --- 2. SANITIZE CATEGORY ---
    String? dbCategory = c['category'];
    // Only accept if it exists in our known keys
    _selectedCategory =
        (dbCategory != null && _cropData.containsKey(dbCategory))
            ? dbCategory
            : null;

    // --- 3. SANITIZE CROP NAME ---
    String? dbCrop = c['crop_name'] ?? c['name'];
    List<String> validCrops = _selectedCategory != null
        ? _cropData[_selectedCategory]!.keys.toList()
        : [];

    // Only set if valid for the selected category
    _selectedCrop =
        (dbCrop != null && validCrops.contains(dbCrop)) ? dbCrop : null;

    // --- 4. SANITIZE VARIETY (This fixes the "Roma" error) ---
    String? dbVariety = c['variety'];
    List<String> validVarieties =
        (_selectedCategory != null && _selectedCrop != null)
            ? _cropData[_selectedCategory]![_selectedCrop]!
            : [];

    // If DB has "Roma" but list has "Roma Tomato", this ensures we don't crash
    _selectedVariety = (dbVariety != null && validVarieties.contains(dbVariety))
        ? dbVariety
        : null;

    // --- 5. SANITIZE GRADE ---
    String? dbGrade = c['grade'];
    _selectedGrade = (dbGrade != null && _gradeOptions.contains(dbGrade))
        ? dbGrade
        : null; // Don't default, just leave empty if invalid

    _cropType = c['crop_type'] ?? "Organic";

    // --- 6. PARSE QUANTITY ---
    String rawQty = c['quantity'] ?? "0 Kg";
    String qtyVal = "0";
    List<String> parts = rawQty.split(' ');
    if (parts.length >= 2) {
      qtyVal = parts[0];
      String unit = parts.sublist(1).join(' ');
      if (["Kg", "Quintal (q)", "Ton", "Crates"].contains(unit)) {
        _selectedUnit = unit;
      }
    } else {
      qtyVal = rawQty;
    }

    _qtyCtrl = TextEditingController(text: qtyVal);
    _priceCtrl = TextEditingController(text: (c['price'] ?? 0).toString());
    _notesCtrl = TextEditingController(text: c['description'] ?? "");
    _existingImageUrl = c['image_url'];

    if (c['harvest_date'] != null)
      _harvestDate = DateTime.parse(c['harvest_date']);
    if (c['available_from'] != null)
      _availableDate = DateTime.parse(c['available_from']);
  }

  // --- IMAGE PICKER ---
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file =
          await _picker.pickImage(source: source, imageQuality: 70);
      if (file != null) {
        setState(() => _selectedImage = File(file.path));
        Navigator.pop(context); // Close Bottom Sheet
      }
    } catch (e) {
      debugPrint("Image Error: $e");
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
            const Text("Update Crop Photo",
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

  // --- DATABASE UPDATE ---
  Future<void> _updateCrop() async {
    if (_selectedCrop == null ||
        _qtyCtrl.text.isEmpty ||
        _priceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please fill all required fields (*)"),
          backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);
    final user = Supabase.instance.client.auth.currentUser;

    try {
      String? imageUrl = _existingImageUrl;

      if (_selectedImage != null && user != null) {
        final ext = _selectedImage!.path.split('.').last;
        final fileName =
            '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$ext';

        await Supabase.instance.client.storage.from('crop_images').uploadBinary(
            fileName, await _selectedImage!.readAsBytes(),
            fileOptions: const FileOptions(upsert: true));
        imageUrl = fileName;
      }

      final Map<String, dynamic> data = {
        'crop_name': _selectedCrop,
        'category': _selectedCategory,
        'variety': _selectedVariety,
        'grade': _selectedGrade,
        'quantity': "${_qtyCtrl.text} $_selectedUnit",
        'price': double.tryParse(_priceCtrl.text) ?? 0,
        'crop_type': _cropType,
        'description': _notesCtrl.text,
        'harvest_date': _harvestDate?.toIso8601String(),
        'available_from': _availableDate?.toIso8601String(),
        'image_url': imageUrl,
        'status': _status,
      };

      await Supabase.instance.client
          .from('crops')
          .update(data)
          .eq('id', widget.cropData['id']);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Crop Updated Successfully!"),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Edit ${widget.cropData['crop_name'] ?? 'Crop'}"),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
            : Stepper(
                type: StepperType.horizontal,
                currentStep: _currentStep,
                elevation: 0,
                controlsBuilder: (context, details) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: details.onStepContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(
                              _currentStep == 2 ? "SAVE CHANGES" : "NEXT",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ),
                        ),
                        if (_currentStep > 0) ...[
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: details.onStepCancel,
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: Colors.grey),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("BACK",
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ]
                      ],
                    ),
                  );
                },
                onStepContinue: () {
                  if (_currentStep < 2)
                    setState(() => _currentStep += 1);
                  else
                    _updateCrop();
                },
                onStepCancel: () {
                  if (_currentStep > 0) setState(() => _currentStep -= 1);
                },
                steps: _getSteps(),
              ),
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
            const SizedBox(height: 10),

            // Status Dropdown
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
                      (val) => setState(() => _status = val!)),
                ],
              ),
            ),

            Row(children: [
              _typeButton("Organic", Colors.green),
              const SizedBox(width: 10),
              _typeButton("Inorganic", Colors.orange),
            ]),
            const SizedBox(height: 20),

            _dropdown("Category *", _selectedCategory, ['Vegetables', 'Fruits'],
                (val) {
              setState(() {
                _selectedCategory = val;
                _selectedCrop = null;
                _selectedVariety = null;
              });
            }),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            _dropdown(
                "Variety",
                _selectedVariety,
                (_selectedCategory != null && _selectedCrop != null)
                    ? _cropData[_selectedCategory]![_selectedCrop]!
                    : [],
                (val) => setState(() => _selectedVariety = val)),
            const SizedBox(height: 16),
            _dropdown("Grade", _selectedGrade, _gradeOptions,
                (val) => setState(() => _selectedGrade = val)),
          ],
        ),
      ),
      Step(
        title: const Text("Rate"),
        isActive: _currentStep >= 1,
        content: Column(
          children: [
            const SizedBox(height: 10),
            _inputField("Quantity Available *", _qtyCtrl,
                type: TextInputType.number),
            const SizedBox(height: 16),
            _dropdown(
                "Unit",
                _selectedUnit,
                ["Kg", "Quintal (q)", "Ton", "Crates"],
                (val) => setState(() => _selectedUnit = val)),
            const SizedBox(height: 16),
            _inputField("Price per Unit (₹) *", _priceCtrl,
                type: TextInputType.number, prefix: "₹"),
            const SizedBox(height: 20),
            if (_priceCtrl.text.isNotEmpty && _qtyCtrl.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!)),
                child: Row(
                  children: [
                    const Icon(Icons.calculate, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(
                            "Est. Total Value: ₹${(double.tryParse(_qtyCtrl.text) ?? 0 * (double.tryParse(_priceCtrl.text) ?? 0)).toStringAsFixed(0)}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 16))),
                  ],
                ),
              )
          ],
        ),
      ),
      Step(
        title: const Text("Details"),
        isActive: _currentStep >= 2,
        content: Column(
          children: [
            const SizedBox(height: 10),

            // Image Box
            InkWell(
              onTap: _showImagePickerOptions,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!)),
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
                          Text("Tap to change photo",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(blurRadius: 5, color: Colors.black26)
                            ]),
                        child: const Icon(Icons.edit,
                            size: 20, color: Color(0xFF2E7D32)),
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            _datePicker("Harvest Date", _harvestDate,
                (d) => setState(() => _harvestDate = d)),
            const SizedBox(height: 12),
            _datePicker("Available From", _availableDate,
                (d) => setState(() => _availableDate = d)),

            const SizedBox(height: 20),
            _inputField("Description / Notes", _notesCtrl, maxLines: 3),
          ],
        ),
      ),
    ];
  }

  // --- WIDGET HELPERS ---

  Widget _typeButton(String type, Color color) {
    bool isSelected = _cropType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _cropType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: isSelected ? color : Colors.grey[300]!,
                width: isSelected ? 2 : 1),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  ]
                : [],
          ),
          child: Center(
            child: Text(type,
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _dropdown(String label, String? value, List<String> items,
      Function(String?) onChanged) {
    // 🔥 SAFEGUARD: Force null if DB value is invalid
    if (value != null && !items.contains(value)) {
      value = null;
    }

    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl,
      {TextInputType type = TextInputType.text,
      int maxLines = 1,
      String? prefix}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _datePicker(
      String label, DateTime? date, Function(DateTime) onConfirm) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030));
        if (d != null) onConfirm(d);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                date == null ? label : "${date.day}/${date.month}/${date.year}",
                style: TextStyle(
                    color: date == null ? Colors.grey[700] : Colors.black,
                    fontSize: 16)),
            const Icon(Icons.calendar_today, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
