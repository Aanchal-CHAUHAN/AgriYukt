import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

// ✅ FIX 1: Using a relative import to guarantee it finds the file
import '../../../../widgets/agri_stats_dashboard.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // Farmer Data
  String _name = "Farmer";
  int _cropCount = 0;
  int _orderCount = 0;
  String _earnings = "₹0";
  bool _loading = true;

  // Wallet Privacy
  bool _isEarningsHidden = true;

  // Weather Data
  String _temp = "--";
  String _condition = "Loading...";
  IconData _weatherIcon = Icons.cloud;
  bool _weatherLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRealData();
    _fetchWeather();
  }

  // --- 1. FETCH FARMER DATA ---
  Future<void> _fetchRealData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final client = Supabase.instance.client;

        final profile = await client
            .from('profiles')
            .select('first_name')
            .eq('id', user.id)
            .maybeSingle();

        // ✅ FIX 2: .count() returns an int directly. No need for .count property later.
        final int crops = await client
            .from('crops')
            .count(CountOption.exact)
            .eq('farmer_id', user.id);

        final int orders = await client
            .from('orders')
            .count(CountOption.exact)
            .eq('farmer_id', user.id)
            .eq('status', 'Pending');

        final earningsData = await client
            .from('orders')
            .select('price_offered')
            .eq('farmer_id', user.id)
            .eq('status', 'Completed');

        double total = 0;
        for (var o in earningsData) {
          total += (o['price_offered'] as num).toDouble();
        }

        if (mounted) {
          setState(() {
            _name = profile?['first_name'] ?? "Farmer";
            _cropCount = crops; // ✅ FIX 2: Assign directly
            _orderCount = orders; // ✅ FIX 2: Assign directly
            _earnings = total > 999
                ? "₹${(total / 1000).toStringAsFixed(1)}K"
                : "₹${total.toInt()}";
            _loading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
      if (mounted) setState(() => _loading = false);
    }
  }

  // --- 2. FETCH WEATHER ---
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
      } else {
        await _callWeatherApi(21.1458, 79.0882);
      }
    } catch (e) {
      debugPrint("Weather Error: $e");
      if (mounted) _callWeatherApi(21.1458, 79.0882);
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
    final Color primaryGreen = Colors.green[800]!;
    final Color lightGreen = Colors.green[600]!;

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
                  color: primaryGreen)),
          const SizedBox(height: 15),

          // 2. WEATHER CARD
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primaryGreen, lightGreen]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.green.withOpacity(0.3),
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

          // 3. DASHBOARD STAT CARDS
          const Text("Overview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: _statCard(
                                Icons.grass,
                                "$_cropCount",
                                "Active Crops",
                                Colors.green,
                                Colors.green[50]!)),
                        const SizedBox(width: 15),
                        Expanded(
                            child: _statCard(
                                Icons.shopping_cart,
                                "$_orderCount",
                                "Pending Orders",
                                Colors.orange,
                                Colors.orange[50]!)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(child: _earningsCard()),
                        const SizedBox(width: 15),
                        Expanded(
                            child: _statCard(
                                Icons.trending_up,
                                "High",
                                "Market Demand",
                                Colors.purple,
                                Colors.purple[50]!)),
                      ],
                    ),
                  ],
                ),

          const SizedBox(height: 30),

          // 4. DETAILED ANALYTICS (CHARTS)
          // ✅ FIX 3: Removed 'const' keyword just in case, though the relative import should fix it.
          AgriStatsDashboard(),

          const SizedBox(height: 25),
        ],
      ),
    );
  }

  // --- CUSTOM EARNINGS CARD ---
  Widget _earningsCard() {
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
        border: Border.all(color: Colors.blue[50]!, width: 1),
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
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.currency_rupee,
                    color: Colors.blue, size: 20),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isEarningsHidden = !_isEarningsHidden;
                  });
                },
                child: Icon(
                  _isEarningsHidden ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            _isEarningsHidden ? "••••••" : _earnings,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 5),
          Text("Total Earnings",
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600])),
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
                color: bgColor, borderRadius: BorderRadius.circular(10)),
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
}
