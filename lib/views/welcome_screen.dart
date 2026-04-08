// ============================================================
// welcome_screen.dart — Pantalla de bienvenida (splash/onboarding)
// Es la primera pantalla que ve el usuario al abrir la app.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/colors.dart';
import '../widgets/gradient_button.dart';
import '../widgets/decorative_background.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.smokeWhite,
      body: DecorativeBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                // ── Logo ocupa todo el espacio disponible ───────
                Expanded(
                  flex: 5,
                  child: Image.asset(
                    'assets/images/logo_serenia.png',
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 12),

                // ── Subtítulo ───────────────────────────────────
                Text(
                  'Gestión psicopedagógica\ncon claridad y calma',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.textMedium,
                    height: 1.5,
                  ),
                ),

                const Spacer(flex: 1),

                // ── Botón principal ─────────────────────────────
                GradientButton(
                  text: 'Comenzar',
                  icon: Icons.arrow_forward_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),

                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
