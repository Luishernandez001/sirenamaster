// ============================================================
// create_report_screen.dart — Formulario para crear un reporte
// Campos: estudiante, curso, categoría, prioridad, descripción
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/colors.dart';
import '../widgets/gradient_button.dart';
import '../widgets/soft_card.dart';
import '../widgets/decorative_background.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final _studentController = TextEditingController();
  final _listNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _reporterController = TextEditingController();
  DateTime _reportedAt = DateTime.now();

  // Valores de los dropdowns
  String _selectedPriority = 'Media';
  String _selectedCategory = 'Conductual';

  /// Nivel de curso 1–6 (se guarda como 1ro, 2do, … 6to + sección).
  int _courseGrade = 1;
  String _courseSection = 'A';

  // Opciones disponibles
  final List<String> _priorities = ['Alta', 'Media', 'Baja'];
  final List<String> _categories = ['Conductual', 'Académico', 'Emocional', 'Familiar', 'Otro'];

  static const List<String> _gradeWords = ['1ro', '2do', '3ro', '4to', '5to', '6to'];
  static const List<String> _sections = ['A', 'B', 'C', 'D', 'E'];

  static const List<String> _areas = ['Informática', 'Enfermería', 'Finanzas'];
  String _selectedArea = 'Informática';

  String get _composedCourse => '${_gradeWords[_courseGrade - 1]} $_courseSection';

  @override
  void dispose() {
    _studentController.dispose();
    _listNumberController.dispose();
    _descriptionController.dispose();
    _reporterController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    final d = dt;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  void _submitReport() async {
    _reportedAt = DateTime.now();

    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debes iniciar sesión para crear un reporte')));
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    final doc = {
      'datosEstudiante': {
        'nombre': _studentController.text.trim(),
        'curso': _composedCourse,
        'numeroLista': int.tryParse(_listNumberController.text.trim()),
        'area': _selectedArea,
      },
      'autor': {
        'uid': user.uid,
        'nombre': _reporterController.text.trim(),
      },
      'fechaHora': Timestamp.fromDate(_reportedAt.toUtc()),
      'clasificacion': {
        'categoria': _selectedCategory,
        'prioridad': _selectedPriority,
      },
      'descripcion': _descriptionController.text.trim(),
    };

    try {
      await FirebaseFirestore.instance.collection('reportes').add(doc);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.mintGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Color(0xFF43A047), size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                '¡Reporte creado!',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              Text(
                'El reporte de ${_studentController.text} fue registrado exitosamente.\n${_formatDateTime(_reportedAt)}',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMedium),
              ),
              const SizedBox(height: 20),
              GradientButton(
                text: 'Aceptar',
                height: 48,
                onTap: () {
                  Navigator.pop(context); // cierra diálogo
                  Navigator.pop(context); // vuelve al home
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error guardando reporte: $e')));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.smokeWhite,
      body: DecorativeBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Tooltip(
                      message: 'Volver al inicio',
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: AppColors.softShadow,
                            ),
                            child: Icon(Icons.home_rounded, color: AppColors.textDark, size: 24),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── Sección: Datos del estudiante ────────
                        _SectionTitle(title: 'Datos del estudiante', icon: Icons.person_outline_rounded),
                        const SizedBox(height: 12),

                        SoftCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _FormField(
                                controller: _studentController,
                                label: 'Nombre del estudiante',
                                hint: 'Ej: Valentina Torres',
                                icon: Icons.person_outline_rounded,
                                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.class_outlined, color: AppColors.textLight, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Curso',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textMedium,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Nivel (1 a 6) y sección (A a E)',
                                          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textLight),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Nivel',
                                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMedium),
                                        ),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: List.generate(6, (i) {
                                            final n = i + 1;
                                            final selected = _courseGrade == n;
                                            return GestureDetector(
                                              onTap: () => setState(() => _courseGrade = n),
                                              child: AnimatedContainer(
                                                duration: const Duration(milliseconds: 150),
                                                width: 44,
                                                height: 40,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  gradient: selected ? AppColors.primaryGradient : null,
                                                  color: selected ? null : AppColors.smokeWhite,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: selected ? Colors.transparent : const Color(0xFFEEEEEE),
                                                  ),
                                                ),
                                                child: Text(
                                                  '$n',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: selected ? Colors.white : AppColors.textDark,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Sección',
                                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMedium),
                                        ),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: _sections.map((s) {
                                            final selected = _courseSection == s;
                                            return GestureDetector(
                                              onTap: () => setState(() => _courseSection = s),
                                              child: AnimatedContainer(
                                                duration: const Duration(milliseconds: 150),
                                                width: 44,
                                                height: 40,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  gradient: selected ? AppColors.primaryGradient : null,
                                                  color: selected ? null : AppColors.smokeWhite,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: selected ? Colors.transparent : const Color(0xFFEEEEEE),
                                                  ),
                                                ),
                                                child: Text(
                                                  s,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: selected ? Colors.white : AppColors.textDark,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Nº de lista del estudiante (1-50)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nº de lista',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textMedium,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _listNumberController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(2),
                                    ],
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Campo requerido';
                                      final n = int.tryParse(v);
                                      if (n == null) return 'Ingrese un número válido';
                                      if (n < 1 || n > 50) return 'Ingrese un número entre 1 y 50';
                                      return null;
                                    },
                                    style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
                                    decoration: InputDecoration(
                                      hintText: 'Ej: 12',
                                      hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight),
                                      prefixIcon: Icon(Icons.format_list_numbered, color: AppColors.textLight, size: 18),
                                      filled: true,
                                      fillColor: AppColors.smokeWhite,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFB39DDB), width: 1.5),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFEF9A9A)),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFEF9A9A), width: 1.5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.domain_outlined, color: AppColors.textLight, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Área',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _areas.map((a) {
                                      final selected = _selectedArea == a;
                                      return GestureDetector(
                                        onTap: () => setState(() => _selectedArea = a),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 150),
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                          decoration: BoxDecoration(
                                            gradient: selected ? AppColors.primaryGradient : null,
                                            color: selected ? null : AppColors.smokeWhite,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: selected ? Colors.transparent : const Color(0xFFEEEEEE),
                                            ),
                                          ),
                                          child: Text(
                                            a,
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: selected ? Colors.white : AppColors.textDark,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _FormField(
                                controller: _reporterController,
                                label: 'Reportado por',
                                hint: 'Ej: Prof. Martínez',
                                icon: Icons.badge_outlined,
                                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                              ),
                              const SizedBox(height: 16),
                              // Fecha y hora del reporte (auto)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Fecha y hora',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textMedium,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    initialValue: _formatDateTime(_reportedAt),
                                    readOnly: true,
                                    style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.access_time_outlined, color: AppColors.textLight, size: 18),
                                      filled: true,
                                      fillColor: AppColors.smokeWhite,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFB39DDB), width: 1.5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Sección: Clasificación ───────────────
                        _SectionTitle(title: 'Clasificación', icon: Icons.label_outline_rounded),
                        const SizedBox(height: 12),

                        SoftCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Selector de categoría
                              _buildLabel('Categoría'),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _categories.map((cat) {
                                  final isSelected = cat == _selectedCategory;
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedCategory = cat),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        gradient: isSelected ? AppColors.primaryGradient : null,
                                        color: isSelected ? null : AppColors.smokeWhite,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected ? Colors.transparent : const Color(0xFFEEEEEE),
                                        ),
                                      ),
                                      child: Text(
                                        cat,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected ? Colors.white : AppColors.textMedium,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 16),

                              // Selector de prioridad
                              _buildLabel('Prioridad'),
                              const SizedBox(height: 8),
                              Row(
                                children: _priorities.map((p) {
                                  final isSelected = p == _selectedPriority;
                                  Color bgColor;
                                  Color textColor;
                                  switch (p) {
                                    case 'Alta':
                                      bgColor = AppColors.priorityHigh;
                                      textColor = AppColors.priorityHighText;
                                      break;
                                    case 'Media':
                                      bgColor = AppColors.priorityMedium;
                                      textColor = AppColors.priorityMediumText;
                                      break;
                                    default:
                                      bgColor = AppColors.priorityLow;
                                      textColor = AppColors.priorityLowText;
                                  }
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _selectedPriority = p),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 150),
                                        margin: const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                          color: isSelected ? bgColor : AppColors.smokeWhite,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected ? textColor.withValues(alpha: 0.3) : const Color(0xFFEEEEEE),
                                            width: isSelected ? 2 : 1,
                                          ),
                                        ),
                                        child: Text(
                                          p,
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                            color: isSelected ? textColor : AppColors.textMedium,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Sección: Descripción ─────────────────
                        _SectionTitle(title: 'Descripción del incidente', icon: Icons.description_outlined),
                        const SizedBox(height: 12),

                        SoftCard(
                          padding: const EdgeInsets.all(16),
                          child: TextFormField(
                            controller: _descriptionController,
                            maxLines: 5,
                            validator: (v) => v!.isEmpty ? 'Describe el incidente' : null,
                            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
                            decoration: InputDecoration(
                              hintText: 'Describe detalladamente la situación observada...',
                              hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight),
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ── Botón de envío ───────────────────────
                        GradientButton(
                          text: 'Guardar Reporte',
                          icon: Icons.save_rounded,
                          onTap: _submitReport,
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}

// ── Widget: título de sección ─────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF9575CD)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

// ── Widget: campo de formulario reutilizable ──────────────────
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textMedium,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight),
            prefixIcon: Icon(icon, color: AppColors.textLight, size: 18),
            filled: true,
            fillColor: AppColors.smokeWhite,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFB39DDB), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF9A9A)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF9A9A), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
