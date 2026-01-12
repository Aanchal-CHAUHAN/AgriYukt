import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ CORRECTED IMPORT
import 'package:agriyukt_app/features/buyer/screens/farm_details_screen.dart';

class NearbyFarmsMap extends StatefulWidget {
  const NearbyFarmsMap({super.key});

  @override
  State<NearbyFarmsMap> createState() => _NearbyFarmsMapState();
}

class _NearbyFarmsMapState extends State<NearbyFarmsMap> {
  // ... (Your map state logic remains same, just ensure imports are correct) ...
  // Keep your existing _loadFarms() logic here.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nearby Farms")),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(28.6139, 77.2090),
          zoom: 10,
        ),
        // markers: ... your markers logic
      ),
    );
  }
}
