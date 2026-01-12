import 'package:flutter/material.dart';
import '../widgets/buyer_drawer.dart'; // Ensure this widget exists
import 'buyer_home_screen.dart';
import 'buyer_marketplace_screen.dart';
import 'buyer_profile_screen.dart';
import 'buyer_orders_screen.dart';
import 'buyer_cart_screen.dart';

class BuyerDashboard extends StatefulWidget {
  const BuyerDashboard({super.key});

  @override
  State<BuyerDashboard> createState() => _BuyerDashboardState();
}

class _BuyerDashboardState extends State<BuyerDashboard> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ✅ TAB ORDER: Home(0), Market(1), Orders(2), Profile(3)
  final List<Widget> _screens = [
    const BuyerHomeScreen(),
    const BuyerMarketplaceScreen(),
    const BuyerOrdersScreen(), // Make sure this screen is created
    const BuyerProfileScreen(),
  ];

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: BuyerDrawer(onTabChange: _onTabChange),
      appBar: AppBar(
        backgroundColor: Colors.blue[800], // Distinct Blue for Buyer
        elevation: 0,
        centerTitle: true,
        // ✅ LEFT: Hamburger Menu
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          "AgriYukt ",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        // ✅ RIGHT: Cart & Notification Icons
        actions: [
          // 🛒 Cart Button -> Opens Cart Screen
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BuyerCartScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Notification Logic placeholder
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No new notifications")),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ✅ BODY SWITCHER
      body: _screens[_currentIndex],

      // ✅ BOTTOM NAVIGATION
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabChange,
        backgroundColor: Colors.white,
        elevation: 3,
        indicatorColor: Colors.blue.shade100, // Matching Buyer Theme
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF1565C0)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront, color: Color(0xFF1565C0)),
            label: 'Market',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: Color(0xFF1565C0)),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF1565C0)),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
