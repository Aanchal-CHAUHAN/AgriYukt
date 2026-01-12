import 'dart:io';
import 'dart:async'; // ✅ Added for Debouncing
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agriyukt_app/core/services/location_service.dart';

class CreateAccountController extends ChangeNotifier {
  // ===========================================================================
  // 1. CONTROLLERS
  // ===========================================================================
  final TextEditingController firstNameCtrl = TextEditingController();
  final TextEditingController middleNameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController confirmPassCtrl = TextEditingController();
  final TextEditingController otpCtrl = TextEditingController();

  // Role Details
  final TextEditingController cropCategoryCtrl = TextEditingController();
  final TextEditingController produceQtyCtrl = TextEditingController();
  final TextEditingController occupationCtrl = TextEditingController();
  final TextEditingController capacityCtrl = TextEditingController();
  final TextEditingController compensationCtrl = TextEditingController();
  final TextEditingController opsLevelCtrl = TextEditingController();
  final TextEditingController avgPurchaseCtrl = TextEditingController();
  final TextEditingController shopAddressCtrl = TextEditingController();
  final TextEditingController extraInfoCtrl = TextEditingController();

  // Location
  final TextEditingController addressLine1Ctrl = TextEditingController();
  final TextEditingController addressLine2Ctrl = TextEditingController();
  final TextEditingController pinCodeCtrl = TextEditingController();

  // ===========================================================================
  // 2. STATE VARIABLES
  // ===========================================================================
  String? selectedState = "Maharashtra";
  String? selectedDistrict;
  String? selectedTaluka;
  String? selectedVillage;
  String _selectedRole = "Farmer";
  String get selectedRole => _selectedRole;

  String? farmerType;
  String? buyerType;
  String? regDetails;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- 🔴 Validation & Duplicate Check State ---
  String? phoneError;
  String? emailError;
  String? nameError; // Local logical error (same names)

  // DB Status Messages
  String? phoneDbStatus; // "Checking...", "Taken", "Available"
  bool isPhoneTaken = false;

  String? emailDbStatus;
  bool isEmailTaken = false;

  String? nameDbWarning; // "Soft warning"

  // Password Strength
  String passwordStrength = "";
  Color passwordStrengthColor = Colors.grey;
  double passwordStrengthValue = 0.0;

  // Debounce Timer
  Timer? _debounce;

  File? aadharFrontImage;
  File? aadharBackImage;
  String? extractedAadharNumber;
  String? verifiedAadharName;
  bool isIdVerified = false;

  // ===========================================================================
  // 3. INITIALIZATION
  // ===========================================================================
  CreateAccountController() {
    _initData();
  }

  Future<void> _initData() async {
    await LocationService.loadData();
    notifyListeners();
  }

  // Setters (Same as before)
  void selectRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  void setState(String? value) {
    selectedState = value;
    selectedDistrict = null;
    selectedTaluka = null;
    selectedVillage = null;
    notifyListeners();
  }

  void setDistrict(String? value) {
    selectedDistrict = value;
    selectedTaluka = null;
    selectedVillage = null;
    notifyListeners();
  }

  void setTaluka(String? value) {
    selectedTaluka = value;
    selectedVillage = null;
    notifyListeners();
  }

  void setVillage(String? value) {
    selectedVillage = value;
    notifyListeners();
  }

  void setFarmerType(String? v) {
    farmerType = v;
    notifyListeners();
  }

  void setBuyerType(String? v) {
    buyerType = v;
    notifyListeners();
  }

  void setRegDetails(String? v) {
    regDetails = v;
    notifyListeners();
  }

  void setVerificationData(
      {required File? front,
      required File? back,
      required String? number,
      required String? name,
      required bool isValid}) {
    aadharFrontImage = front;
    aadharBackImage = back;
    extractedAadharNumber = number;
    verifiedAadharName = name;
    isIdVerified = isValid;
    notifyListeners();
  }

  // ===========================================================================
  // 4. REAL-TIME VALIDATION & DB CHECKS
  // ===========================================================================

  // --- 1. Phone Logic (Regex + DB) ---
  void onPhoneChanged(String value) {
    // 1. Regex Validation
    if (value.isEmpty) {
      phoneError = null;
      phoneDbStatus = null;
      isPhoneTaken = false;
    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      phoneError = "Numbers only";
      phoneDbStatus = null;
    } else if (value.length != 10) {
      phoneError = "Must be 10 digits";
      phoneDbStatus = null;
    } else {
      phoneError = null;
      // 2. Trigger DB Check if Valid
      _debounceCheck(() => _checkPhoneInDb(value));
    }
    notifyListeners();
  }

