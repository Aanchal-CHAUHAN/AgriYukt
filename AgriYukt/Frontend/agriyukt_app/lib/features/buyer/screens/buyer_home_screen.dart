import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  // Profile Data
  String _name = "Buyer";
  bool _loading = true;

  // Weather Variables
  String _temp = "--";
  String _condition = "Loading...";
  IconData _weatherIcon = Icons.cloud;
  bool _weatherLoading = false;

  // Dashboard Stats (Real-time counts)
  int _activeOrders = 0;
  int _pendingOrders = 0;
  int _freshListingsToday = 0;

  // Wallet Logic
  double _walletAmount = 12500.00; // Replace with DB value later
  bool _isWalletHidden = true; // Default to hidden

  // Fresh Arrivals List
  List<Map<String, dynamic>> _freshCrops = [];

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    _fetchWeather();
    _fetchDashboardStats();
    _fetchFreshArrivalsList();
  }

  // --- 1. FETCH PROFILE ---
  Future<void> _fetchProfileData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('first_name')
          .eq('id', user.id)
          .maybeSingle();

      if (mounted && data != null) {
        setState(() {
          _name = data['first_name'] ?? "Buyer";
          _loading = false;
        });
      }
    }
  }

  // --- 2. FETCH DASHBOARD STATS (REAL COUNTS) ---
  Future<void> _fetchDashboardStats() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final client = Supabase.instance.client;

      // 1. Pending Orders Count
      final pendingCount = await client
          .from('orders')
          .count(CountOption.exact)
          .eq('buyer_id', user.id)
          .eq('status', 'pending');

      // 2. Active Orders Count (Accepted/In-Transit)
      final activeCount = await client
          .from('orders')
          .count(CountOption.exact)
          .eq('buyer_id', user.id)
          .inFilter('status', ['accepted', 'in_transit', 'processing']);

      // 3. Fresh Listings Count (Global - Created Today)
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      final freshCount = await client
          .from('crops')
          .count(CountOption.exact)
          .gte('created_at', todayStr);

      if (mounted) {
        setState(() {
          _pendingOrders = pendingCount;
          _activeOrders = activeCount;
          _freshListingsToday = freshCount;
        });
      }
    } catch (e) {
      debugPrint("Stats Fetch Error: $e");
    }
  }

  // --- 3. FETCH WEATHER ---
  Future<void> _fetchWeather() async {
    if (_weatherLoading) return;
    setState(() => _weatherLoading = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 5));

        await _callWeatherApi(position.latitude, position.longitude);
      }
    } catch (e) {
      debugPrint("Weather Error: $e");
      if (mounted) _callWeatherApi(21.1458, 79.0882); // Fallback
    } finally {
      if (mounted) setState(() => _weatherLoading = false);
    }
  }

  Future<void> _callWeatherApi(double lat, double long) async {
    try {
      final url = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$long&current_weather=true');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current_weather'];
        final code = current['weathercode'];

        if (mounted) {
          setState(() {
            _temp = "${current['temperature'].round()}°C";
            _condition = _getWeatherCondition(code);
            _weatherIcon = _getWeatherIcon(code);
          });
        }
      }
    } catch (e) {
      debugPrint("API Error: $e");
    }
  }

  // --- 4. FETCH FRESH ARRIVALS LIST ---
  Future<void> _fetchFreshArrivalsList() async {
    try {
      final response = await Supabase.instance.client
          .from('crops')
          .select('name, price_per_kg, image_url, created_at')
          .order('created_at', ascending: false)
          .limit(5);

      if (mounted) {
        setState(() {
          _freshCrops = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      debugPrint("Error fetching crops: $e");
    }
  }

  // --- HELPERS ---
  String _getWeatherCondition(int code) {
    if (code == 0) return "Clear Sky";
    if (code >= 1 && code <= 3) return "Partly Cloudy";
    if (code >= 45 && code <= 48) return "Foggy";
    if (code >= 51 && code <= 67) return "Rainy";
    if (code >= 95) return "Thunderstorm";
    return "Sunny";
  }

  IconData _getWeatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny;
    if (code >= 1 && code <= 3) return Icons.cloud;
    if (code >= 51 && code <= 67) return Icons.water_drop;
    if (code >= 95) return Icons.thunderstorm;
    return Icons.wb_sunny;
  }

  // --- UI BUILD ---
  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = Colors.blue[800]!;
    final Color lightBlue = Colors.blue[600]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. GREETING
          Text("Namaste, $_name 🙏",
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue)),

          const SizedBox(height: 15),

          // 2. WEATHER CARD
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primaryBlue, lightBlue]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text("Today's Weather",
                            style: TextStyle(color: Colors.white70)),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _fetchWeather,
                          child: _weatherLoading
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.refresh,
                                  color: Colors.white70, size: 16),
                        )
                      ],
                    ),
                    Text(_temp,
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Row(
                      children: [
                        Icon(_weatherIcon, color: Colors.white, size: 16),
                        const SizedBox(width: 5),
                        Text(_condition,
                            style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ],
                ),
                Icon(_weatherIcon, size: 50, color: Colors.yellowAccent),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // 3. DASHBOARD TITLE
          const Text("Dashboard",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // 4. STATS GRID (2x2)
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            Icons.local_shipping,
                            "$_activeOrders",
                            "Active Orders",
                            Colors.green,
                            Colors.green[50]!,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _statCard(
                            Icons.hourglass_top,
                            "$_pendingOrders",
                            "Pending Orders",
                            Colors.orange,
                            Colors.orange[50]!,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        // WALLET CARD (With Hide Feature)
                        Expanded(
                          child: _walletCard(),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _statCard(
                            Icons.new_releases,
                            "$_freshListingsToday",
                            "New Listings",
                            Colors.blue,
                            Colors.blue[50]!,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

          const SizedBox(height: 25),

          // 5. FRESH ARRIVALS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Fresh Arrivals 🌾",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("See All",
                  style: TextStyle(
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ],
          ),
          const SizedBox(height: 15),

          if (_freshCrops.isEmpty)
            const Text("No crops available right now.",
                style: TextStyle(color: Colors.grey))
          else
            SizedBox(
              height: 210,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _freshCrops.length,
                itemBuilder: (context, index) {
                  final crop = _freshCrops[index];
                  final date = DateTime.parse(crop['created_at']);
                  final diff = DateTime.now().difference(date);
                  String timeLabel =
                      diff.inHours < 24 ? "Today" : "${diff.inDays}d ago";

                  return _freshCropCard(
                    crop['name'] ?? "Unknown",
                    "₹${crop['price_per_kg']}/kg",
                    timeLabel,
                    crop['image_url'] ?? "",
                  );
                },
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- CUSTOM WALLET CARD ---
  Widget _walletCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2))
        ],
        border: Border.all(color: Colors.purple[50]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance_wallet,
                    color: Colors.purple, size: 20),
              ),
              // Eye Toggle Icon
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isWalletHidden = !_isWalletHidden;
                  });
                },
                child: Icon(
                  _isWalletHidden ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            _isWalletHidden ? "••••••" : "₹${_walletAmount.toStringAsFixed(0)}",
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 5),
          const Text(
            "Wallet Balance",
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.purple),
          ),
        ],
      ),
    );
  }

  // --- STANDARD STAT CARD ---
  Widget _statCard(
      IconData icon, String val, String label, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2))
        ],
        border: Border.all(color: bgColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 15),
          Text(val,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _freshCropCard(String name, String price, String time, String imgUrl) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 15, bottom: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: imgUrl.isNotEmpty
                    ? Image.network(imgUrl,
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                            height: 110,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image)))
                    : Container(height: 110, color: Colors.grey[200]),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(time,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 5),
                Text(price,
                    style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
