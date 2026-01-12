import 'package:flutter/material.dart';
import 'package:agriyukt_app/core/services/farm_service.dart';

class AddFarmScreen extends StatefulWidget {
  const AddFarmScreen({super.key});

  @override
  State<AddFarmScreen> createState() => _AddFarmScreenState();
}

class _AddFarmScreenState extends State<AddFarmScreen> {
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cropCtrl = TextEditingController();
  bool _isLoading = false;

  void _saveFarm() async {
    if (_nameCtrl.text.isEmpty || _addressCtrl.text.isEmpty) return;

    setState(() => _isLoading = true);

    // Call Service
    bool success = await FarmService().addFarm(
      _nameCtrl.text.trim(),
      _addressCtrl.text.trim(),
      _cropCtrl.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true); // Return 'true' to refresh list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Farm Added Successfully!"),
            backgroundColor: Colors.green),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Failed to add farm."), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Farm")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                  labelText: "Farm Name (e.g. Green Valley)",
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressCtrl,
              decoration: const InputDecoration(
                  labelText: "Location/Village", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cropCtrl,
              decoration: const InputDecoration(
                  labelText: "Primary Crop (e.g. Wheat)",
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveFarm,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: const Text("SAVE FARM",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