  Future<void> _checkPhoneInDb(String phone) async {
    phoneDbStatus = "Checking...";
    notifyListeners();
    try {
      final count = await Supabase.instance.client
          .from('profiles')
          .count(CountOption.exact)
          .eq('phone', phone);

      if (count > 0) {
        isPhoneTaken = true;
        phoneDbStatus = "⚠️ This number is already registered.";
      } else {
        isPhoneTaken = false;
        phoneDbStatus = "✅ Number available";
      }
    } catch (e) {
      phoneDbStatus = null; // Quiet fail on network error
    }
    notifyListeners();
  }

  // --- 2. Email Logic (Regex + DB) ---
  void onEmailChanged(String value) {
    if (value.isEmpty) {
      emailError = null;
      emailDbStatus = null;
      isEmailTaken = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      emailError = "Invalid email format";
      emailDbStatus = null;
    } else {
      emailError = null;
      _debounceCheck(() => _checkEmailInDb(value));
    }
    notifyListeners();
  }

  Future<void> _checkEmailInDb(String email) async {
    emailDbStatus = "Checking...";
    notifyListeners();
    try {
      final count = await Supabase.instance.client
          .from('profiles')
          .count(CountOption.exact)
          .eq('email', email);

      if (count > 0) {
        isEmailTaken = true;
        emailDbStatus = "⚠️ Account with this email exists.";
      } else {
        isEmailTaken = false;
        emailDbStatus = "✅ Email available";
      }
    } catch (e) {
      emailDbStatus = null;
    }
    notifyListeners();
  }

  // --- 3. Name Logic (Logical Check + Soft DB Warning) ---
  void onNameChanged() {
    String first = firstNameCtrl.text.trim();
    String middle = middleNameCtrl.text.trim();
    String last = lastNameCtrl.text.trim();

    // Logical Check
    if (first.isNotEmpty && middle.isNotEmpty && last.isNotEmpty) {
      if (first.toLowerCase() == middle.toLowerCase() &&
          middle.toLowerCase() == last.toLowerCase()) {
        nameError = "First, Middle, and Last name cannot be same.";
      } else {
        nameError = null;
        // Trigger Soft DB Check
        _debounceCheck(() => _checkNameInDb(first, middle, last));
      }
    } else {
      nameError = null;
      nameDbWarning = null;
    }
    notifyListeners();
  }

  Future<void> _checkNameInDb(String f, String m, String l) async {
    try {
      final count = await Supabase.instance.client
          .from('profiles')
          .count(CountOption.exact)
          .match({'first_name': f, 'middle_name': m, 'last_name': l});

      if (count > 0) {
        nameDbWarning =
            "ℹ️ An account with this name exists. Please ensure this is not a duplicate.";
      } else {
        nameDbWarning = null;
      }
    } catch (e) {
      nameDbWarning = null;
    }
    notifyListeners();
  }

