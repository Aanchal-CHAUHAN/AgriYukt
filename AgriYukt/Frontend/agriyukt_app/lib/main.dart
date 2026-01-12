import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- CONTROLLERS ---
<<<<<<< HEAD
import 'package:agriyukt_app/features/auth/controllers/login_controller.dart';
import 'package:agriyukt_app/features/onboarding/onboarding_controller.dart';

// --- SCREENS ---
import 'package:agriyukt_app/features/onboarding/screens/splash_screen.dart';
import 'package:agriyukt_app/features/onboarding/screens/language_screen.dart';
import 'package:agriyukt_app/features/onboarding/screens/onboarding_screen.dart';
import 'package:agriyukt_app/features/auth/screens/login_screen.dart';
import 'package:agriyukt_app/features/auth/screens/forgot_password_screen.dart';
import 'package:agriyukt_app/features/auth/screens/registration/create_account/create_account_screen.dart';

// --- DASHBOARDS ---
import 'package:agriyukt_app/features/farmer/screens/farmer_layout.dart';
import 'package:agriyukt_app/features/buyer/screens/buyer_dashboard.dart';

// ✅ CRITICAL IMPORT: This file MUST exist at this path
import 'package:agriyukt_app/features/inspector/screens/inspector_layout.dart';
=======
import 'features/auth/controllers/login_controller.dart';
import 'features/onboarding/onboarding_controller.dart';

// --- SCREENS ---
import 'features/onboarding/screens/splash_screen.dart';
import 'features/onboarding/screens/language_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/screens/registration/create_account/create_account_screen.dart';

// --- DASHBOARDS ---
import 'features/farmer/screens/farmer_layout.dart';
import 'features/buyer/screens/buyer_dashboard.dart';
import 'features/inspector/screens/inspector_layout.dart';
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lyrbnrazuxjilbhdylwt.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx5cmJucmF6dXhqaWxiaGR5bHd0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY1OTE2MDQsImV4cCI6MjA4MjE2NzYwNH0.5HzDWNcNZD5kZw89QNsJFQhnbZwtVx2CMoRzaBZBmHk',
  );

  runApp(const AgriYuktApp());
}

class AgriYuktApp extends StatelessWidget {
  const AgriYuktApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginController()),
        ChangeNotifierProvider(create: (_) => OnboardingController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AgriYukt',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
        ),
        routes: {
          // Auth
          '/splash': (context) => const SplashScreen(),
          '/language': (context) => const LanguageScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/create-account': (context) => const CreateAccountScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),

          // Dashboards
          '/farmer': (context) => const FarmerLayout(),
          '/buyer': (context) => const BuyerDashboard(),
<<<<<<< HEAD

          // ✅ FIX: No 'const' keyword here
          '/inspector': (context) => InspectorLayout(),
=======
          '/inspector': (context) => const InspectorLayout(),
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
        },
        home: const SplashHandler(),
      ),
    );
  }
}

class SplashHandler extends StatefulWidget {
  const SplashHandler({super.key});

  @override
  State<SplashHandler> createState() => _SplashHandlerState();
}

class _SplashHandlerState extends State<SplashHandler> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showSplash ? const SplashScreen() : const AuthGate();
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        final session = snapshot.data?.session;
        if (session == null) return const LanguageScreen();

        return FutureBuilder<Map<String, dynamic>?>(
          future: _fetchUserProfile(session.user.id),
          builder: (context, profileSnap) {
            if (profileSnap.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            final role =
                profileSnap.data?['role']?.toString().toLowerCase().trim() ??
                    'farmer';

            if (role == 'buyer') return const BuyerDashboard();
<<<<<<< HEAD

            // ✅ FIX: No 'const' keyword here
            if (role == 'inspector') return InspectorLayout();

=======
            if (role == 'inspector') return const InspectorLayout();
>>>>>>> bc72846f2c5f4dcf81485a3b078c6b0f7c73a416
            return const FarmerLayout();
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _fetchUserProfile(String userId) async {
    try {
      return await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
    } catch (e) {
      return null;
    }
  }
}
