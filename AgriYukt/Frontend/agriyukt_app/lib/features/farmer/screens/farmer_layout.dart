import 'package:flutter/material.dart';
import 'package:agriyukt_app/features/farmer/screens/home_tab.dart';
import 'package:agriyukt_app/features/farmer/screens/profile_tab.dart';
// ✅ IMPORT THE ORDERS SCREEN
import 'package:agriyukt_app/features/farmer/screens/orders_screen.dart';

class FarmerLayout extends StatefulWidget {
  const FarmerLayout({super.key});

  @override
  State<FarmerLayout> createState() => _FarmerLayoutState();
}

class _FarmerLayoutState extends State<FarmerLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    // ✅ CALL THE CORRECT CLASS NAME
    const FarmerOrdersScreen(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