  // --- Helper: Debouncer ---
  void _debounceCheck(VoidCallback action) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), action); // Wait 800ms
  }

  // --- Password Strength (Same as before) ---
  void checkPasswordStrength(String value) {
    // ... (Keep your existing logic here) ...
    if (value.isEmpty) {
      passwordStrength = "";
      passwordStrengthValue = 0.0;
      passwordStrengthColor = Colors.grey;
    } else {
      bool hasUpper = value.contains(RegExp(r'[A-Z]'));
      bool hasLower = value.contains(RegExp(r'[a-z]'));
      bool hasDigits = value.contains(RegExp(r'[0-9]'));
      bool hasSpecial = value.contains(RegExp(r'[!@#\$&*~]'));
      bool isLong = value.length >= 8;

      if (isLong && hasUpper && hasLower && hasDigits && hasSpecial) {
        passwordStrength = "🟢 Strong";
        passwordStrengthColor = Colors.green;
        passwordStrengthValue = 1.0;
      } else if (value.length >= 6 && hasDigits) {
        passwordStrength = "🟠 Medium";
        passwordStrengthColor = Colors.orange;
        passwordStrengthValue = 0.6;
      } else {
        passwordStrength = "🔴 Weak";
        passwordStrengthColor = Colors.red;
        passwordStrengthValue = 0.3;
      }
    }
    notifyListeners();
  }

  // --- Validate Step 1 Before Next ---
  Future<String?> validateStep1() async {
    if (firstNameCtrl.text.isEmpty || lastNameCtrl.text.isEmpty)
      return "Name required";
    if (phoneError != null) return phoneError;
    if (isPhoneTaken)
      return "Mobile number already registered. Please Login."; // BLOCKER

    if (emailError != null) return emailError;
    if (isEmailTaken)
      return "Email already registered. Please Login."; // BLOCKER

    if (nameError != null) return nameError;
    // nameDbWarning is NOT a blocker, so we don't return it here.

    if (passwordStrength == "🔴 Weak") return "Password is too weak.";
    if (passCtrl.text != confirmPassCtrl.text) return "Passwords do not match";

    return null;
  }

  // ===========================================================================
  // 5. REGISTER (FINAL SUBMIT) - Kept same, but cleaned up
  // ===========================================================================
  Future<void> verifyAndRegister(BuildContext context) async {
    if (!isIdVerified) {
      _showError(context, "⚠️ Please complete ID Verification tab first.");
      return;
    }
    // ... (Rest of logic same as previous, using isPhoneTaken check) ...
    // Since we check duplicate earlier, this part is mostly safeguard.
    _isLoading = true;
    notifyListeners();

    try {
      // ... (Supabase Auth & Insert Logic) ...
      final supabase = Supabase.instance.client;
      final AuthResponse res = await supabase.auth.signUp(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
        data: {'phone': phoneCtrl.text.trim(), 'role': _selectedRole},
      );
      final user = res.user;
      if (user == null) throw "Sign up failed.";

      // Image Upload Logic...
      String? frontUrl;
      String? backUrl;
      final time = DateTime.now().millisecondsSinceEpoch;
      if (aadharFrontImage != null) {
        final path = '${user.id}/front_$time.jpg';
        await supabase.storage
            .from('verification_docs')
            .upload(path, aadharFrontImage!);
        frontUrl =
            supabase.storage.from('verification_docs').getPublicUrl(path);
      }
      if (aadharBackImage != null) {
        final path = '${user.id}/back_$time.jpg';
        await supabase.storage
            .from('verification_docs')
            .upload(path, aadharBackImage!);
        backUrl = supabase.storage.from('verification_docs').getPublicUrl(path);
      }

      // Role Data Compilation...
      Map<String, dynamic> roleData = {};
      if (_selectedRole == 'Farmer') {
        roleData = {
          'type': farmerType,
          'crop_category': cropCategoryCtrl.text,
          'produce_qty': produceQtyCtrl.text,
          'info': extraInfoCtrl.text
        };
      } else if (_selectedRole == 'Inspector') {
        roleData = {
          'occupation': occupationCtrl.text,
          'capacity': capacityCtrl.text,
          'compensation': compensationCtrl.text,
          'ops_level': opsLevelCtrl.text,
          'info': extraInfoCtrl.text
        };
      } else {
        roleData = {
          'type': buyerType,
          'reg_details': regDetails,
          'avg_purchase': avgPurchaseCtrl.text,
          'shop_address': shopAddressCtrl.text
        };
      }

      // DB Insert
      await supabase.from('profiles').insert({
        'id': user.id,
        'first_name': firstNameCtrl.text.trim(),
        'middle_name': middleNameCtrl.text.trim(),
        'last_name': lastNameCtrl.text.trim(),
        'role': _selectedRole,
        'phone': phoneCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'state': selectedState,
        'district': selectedDistrict,
        'taluka': selectedTaluka,
        'village': selectedVillage,
        'pincode': pinCodeCtrl.text.trim(),
        'address_line_1': addressLine1Ctrl.text.trim(),
        'address_line_2': addressLine2Ctrl.text.trim(),
        'extra_field': roleData.toString(),
        'aadhar_number': extractedAadharNumber,
        'aadhar_name': verifiedAadharName,
        'aadhar_front_url': frontUrl,
        'aadhar_back_url': backUrl,
        'verification_status': 'Verified',
      });

      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Account Created! Login now."),
            backgroundColor: Colors.green));
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      _showError(context, "Error: $e");
    }
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }
}
