import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agriyukt_app/core/services/location_service.dart';
import 'package:agriyukt_app/features/onboarding/onboarding_controller.dart';
import 'create_account_controller.dart';
import 'tabs/verification_tab.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateAccountController(),
      child: const _CreateAccountContent(),
    );
  }
}

class _CreateAccountContent extends StatefulWidget {
  const _CreateAccountContent();

  @override
  State<_CreateAccountContent> createState() => _CreateAccountContentState();
}

class _CreateAccountContentState extends State<_CreateAccountContent> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _obscurePass = true;
  bool _obscureConfirmPass = true;

  List<LocalizedItem> _stateList = [];
  List<LocalizedItem> _districtList = [];
  List<LocalizedItem> _talukaList = [];
  List<LocalizedItem> _villageList = [];

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

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<CreateAccountController>(context);
    final langCode =
        Provider.of<OnboardingController>(context).selectedLanguage;
    final isMarathi = langCode == 'mr';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7), // Light grey background
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. Header ---
            _buildHeader(context),

            // --- 2. Content ---
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                children: [
                  _buildStep1_RoleAndPersonal(ctrl, isMarathi),
                  _buildStep2_ProfessionalAndLocation(ctrl, isMarathi),
                  VerificationTab(controller: ctrl),
                ],
              ),
            ),

            // --- 3. Bottom Nav ---
            _buildBottomNav(ctrl, isMarathi, context),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 🎨 UI COMPONENTS
  // ===========================================================================

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => _currentPage > 0
                    ? _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut)
                    : Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.arrow_back_ios_new,
                      size: 24, color: Colors.black87),
                ),
              ),
              const SizedBox(width: 10),
              const Text("Create Account",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _stepCircle(1, "Personal", _currentPage >= 0),
              _stepLine(_currentPage >= 1),
              _stepCircle(2, "Details", _currentPage >= 1),
              _stepLine(_currentPage >= 2),
              _stepCircle(3, "Verify", _currentPage >= 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepCircle(int step, String label, bool isActive) {
    return Column(
      // Changed back to Column for better readability
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFF2E7D32) : Colors.grey.shade300,
          ),
          child: Center(
            child: isActive
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : Text("$step",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
                fontSize: 13,
                color: isActive ? Colors.black87 : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal))
      ],
    );
  }

  Widget _stepLine(bool isActive) {
    return Container(
      width: 30,
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
      color: isActive ? const Color(0xFF2E7D32) : Colors.grey.shade300,
    );
  }

  Widget _buildBottomNav(
      CreateAccountController ctrl, bool isMarathi, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5))
      ]),
      child: SizedBox(
        width: double.infinity, height: 55, // Taller button
        child: ElevatedButton(
          onPressed: ctrl.isLoading
              ? null
              : () async {
                  if (_currentPage < 2) {
                    if (_currentPage == 0) {
                      String? error = await ctrl.validateStep1();
                      if (error != null) {
                        _showSnack(error, Colors.red);
                        return;
                      }
                    }
                    if (_currentPage == 1 && ctrl.selectedDistrict == null) {
                      _showSnack("Please select District", Colors.red);
                      return;
                    }
                    _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  } else {
                    await ctrl.verifyAndRegister(context);
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
          ),
          child: ctrl.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : Text(
                  _currentPage == 2
                      ? (isMarathi ? 'खाते तयार करा' : 'Create Account')
                      : (isMarathi ? 'पुढे' : 'Next'),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
        ),
      ),
    );
  }

  // ===========================================================================
  // PAGE 1
  // ===========================================================================
  Widget _buildStep1_RoleAndPersonal(
      CreateAccountController ctrl, bool isMarathi) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Who are you?"),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                  child: _roleCard(ctrl, 'Farmer',
                      isMarathi ? 'शेतकरी' : 'Farmer', Icons.agriculture)),
              const SizedBox(width: 10),
              Expanded(
                  child: _roleCard(ctrl, 'Buyer',
                      isMarathi ? 'खरेदीदार' : 'Buyer', Icons.shopping_cart)),
              const SizedBox(width: 10),
              Expanded(
                  child: _roleCard(
                      ctrl,
                      'Inspector',
                      isMarathi ? 'निरीक्षक' : 'Inspector',
                      Icons.verified_user)),
            ],
          ),
          const SizedBox(height: 30),
          _sectionTitle("Personal Info"),
          const SizedBox(height: 15),
          _txt(ctrl.firstNameCtrl, "First Name", Icons.person,
              onChanged: (v) => ctrl.onNameChanged()),
          _txt(ctrl.middleNameCtrl, "Middle Name", Icons.person_outline,
              onChanged: (v) => ctrl.onNameChanged()),
          _txt(ctrl.lastNameCtrl, "Last Name", Icons.person,
              onChanged: (v) => ctrl.onNameChanged(),
              errorText: ctrl.nameError,
              statusText: ctrl.nameDbWarning),
          _txt(ctrl.phoneCtrl, "Mobile Number", Icons.phone,
              type: TextInputType.phone,
              onChanged: (v) => ctrl.onPhoneChanged(v),
              errorText: ctrl.phoneError,
              statusText: ctrl.phoneDbStatus,
              showLoginLink: ctrl.isPhoneTaken),
          _txt(ctrl.emailCtrl, "Email Address", Icons.email,
              type: TextInputType.emailAddress,
              onChanged: (v) => ctrl.onEmailChanged(v),
              errorText: ctrl.emailError,
              statusText: ctrl.emailDbStatus,
              showLoginLink: ctrl.isEmailTaken),
          _txt(ctrl.passCtrl, "Password", Icons.lock,
              isPass: true,
              obscureText: _obscurePass,
              onTogglePass: () => setState(() => _obscurePass = !_obscurePass),
              onChanged: (v) => ctrl.checkPasswordStrength(v)),
          if (ctrl.passCtrl.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 15, left: 5, right: 5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                    value: ctrl.passwordStrengthValue,
                    color: ctrl.passwordStrengthColor,
                    backgroundColor: Colors.grey.shade300,
                    minHeight: 6),
              ),
            ),
          _txt(ctrl.confirmPassCtrl, "Confirm Password", Icons.lock_clock,
              isPass: true,
              obscureText: _obscureConfirmPass,
              onTogglePass: () =>
                  setState(() => _obscureConfirmPass = !_obscureConfirmPass)),
        ],
      ),
    );
  }

  // ===========================================================================
  // PAGE 2
  // ===========================================================================
  Widget _buildStep2_ProfessionalAndLocation(
      CreateAccountController ctrl, bool isMarathi) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("${ctrl.selectedRole} Details"),
          const SizedBox(height: 15),
          if (ctrl.selectedRole == 'Farmer') ...[
            _simpleDD(
                "Type",
                ctrl.farmerType,
                ['Individual', 'Family', 'FPO', 'Tenant'],
                (v) => ctrl.setFarmerType(v),
                Icons.person_pin),
            _simpleDD(
                "Crop",
                ctrl.cropCategoryCtrl.text.isEmpty
                    ? null
                    : ctrl.cropCategoryCtrl.text,
                ['Vegetables', 'Fruits', 'Grains', 'Cash Crops'],
                (v) => ctrl.cropCategoryCtrl.text = v!,
                Icons.grass),
            _simpleDD(
                "Qty (Quintals)",
                ctrl.produceQtyCtrl.text.isEmpty
                    ? null
                    : ctrl.produceQtyCtrl.text,
                ['< 10', '10 - 50', '50 - 100', '> 100'],
                (v) => ctrl.produceQtyCtrl.text = v!,
                Icons.production_quantity_limits),
            _txt(ctrl.extraInfoCtrl, "Extra Info (Opt)", Icons.note_add),
          ],
          if (ctrl.selectedRole == 'Inspector') ...[
            _simpleDD(
                "Occupation",
                ctrl.occupationCtrl.text.isEmpty
                    ? null
                    : ctrl.occupationCtrl.text,
                ['Student', 'Govt Job', 'NGO', 'Full-Time'],
                (v) => ctrl.occupationCtrl.text = v!,
                Icons.work),
            _simpleDD(
                "Capacity",
                ctrl.capacityCtrl.text.isEmpty ? null : ctrl.capacityCtrl.text,
                ['1-10', '11-20', '21-40', '40+'],
                (v) => ctrl.capacityCtrl.text = v!,
                Icons.people),
            _simpleDD(
                "Compensation",
                ctrl.compensationCtrl.text.isEmpty
                    ? null
                    : ctrl.compensationCtrl.text,
                ['Per Inspection', '10k-20k/mo', '20k+/mo'],
                (v) => ctrl.compensationCtrl.text = v!,
                Icons.currency_rupee),
            _simpleDD(
                "Level",
                ctrl.opsLevelCtrl.text.isEmpty ? null : ctrl.opsLevelCtrl.text,
                ['Village', 'Taluka', 'District'],
                (v) => ctrl.opsLevelCtrl.text = v!,
                Icons.map),
          ],
          if (ctrl.selectedRole == 'Buyer') ...[
            _simpleDD(
                "Type",
                ctrl.buyerType,
                ['Retailer', 'Wholesaler', 'Trader', 'Exporter'],
                (v) => ctrl.setBuyerType(v),
                Icons.shopping_bag),
            _simpleDD(
                "Reg. Type",
                ctrl.regDetails,
                ['GST', 'MSME', 'Cooperative', 'None'],
                (v) => ctrl.setRegDetails(v),
                Icons.app_registration),
            _simpleDD(
                "Purchase/Day",
                ctrl.avgPurchaseCtrl.text.isEmpty
                    ? null
                    : ctrl.avgPurchaseCtrl.text,
                ['< 5 Q', '5-20 Q', '20-50 Q', '50+ Q'],
                (v) => ctrl.avgPurchaseCtrl.text = v!,
                Icons.shopping_cart_checkout),
            _txt(ctrl.shopAddressCtrl, "Shop Address", Icons.store),
          ],
          const SizedBox(height: 30),
          _sectionTitle("Location"),
          const SizedBox(height: 15),
          _locDD(isMarathi ? 'राज्य' : 'State', ctrl.selectedState, _stateList,
              isMarathi, (val) {
            ctrl.setState(val);
            setState(() {
              _districtList = LocationService.getDistricts(val!);
              _talukaList = [];
              _villageList = [];
            });
          }, Icons.map),
          _locDD(isMarathi ? 'जिल्हा' : 'District', ctrl.selectedDistrict,
              _districtList, isMarathi, (val) {
            ctrl.setDistrict(val);
            setState(() {
              _talukaList =
                  LocationService.getTalukas(ctrl.selectedState!, val!);
              _villageList = [];
            });
          }, Icons.location_city),
          _locDD(isMarathi ? 'तालुका' : 'Taluka', ctrl.selectedTaluka,
              _talukaList, isMarathi, (val) {
            ctrl.setTaluka(val);
            setState(() {
              _villageList = LocationService.getVillages(
                  ctrl.selectedState!, ctrl.selectedDistrict!, val!);
            });
          }, Icons.place),
          _locDD(
              isMarathi ? 'गाव' : 'Village',
              ctrl.selectedVillage,
              _villageList,
              isMarathi,
              (val) => ctrl.setVillage(val),
              Icons.home_filled),
          const SizedBox(height: 15),
          _txt(ctrl.addressLine1Ctrl, "Address Line 1", Icons.home),
          _txt(ctrl.addressLine2Ctrl, "Address Line 2", Icons.home_work),
          _txt(ctrl.pinCodeCtrl, "Pincode", Icons.pin_drop,
              type: TextInputType.number),
        ],
      ),
    );
  }

  // ===========================================================================
  // 📏 BIGGER & BOLDER WIDGETS
  // ===========================================================================

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1B5E20)));
  }

  // ✨ Larger Role Card
  Widget _roleCard(
      CreateAccountController ctrl, String key, String label, IconData icon) {
    bool isSelected = ctrl.selectedRole == key;
    return GestureDetector(
      onTap: () => ctrl.selectRole(key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
              width: 2),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey,
                size: 28),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? const Color(0xFF1B5E20)
                        : Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  // ✨ Larger Input Field
  Widget _txt(TextEditingController c, String l, IconData i,
      {TextInputType type = TextInputType.text,
      bool isPass = false,
      bool obscureText = false,
      VoidCallback? onTogglePass,
      String? hint,
      Function(String)? onChanged,
      String? errorText,
      String? statusText,
      bool showLoginLink = false}) {
    Color statusColor = Colors.grey;
    if (statusText != null) {
      if (statusText.contains("✅")) statusColor = Colors.green;
      if (statusText.contains("⚠️")) statusColor = Colors.orange.shade800;
      if (statusText.contains("Checking")) statusColor = Colors.blue;
      if (statusText.contains("ℹ️")) statusColor = Colors.blue;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ]),
            child: TextField(
              controller: c, keyboardType: type,
              obscureText: isPass ? obscureText : false, onChanged: onChanged,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500), // Bigger input text
              decoration: InputDecoration(
                labelText: l,
                labelStyle: TextStyle(
                    color: Colors.grey.shade600, fontSize: 15), // Bigger label
                hintText: hint,
                prefixIcon: Icon(i, color: const Color(0xFF2E7D32), size: 24),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: isPass
                    ? IconButton(
                        icon: Icon(
                            obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 24,
                            color: Colors.grey),
                        onPressed: onTogglePass)
                    : null,
              ),
            ),
          ),
          if (errorText != null)
            Padding(
                padding: const EdgeInsets.only(top: 6, left: 10),
                child: Text(errorText,
                    style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.bold))),
          if (statusText != null && errorText == null)
            Padding(
                padding: const EdgeInsets.only(top: 6, left: 10),
                child: Text(statusText,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold))),
          if (showLoginLink)
            Padding(
                padding: const EdgeInsets.only(left: 6),
                child: TextButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (route) => false),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 24),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: const Text("Login here",
                        style: TextStyle(
                            color: Color(0xFF1565C0),
                            fontSize: 14,
                            decoration: TextDecoration.underline)))),
        ],
      ),
    );
  }

  // ✨ Larger Dropdown
  Widget _simpleDD(String l, String? v, List<String> items,
      Function(String?) ch, IconData i) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ]),
        child: DropdownButtonFormField<String>(
          value: v,
          items: items
              .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 16))))
              .toList(),
          onChanged: ch,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 24),
          decoration: InputDecoration(
              labelText: l,
              labelStyle: const TextStyle(fontSize: 15),
              prefixIcon: Icon(i, color: const Color(0xFF2E7D32), size: 24),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
        ),
      ),
    );
  }

  Widget _locDD(String l, String? v, List<LocalizedItem> items, bool isMr,
      Function(String?) ch, IconData i) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ]),
        child: DropdownButtonFormField<String>(
          value: v,
          items: items
              .map((e) => DropdownMenuItem(
                  value: e.id,
                  child: Text(e.getName(isMr),
                      style: const TextStyle(fontSize: 16))))
              .toList(),
          onChanged: ch,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 24),
          decoration: InputDecoration(
              labelText: l,
              labelStyle: const TextStyle(fontSize: 15),
              prefixIcon: Icon(i, color: const Color(0xFF2E7D32), size: 24),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
        ),
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(fontSize: 15)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
  }

  String _getTitle(int page) {
    return page == 0
        ? "Create Account"
        : page == 1
            ? "Role Details"
            : "Verification";
  }
}
