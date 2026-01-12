import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class InspectorHomeTab extends StatefulWidget {
  const InspectorHomeTab({super.key});

  @override
  State<InspectorHomeTab> createState() => _InspectorHomeTabState();
}

class _InspectorHomeTabState extends State<InspectorHomeTab> {
  // Inspector Data
  String _name = "Inspector"; // Default fallback
  int _assignedFarmers = 0;
  int _pendingOrders = 0;
  int _activeOrders = 0;
  int _totalCropsManaged = 0;
  bool _loading = true;

  // Weather Data
  String _temp = "--";
  String _condition = "Loading...";
  IconData _weatherIcon = Icons.cloud;
  bool _weatherLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchInspectorStats();
    _fetchWeather();
  }

  // --- 1. FETCH INSPECTOR STATS (FIXED NAME LOGIC) ---
  Future<void> _fetchInspectorStats() async {
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;

      if (user != null) {
        debugPrint("🔍 Fetching data for User ID: ${user.id}");

        // A. Fetch Profile Name
        final profile = await client
            .from('profiles')
            .select('first_name')
            .eq('id', user.id)
            .maybeSingle();

        debugPrint("👤 Profile Data: $profile");

        // B. Fetch Crops Managed (Fix for UUID/Int types)
        final myCropsData = await client
            .from('crops')
            .select('id, farmer_id')
            .eq('inspector_id', user.id);

        // Convert to List
        List<dynamic> myCrops = myCropsData as List<dynamic>;

        // 🔴 CRITICAL FIX: Removed 'as int'. This allows String UUIDs or Int IDs safely.
        List<dynamic> myCropIds = myCrops.map((c) => c['id']).toList();

        Set<String> uniqueFarmers =
            myCrops.map((c) => c['farmer_id'].toString()).toSet();

        // C. Get Orders
        int pending = 0;
        int active = 0;

        if (myCropIds.isNotEmpty) {
          final ordersData = await client
              .from('orders')
              .select('status')
              .inFilter('crop_id', myCropIds);

          for (var o in ordersData) {
            String status = (o['status'] ?? '').toString().toLowerCase();
            if (status == 'pending') {
              pending++;
            } else if (status == 'accepted' ||
                status == 'in_transit' ||
                status == 'processing') {
              active++;
            }
          }
        }

        if (mounted) {
          setState(() {
            // ✅ ROBUST NAME LOGIC
            // Checks if profile exists AND first_name is not empty
            if (profile != null &&
                profile['first_name'] != null &&
                profile['first_name'].toString().trim().isNotEmpty) {
              _name = profile['first_name'];
            } else {
              _name = "Inspector";
            }

            _assignedFarmers = uniqueFarmers.length;
            _totalCropsManaged = myCrops.length;
            _pendingOrders = pending;
            _activeOrders = active;
            _loading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("❌ Inspector Stats Error: $e");
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
      }
    } catch (e) {
      if (mounted) _callWeatherApi(21.1458, 79.0882); // Fallback to Nagpur
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
    // 🎨 Theme Colors (Inspector Orange)
    final Color primaryColor = Colors.orange[800]!;
    final Color lightColor = Colors.orange[600]!;

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
                  color: primaryColor)),

          const SizedBox(height: 15),

          // 2. WEATHER CARD
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primaryColor, lightColor]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
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

          // 3. DASHBOARD
          const Text("Dashboard",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // 4. STATS GRID
          _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.orange))
              : GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  // ✅ FIX: 1.1 ensures content fits without overflow
                  childAspectRatio: 1.1,

                  children: [
                    _statCard(Icons.people, "$_assignedFarmers",
                        "Total Farmers", Colors.green, Colors.green[50]!),
                    _statCard(Icons.pending_actions, "$_pendingOrders",
                        "Pending Orders", Colors.orange, Colors.orange[50]!),
                    _statCard(Icons.local_shipping, "$_activeOrders",
                        "Active Orders", Colors.blue, Colors.blue[50]!),
                    _statCard(Icons.grass, "$_totalCropsManaged",
                        "Crops Managed", Colors.purple, Colors.purple[50]!),
                  ],
                ),

          const SizedBox(height: 25),
        ],
      ),
    );
  }

  // --- STAT CARD WIDGET ---
  Widget _statCard(
      IconData icon, String val, String label, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(12),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          // ✅ FIX: FittedBox prevents text overflow
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(val,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
          ),
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
