import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Preferred portrait orientation for optimized billing layout
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const CrackersBillingApp());
}

class CrackersBillingApp extends StatelessWidget {
  const CrackersBillingApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Primary festive brand palette (Matches Gopi Crackers Sivakasi Store)
    const primaryColor = Color(0xFF8B1E0F); // Sivakasi Crimson Red
    const primaryDark = Color(0xFF5E0B02); // Deep Rich Crimson
    const accentColor = Color(0xFFD97706); // Flame Gold / Amber
    const scaffoldBg = Color(0xFFFBF8F2); // Warm Festive Cream Sand
    const surfaceCard = Color(0xFFFFFFFF); // Clean Crisp White Cards

    return MaterialApp(
      title: 'Gopi Crackers — Sivakasi Billing System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: scaffoldBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: accentColor,
          surface: surfaceCard,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
            color: Colors.white,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFEAD8C3), width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              letterSpacing: 0.3,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryDark,
            side: const BorderSide(color: Color(0xFFD97706), width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5D5C5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5D5C5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFF6E5E52), fontSize: 14),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFF3ECE0),
          selectedColor: const Color(0xFF8B1E0F),
          disabledColor: Colors.grey.shade200,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
