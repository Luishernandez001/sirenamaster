// ============================================================
// main.dart — Punto de entrada de la aplicación Serenia
// Configura el tema global con Poppins y arranca en WelcomeScreen
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/colors.dart';
import 'views/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Hace la barra de estado transparente para un look más premium
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const SereniaApp());
}

class SereniaApp extends StatelessWidget {
  const SereniaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serenia',
      debugShowCheckedModeBanner: false, // Quita el banner "DEBUG"

      // ── Tema global de la app ──────────────────────────────
      theme: ThemeData(
        // Usa Poppins como fuente base en toda la app
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: AppColors.smokeWhite,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9575CD),
          surface: AppColors.smokeWhite,
        ),
        // Quita el efecto de splash azul por defecto en botones
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        useMaterial3: true,
      ),

      // La app siempre arranca en la pantalla de bienvenida
      home: const WelcomeScreen(),
    );
  }
}
