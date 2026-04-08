// ============================================================
// login_screen.dart — Pantalla de inicio de sesión
// Formulario con campos de email y contraseña estilo Soft-UI
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/colors.dart';
import '../widgets/gradient_button.dart';
import '../widgets/decorative_background.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para leer el texto de los campos
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Controla si la contraseña es visible o no
  bool _obscurePassword = true;

  // Clave para validar el formulario
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Libera memoria al salir de la pantalla
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Función que se ejecuta al presionar "Ingresar"
  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      // En una app real aquí iría la lógica de autenticación
      // Por ahora navegamos directo al Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.smokeWhite,
      body: DecorativeBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            // SingleChildScrollView evita overflow cuando aparece el teclado
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // ── Botón de regreso ──────────────────────────
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppColors.softShadow,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Ilustración de login ──────────────────────
                  Center(
                    child: Image.asset(
                      'assets/images/login_illustration.png',
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Encabezado ────────────────────────────────
                  Text(
                    'Bienvenido\nde vuelta 👋',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ingresa tus credenciales para continuar',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textMedium,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Campo Email ───────────────────────────────
                  _buildLabel('Correo electrónico'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _emailController,
                    hint: 'orientador@colegio.cl',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Ingresa tu correo';
                      if (!v.contains('@')) return 'Correo inválido';
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // ── Campo Contraseña ──────────────────────────
                  _buildLabel('Contraseña'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _passwordController,
                    hint: '••••••••',
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    // Botón para mostrar/ocultar contraseña
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textLight,
                        size: 20,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                      if (v.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  // ── Olvidé mi contraseña ──────────────────────
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF9575CD),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Botón de ingreso ──────────────────────────
                  GradientButton(
                    text: 'Ingresar',
                    onTap: _handleLogin,
                  ),

                  const SizedBox(height: 24),

                  // ── Divisor ───────────────────────────────────
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'o continúa con',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Botón Google (visual, sin funcionalidad) ──
                  GestureDetector(
                    onTap: _handleLogin, // En producción: implementar Google Sign-In
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppColors.softShadow,
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.g_mobiledata_rounded, size: 28, color: Color(0xFFEA4335)),
                          const SizedBox(width: 8),
                          Text(
                            'Continuar con Google',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Helper: etiqueta de campo ─────────────────────────────
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    );
  }

  // ── Helper: campo de texto estilizado ────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: AppColors.textDark,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.textLight,
        ),
        prefixIcon: Icon(icon, color: AppColors.textLight, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFB39DDB), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEF9A9A)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEF9A9A), width: 2),
        ),
      ),
    );
  }
}
