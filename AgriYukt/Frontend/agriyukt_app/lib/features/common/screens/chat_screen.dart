import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String orderId;
<<<<<<< HEAD
  final String targetUserId;
  final String targetName;
  final String cropName;
  final String orderStatus;

  const ChatScreen({
    super.key,
    required this.targetUserId,
    required this.targetName,
    required this.orderId,
    required this.cropName,
    required this.orderStatus,
=======
  final String orderStatus;
  final String cropName;
  final String? cropImage; // URL if available
  final dynamic cropId; // ID to fetch image if URL is missing
  final String otherUserName;
  final String currentUserRole; // 'farmer', 'buyer'

  const ChatScreen({
    super.key,
    required this.orderId,
    required this.orderStatus,
    required this.cropName,
    this.cropImage,
    this.cropId,
    required this.otherUserName,
    required this.currentUserRole,
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
<<<<<<< HEAD
  final _supabase = Supabase.instance.client;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  // 🛡️ SECURITY: REGEX PATTERNS
  final RegExp _phoneRegex = RegExp(r'(\d\W*){10,}');
  final RegExp _emailRegex =
      RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');

  // 💬 PREDEFINED QUICK REPLIES (Safe & Fast)
  final List<String> _quickReplies = [
    "Is the crop ready?",
    "When can I pick up?",
    "Please confirm the order.",
    "The quality looks good.",
    "I have made the payment.",
    "Crop is harvested.",
    "Location is correct.",
    "Running slightly late.",
    "Order Delivered."
  ];

  @override
  Widget build(BuildContext context) {
    final myId = _supabase.auth.currentUser!.id;

    return Scaffold(
      backgroundColor: const Color(0xFFE5DDD5),
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: const Color(0xFF075E54),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                  widget.targetName.isNotEmpty ? widget.targetName[0] : '?',
                  style: const TextStyle(color: Color(0xFF075E54))),
            ),
            const SizedBox(width: 10),
=======
  final _client = Supabase.instance.client;
  final ScrollController _scrollController = ScrollController();

  Future<void> _sendMessage(String text, {String type = 'text'}) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      await _client.from('chat_messages').insert({
        'order_id': widget.orderId,
        'sender_id': user.id,
        'sender_role': widget.currentUserRole,
        'message_content': text,
        'message_type': type, // 'text', 'system'
      });
      _scrollToBottom();
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ STRICT RULES: Context-Aware Options
    final List<String> options =
        ChatLogic.getOptions(widget.currentUserRole, widget.orderStatus);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leadingWidth: 40,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // ✅ EXACT CROP IMAGE IN HEADER
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 40,
                width: 40,
                child: _ChatHeaderImage(
                    cropId: widget.cropId, imageUrl: widget.cropImage),
              ),
            ),
            const SizedBox(width: 12),
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
<<<<<<< HEAD
                  Text(widget.targetName, style: const TextStyle(fontSize: 16)),
                  Text(
                    "${widget.cropName} • ${widget.orderStatus}",
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
=======
                  Row(
                    children: [
                      // ✅ REAL NAME + VERIFIED BADGE
                      Flexible(
                          child: Text(widget.otherUserName,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, color: Colors.blue, size: 16),
                    ],
                  ),
                  Text("Order #${widget.orderId} • ${widget.cropName}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
<<<<<<< HEAD
          // 1. MESSAGES LIST
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _supabase
=======
          // --- MESSAGES STREAM ---
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _client
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
                  .from('chat_messages')
                  .stream(primaryKey: ['id'])
                  .eq('order_id', widget.orderId)
                  .order('created_at', ascending: true),
              builder: (context, snapshot) {
<<<<<<< HEAD
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;

                // Auto-scroll
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController
                        .jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });

                if (messages.isEmpty) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 5)
                          ]),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.security, size: 40, color: Colors.green),
                          SizedBox(height: 10),
                          Text(
                            "Safe Chat",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "For your safety, sharing phone numbers or emails is disabled. Use the Quick Replies below.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
=======
                if (!snapshot.hasData)
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.green));

                final messages = snapshot.data!;
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());

                // ✅ AUTO-SYSTEM MESSAGES (Visual Mock if empty)
                if (messages.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: const [
                      _SystemEventCard(
                          icon: Icons.receipt_long, text: "Order Created"),
                      // ✅ FIXED: Changed calendar_clock to schedule
                      _SystemEventCard(
                          icon: Icons.schedule,
                          text: "Pickup Slot Requested by Buyer"),
                    ],
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
<<<<<<< HEAD
                  padding: const EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['sender_id'] == myId;
                    final time = DateFormat('hh:mm a')
                        .format(DateTime.parse(msg['created_at']).toLocal());

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                            color:
                                isMe ? const Color(0xFFDCF8C6) : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: isMe
                                  ? const Radius.circular(12)
                                  : Radius.zero,
                              bottomRight: isMe
                                  ? Radius.zero
                                  : const Radius.circular(12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1))
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(msg['message_content'],
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(time,
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey[600])),
                          ],
                        ),
                      ),
=======
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe =
                        msg['sender_id'] == _client.auth.currentUser?.id;
                    final role = msg['sender_role'];

                    // ✅ VISUAL SEPARATION: System vs User
                    if (role == 'system') {
                      return _SystemEventCard(
                          icon: Icons.info_outline,
                          text: msg['message_content']);
                    }

                    return _ChatBubble(
                      text: msg['message_content'],
                      isMe: isMe,
                      role: role,
                      time: msg['created_at'],
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
                    );
                  },
                );
              },
            ),
          ),

