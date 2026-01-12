import 'package:flutter/material.dart';

// ✅ SCREEN IMPORTS
// We use InspectorHomeTab for the dashboard since it has the weather and stats logic you provided
import 'package:agriyukt_app/features/inspector/screens/inspector_home_tab.dart';
import 'package:agriyukt_app/features/inspector/screens/inspector_add_crop_tab.dart';
import 'package:agriyukt_app/features/inspector/screens/inspector_orders_tab.dart';
import 'package:agriyukt_app/features/inspector/screens/inspector_profile_tab.dart';

// ✅ DRAWER IMPORT
import 'package:agriyukt_app/features/inspector/widgets/inspector_drawer.dart';

class InspectorLayout extends StatefulWidget {
  const InspectorLayout({super.key});

  @override
  State<InspectorLayout> createState() => _InspectorLayoutState();
}

class _InspectorLayoutState extends State<InspectorLayout> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ✅ The 4 Functional Tabs
  final List<Widget> _screens = [
    const InspectorHomeTab(), // 0: Dashboard (Weather + Stats)
    const InspectorAddCropTab(), // 1: Add Crop
    const InspectorOrdersTab(), // 2: Orders
    const InspectorProfileTab(), // 3: Profile
  ];

  void _switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      // ✅ Sidebar Drawer
      drawer: InspectorDrawer(onItemSelected: _switchTab),

      appBar: AppBar(
        backgroundColor: const Color(0xFFE65100), // Inspector Orange
        elevation: 0,
        centerTitle: true,

        // Hamburger Icon
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),

        title: const Text(
          "AgriYukt",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.white),
            onPressed: () {
              // Notification logic
            },
          ),
          const SizedBox(width: 12),
        ],
      ),

      // ✅ Maintains state of tabs so they don't reload on switch
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _switchTab,
        backgroundColor: Colors.white,
        indicatorColor: Colors.orange.shade100,
        destinations: const [
          // 1. Dashboard
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard, color: Color(0xFFE65100)),
              label: 'Dashboard'),

          // 2. Add Crop
          NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle,
                  color: Color.fromARGB(255, 237, 119, 56)),
              label: 'Add Crop'),

          // 3. Orders
          NavigationDestination(
              icon: Icon(Icons.shopping_bag_outlined),
              selectedIcon: Icon(Icons.shopping_bag, color: Color(0xFFE65100)),
              label: 'Orders'),

          // 4. Profile
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: Color(0xFFE65100)),
              label: 'Profile'),
        ],
      ),
    );
  }
}
