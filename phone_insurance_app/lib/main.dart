import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/topup_screen.dart';
import 'screens/policy/device_selection_screen.dart';
import 'screens/claim/select_policy_screen.dart';
import 'screens/claim/claim_history_screen.dart';
import 'screens/wallet/wallet_history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_stores_screen.dart';
import 'screens/admin/admin_users_screen.dart';
import 'screens/admin/admin_policies_screen.dart';
import 'screens/admin/admin_claims_screen.dart';
import 'screens/admin/admin_store_detail_screen.dart';
import 'screens/admin/admin_devices_screen.dart';
import 'screens/admin/admin_tiers_screen.dart';
import 'screens/admin/admin_analytics_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  final role = prefs.getString('user_role') ?? 'customer';
  
  // Jika ada token, langsung ke dashboard sesuai role. Jika tidak, ke login.
  String initialRoute = '/';
  if (token != null && token.isNotEmpty) {
    bool isAdmin = (role == 'super_admin' || role == 'store_admin');
    initialRoute = isAdmin ? '/admin-dashboard' : '/dashboard';
  }
  
  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smile by SPC',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const LoginScreen(), 
        '/register': (context) => const RegisterScreen(), 
        '/dashboard': (context) => const DashboardScreen(),
        // '/topup': (context) => const TopUpScreen(), // DISABLED - Admin only
        // '/device-selection': (context) => const DeviceSelectionScreen(), // DISABLED - Admin creates policies
        '/select-policy': (context) => const SelectPolicyScreen(),
        '/claim-history': (context) => const ClaimHistoryScreen(),
        '/wallet-history': (context) => const WalletHistoryScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        '/admin-stores': (context) => const AdminStoresScreen(),
        '/admin-users': (context) => const AdminUsersScreen(),
        '/admin-policies': (context) => const AdminPoliciesScreen(),
        '/admin-claims': (context) => const AdminClaimsScreen(),
        '/admin-devices': (context) => const AdminDevicesScreen(),
        '/admin-tiers': (context) => const AdminTiersScreen(),
        '/admin-analytics': (context) => const AdminAnalyticsScreen(),
        '/admin-store-detail': (context) {
          final store = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return AdminStoreDetailScreen(store: store);
        },
      },
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5E35B1),
        primary: const Color(0xFF5E35B1),
        secondary: const Color(0xFFFF6F00),
        brightness: Brightness.light,
      ),
      
      // Typography dengan Google Fonts
      textTheme: GoogleFonts.interTextTheme(),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: const Color(0xFF5E35B1),
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      
      // ElevatedButton Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // InputDecoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5E35B1), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // FloatingActionButton Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(0xFF5E35B1),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}