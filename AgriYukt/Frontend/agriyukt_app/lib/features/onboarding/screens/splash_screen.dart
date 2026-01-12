import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // 1. Bloom Animation
    _controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo);
    _controller.forward();

    // 2. Init App
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      await Supabase.initialize(
        url: 'https://lyrbnrazuxjilbhdylwt.supabase.co',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx5cmJucmF6dXhqaWxiaGR5bHd0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY1OTE2MDQsImV4cCI6MjA4MjE2NzYwNH0.5HzDWNcNZD5kZw89QNsJFQhnbZwtVx2CMoRzaBZBmHk',
      );
    } catch (e) {
      debugPrint("Supabase Init Error: $e");
    }

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    _checkNavigation();
  }

  Future<void> _checkNavigation() async {
    // ✅ NEW LOGIC: Only check if user is logged in.
    // If NOT logged in -> Always show Language/Onboarding.
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      // User is logged in -> Go to Dashboard
      Navigator.pushReplacementNamed(context, '/farmer-dashboard');
    } else {
      // User is NOT logged in -> Go to Language Selection (Start of Onboarding)
      Navigator.pushReplacementNamed(context, '/language');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                    color: Colors.green.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.agriculture_rounded,
                    size: 80, color: Colors.green),
              ),
              const SizedBox(height: 20),
              const Text("AgriYukt",
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
            ],
          ),
        ),
      ),
    );
  }
}