<<<<<<< HEAD
          // 2. QUICK REPLIES (Horizontal Scroll)
          Container(
            height: 50,
            color: const Color(0xFFE5DDD5),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: _quickReplies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return ActionChip(
                  label: Text(_quickReplies[index]),
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  labelStyle:
                      const TextStyle(color: Color(0xFF075E54), fontSize: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.green.shade100)),
                  onPressed: () =>
                      _sendMessage(overrideText: _quickReplies[index]),
                );
              },
            ),
          ),

          // 3. INPUT AREA
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF075E54),
                  radius: 24,
                  child: IconButton(
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: () => _sendMessage(),
                  ),
=======
          // --- ✅ LOGISTICS ACTION PANEL (NO KEYBOARD) ---
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5))
              ],
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "QUICK ACTIONS (${widget.orderStatus.toUpperCase()})",
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                      letterSpacing: 1),
                ),
                const SizedBox(height: 12),

                // ACTION CHIPS
                Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  children: options.map((option) {
                    return InkWell(
                      onTap: () => _sendMessage(option),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: widget.currentUserRole == 'farmer'
                              ? Colors.green[50]
                              : Colors.blue[50],
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: widget.currentUserRole == 'farmer'
                                  ? Colors.green[200]!
                                  : Colors.blue[200]!),
                        ),
                        child: Text(
                          option,
                          style: TextStyle(
                            color: widget.currentUserRole == 'farmer'
                                ? Colors.green[800]
                                : Colors.blue[800],
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
<<<<<<< HEAD

  // 🛡️ SMART SEND LOGIC
  Future<void> _sendMessage({String? overrideText}) async {
    final text = overrideText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    // 🛑 1. CHECK FOR PHONE NUMBERS
    if (_phoneRegex.hasMatch(text)) {
      _showSecurityWarning(
          "⚠️ Phone numbers are not allowed. Please use the Quick Replies.");
      return;
    }

    // 🛑 2. CHECK FOR EMAILS
    if (_emailRegex.hasMatch(text)) {
      _showSecurityWarning("⚠️ Email addresses are not allowed.");
      return;
    }

    setState(() => _isSending = true);

    try {
      final myId = _supabase.auth.currentUser!.id;

      await _supabase.from('chat_messages').insert({
        'order_id': widget.orderId,
        'sender_id': myId,
        'sender_role': 'user',
        'message_content': text,
        'created_at': DateTime.now().toIso8601String(),
      });

      _messageController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showSecurityWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.lock, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ]),
        backgroundColor: Colors.red[800],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
=======
}

// --- VISUAL COMPONENTS ---

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String role;
  final String? time;

  const _ChatBubble(
      {required this.text, required this.isMe, required this.role, this.time});

  @override
  Widget build(BuildContext context) {
    Color roleColor = role == 'buyer'
        ? Colors.blue
        : (role == 'inspector' ? Colors.orange : Colors.green);
    String displayTime = time != null
        ? DateFormat('hh:mm a').format(DateTime.parse(time!).toLocal())
        : "";

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? roleColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isMe ? roleColor.withOpacity(0.2) : Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(role.toUpperCase(),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: roleColor)),
              ),
            Text(text,
                style: const TextStyle(
                    fontSize: 15, color: Colors.black87, height: 1.3)),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(displayTime,
                  style: TextStyle(fontSize: 10, color: Colors.grey[500])),
            )
          ],
        ),
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
      ),
    );
  }
}
<<<<<<< HEAD
=======

class _SystemEventCard extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SystemEventCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(text,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700])),
        ],
      ),
    );
  }
}

class _ChatHeaderImage extends StatelessWidget {
  final dynamic cropId;
  final String? imageUrl;
  const _ChatHeaderImage({this.cropId, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty)
      return Image.network(imageUrl!, fit: BoxFit.cover);
    if (cropId != null) {
      return FutureBuilder<Map<String, dynamic>?>(
        future: Supabase.instance.client
            .from('crops')
            .select('image_url')
            .eq('id', cropId)
            .maybeSingle(),
        builder: (ctx, snap) {
          if (snap.hasData && snap.data != null) {
            String? url = snap.data!['image_url'];
            if (url != null && !url.startsWith('http')) {
              url = Supabase.instance.client.storage
                  .from('crops')
                  .getPublicUrl(url);
            }
            if (url != null) return Image.network(url, fit: BoxFit.cover);
          }
          return Container(
              color: Colors.green[100],
              child: const Icon(Icons.grass, color: Colors.green));
        },
      );
    }
    return Container(
        color: Colors.green[100],
        child: const Icon(Icons.grass, color: Colors.green));
  }
}

// --- CHAT LOGIC (Strict) ---
class ChatLogic {
  static List<String> getOptions(String role, String status) {
    final s = status.toLowerCase();

    // FARMER / INSPECTOR PRESETS
    if (role == 'farmer' || role == 'inspector') {
      if (s == 'completed')
        return ["Thank you for the business! 🤝", "Please rate the buyer."];
      if (s == 'ready')
        return ["Waiting for arrival ⏳", "Please call if lost 📞"];

      // Default Active State
      return [
        "Slot Confirmed ✅",
        "Crop is harvested & ready 📦",
        "Please arrive on time 🕘",
        "Need to reschedule? 📅"
      ];
    }

    // BUYER PRESETS
    if (role == 'buyer') {
      if (s == 'completed') return ["Order received perfectly ✅", "Thank you!"];

      return [
        "Confirming my slot 🗓️",
        "I will arrive today 🚛",
        "I am on the way 📍",
        "Reached location 🏁",
        "Please keep order ready 📦"
      ];
    }
    return [];
  }
}
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
