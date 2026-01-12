import 'package:flutter/material.dart';

class SupportChatScreen extends StatefulWidget {
  final String role; // 'farmer', 'buyer', or 'inspector'

  const SupportChatScreen({super.key, required this.role});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Message Structure: {text, isUser, time}
  final List<Map<String, dynamic>> _messages = [];

  // State to track if language is selected
  String? _selectedLanguage; // 'en', 'hi', 'mr'
  List<String> _currentOptions = [];

  @override
  void initState() {
    super.initState();
    // 1. Start by asking for language
    _askLanguage();
  }

  void _askLanguage() {
    setState(() {
      _messages.add({
        "text":
            "Namaste! 🙏\nPlease select your language.\n\nकृपया अपनी भाषा चुनें.\n\nकृपया आपली भाषा निवडा.",
        "isUser": false,
        "time": _getTime()
      });
      _currentOptions = ["English", "हिंदी", "मराठी"];
    });
  }

  void _handleOptionClick(String option) {
    _addMessage(option, true); // Show user selection

    if (_selectedLanguage == null) {
      // 2. Handle Language Selection
      _setLanguageAndStart(option);
    } else {
      // 3. Handle Normal FAQ
      _simulateBotResponse(option);
    }
  }

  void _setLanguageAndStart(String language) async {
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      if (language == "हिंदी") {
        _selectedLanguage = 'hi';
        _addMessage(
            "नमस्ते! मैं एग्रीबॉट हूँ। 🤖\nआज मैं आपकी कैसे मदद कर सकता हूँ?",
            false);
      } else if (language == "मराठी") {
        _selectedLanguage = 'mr';
        _addMessage(
            "नमस्कार! मी ॲग्रीबॉट आहे. 🤖\nआज मी तुम्हाला कशी मदत करू शकतो?",
            false);
      } else {
        _selectedLanguage = 'en';
        _addMessage(
            "Hello! I am AgriBot 🤖.\nHow can I help you today?", false);
      }

      // Load FAQs based on Role & Language
      _loadFaqs();
    });
  }

  void _loadFaqs() {
    final role = widget.role.toLowerCase();

    if (_selectedLanguage == 'hi') {
      // --- HINDI ---
      if (role == 'farmer') {
        _currentOptions = [
          "फसल कैसे जोड़ें?",
          "भुगतान नहीं मिला",
          "सत्यापन स्थिति",
          "एजेंट से बात करें"
        ];
      } else if (role == 'buyer') {
        _currentOptions = [
          "मेरा ऑर्डर ट्रैक करें",
          "रिफंड पॉलिसी",
          "गुणवत्ता समस्या",
          "एजेंट से बात करें"
        ];
      } else {
        _currentOptions = [
          "फसल सत्यापित करें",
          "सिंक समस्या",
          "प्रोफाइल अपडेट",
          "एजेंट से बात करें"
        ];
      }
    } else if (_selectedLanguage == 'mr') {
      // --- MARATHI ---
      if (role == 'farmer') {
        _currentOptions = [
          "पीक कसे जोडावे?",
          "पैसे मिळाले नाहीत",
          "पडताळणी स्थिती",
          "एजंटशी बोला"
        ];
      } else if (role == 'buyer') {
        _currentOptions = [
          "ऑर्डर ट्रॅक करा",
          "परतावा धोरण",
          "गुणवत्ता समस्या",
          "एजंटशी बोला"
        ];
      } else {
        _currentOptions = [
          "पीक पडताळणी",
          "सिंक समस्या",
          "प्रोफाइल अपडेट",
          "एजंटशी बोला"
        ];
      }
    } else {
      // --- ENGLISH (Default) ---
      if (role == 'farmer') {
        _currentOptions = [
          "How to add crop?",
          "Payment Issue",
          "Verification Status",
          "Contact Agent"
        ];
      } else if (role == 'buyer') {
        _currentOptions = [
          "Track Order",
          "Refund Policy",
          "Quality Issue",
          "Contact Agent"
        ];
      } else {
        _currentOptions = [
          "Verify Crop",
          "Sync Issue",
          "Update Profile",
          "Contact Agent"
        ];
      }
    }
  }

  void _simulateBotResponse(String question) async {
    await Future.delayed(const Duration(seconds: 1));

    String reply = "";

    // Simple Keyword Matching (Works for all languages roughly)
    if (question.contains("add crop") ||
        question.contains("फसल") ||
        question.contains("पीक")) {
      reply = _selectedLanguage == 'hi'
          ? "फसल जोड़ने के लिए: 'मेरी फसलें' टैब पर जाएं -> '+ फसल जोड़ें' पर क्लिक करें।"
          : _selectedLanguage == 'mr'
              ? "पीक जोडण्यासाठी: 'माझी पिके' टॅबवर जा -> '+ पीक जोडा' वर क्लिक करा."
              : "To add a crop: Go to 'My Crops' tab -> Click '+ Add Crop'.";
    } else if (question.contains("Payment") ||
        question.contains("भुगतान") ||
        question.contains("पैसे")) {
      reply = _selectedLanguage == 'hi'
          ? "भुगतान 24 घंटे के भीतर संसाधित किया जाता है। कृपया अपना वॉलेट जांचें।"
          : _selectedLanguage == 'mr'
              ? "पैसे 24 तासांच्या आत जमा केले जातात. कृपया आपले वॉलेट तपासा."
              : "Payments are processed within 24 hours. Please check your Wallet.";
    } else if (question.contains("Verification") ||
        question.contains("सत्यापन") ||
        question.contains("पडताळणी")) {
      reply = _selectedLanguage == 'hi'
          ? "सत्यापन में 24-48 घंटे लगते हैं। सुनिश्चित करें कि आधार फोटो साफ है।"
          : _selectedLanguage == 'mr'
              ? "पडताळणीसाठी 24-48 तास लागतात. आधार फोटो स्पष्ट असल्याची खात्री करा."
              : "Verification takes 24-48 hours. Ensure your Aadhar photo is clear.";
    } else if (question.contains("Agent") ||
        question.contains("एजेंट") ||
        question.contains("एजंट")) {
      reply = _selectedLanguage == 'hi'
          ? "आपको एक मानव एजेंट से जोड़ रहा हूँ... 📞"
          : _selectedLanguage == 'mr'
              ? "तुम्हाला एजंटशी जोडत आहे... 📞"
              : "Connecting you to a human agent... 📞";
    } else if (question.contains("Quality") || question.contains("गुणवत्ता")) {
      reply = "For quality disputes, please raise a ticket in 'My Orders'.";
    } else {
      reply = _selectedLanguage == 'hi'
          ? "क्षमा करें, मुझे समझ नहीं आया। कृपया एजेंट से संपर्क करें।"
          : _selectedLanguage == 'mr'
              ? "क्षमस्व, मला समजले नाही. कृपया एजंटशी संपर्क साधा."
              : "I didn't understand that. Please contact support.";
    }

    _addMessage(reply, false);
  }

  void _sendMessage() {
    if (_msgController.text.trim().isEmpty) return;
    if (_selectedLanguage == null)
      return; // Prevent typing before language select

    String text = _msgController.text.trim();
    _addMessage(text, true);
    _msgController.clear();
    _simulateBotResponse(text);
  }

  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.add({"text": text, "isUser": isUser, "time": _getTime()});
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getTime() {
    final now = DateTime.now();
    return "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              // ✅ CORRECTED ICON: Removed 'quality_control', used 'smart_toy'
              child: Icon(Icons.smart_toy, size: 20, color: Colors.green),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("AgriBot", style: TextStyle(fontSize: 16)),
                Text("Online",
                    style: TextStyle(fontSize: 12, color: Colors.greenAccent)),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      // ✅ Added SafeArea to prevent overlaps
      body: SafeArea(
        child: Column(
          children: [
            // 1. CHAT MESSAGES
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildChatBubble(
                      msg['text'], msg['isUser'], msg['time']);
                },
              ),
            ),

            // 2. OPTIONS CHIPS
            if (_currentOptions.isNotEmpty)
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _currentOptions.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ActionChip(
                        label: Text(_currentOptions[index]),
                        backgroundColor: Colors.green.shade50,
                        labelStyle: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                                color: Colors.green.withOpacity(0.3))),
                        onPressed: () =>
                            _handleOptionClick(_currentOptions[index]),
                      ),
                    );
                  },
                ),
              ),

            // 3. INPUT FIELD
            Container(
              padding: const EdgeInsets.all(10),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      enabled: _selectedLanguage != null,
                      decoration: InputDecoration(
                        hintText: _selectedLanguage == null
                            ? "Select language above..."
                            : "Type a message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: _selectedLanguage == null
                        ? Colors.grey
                        : Colors.green[700],
                    child: IconButton(
                      icon:
                          const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser, String time) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Colors.green[600] : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: isUser ? Colors.white70 : Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
