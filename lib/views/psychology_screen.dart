// ============================================================
// psychology_screen.dart — Seguimiento psicológico
// Muestra una línea de tiempo con la evolución del estudiante
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/colors.dart';
import '../widgets/soft_card.dart';
import '../widgets/decorative_background.dart';

// Modelo simple para un evento en la línea de tiempo
class _TimelineEvent {
  final String date;
  final String title;
  final String description;
  final String type; // 'session', 'report', 'improvement', 'alert'

  const _TimelineEvent({
    required this.date,
    required this.title,
    required this.description,
    required this.type,
  });
}

class PsychologyScreen extends StatefulWidget {
  const PsychologyScreen({super.key});

  @override
  State<PsychologyScreen> createState() => _PsychologyScreenState();
}

class _PsychologyScreenState extends State<PsychologyScreen> {
  // Estudiante seleccionado actualmente
  int _selectedStudent = 0;

  // Lista de estudiantes en seguimiento
  final List<Map<String, String>> _students = [
    {'name': 'Valentina Torres', 'course': '3° Básico A', 'sessions': '6'},
    {'name': 'Mateo Rodríguez', 'course': '5° Básico B', 'sessions': '3'},
    {'name': 'Sofía Herrera', 'course': '2° Medio C', 'sessions': '4'},
  ];

  // Eventos de la línea de tiempo para Valentina (ejemplo)
  final List<_TimelineEvent> _timeline = [
    _TimelineEvent(
      date: '28 Mar 2026',
      title: 'Sesión individual',
      description: 'Se trabajó regulación emocional con técnicas de respiración. Buena disposición.',
      type: 'session',
    ),
    _TimelineEvent(
      date: '21 Mar 2026',
      title: 'Mejora observada',
      description: 'Profesora reporta menor conflictividad en recreos. Avance positivo.',
      type: 'improvement',
    ),
    _TimelineEvent(
      date: '14 Mar 2026',
      title: 'Reunión con apoderado',
      description: 'Se coordinó plan de trabajo conjunto con la madre. Comprometida con el proceso.',
      type: 'session',
    ),
    _TimelineEvent(
      date: '7 Mar 2026',
      title: 'Alerta conductual',
      description: 'Incidente en clases de matemáticas. Se derivó a orientación de urgencia.',
      type: 'alert',
    ),
    _TimelineEvent(
      date: '28 Feb 2026',
      title: 'Primera sesión',
      description: 'Evaluación inicial. Se identificaron dificultades en habilidades sociales.',
      type: 'session',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DecorativeBackground(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Encabezado ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Psicología',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'Seguimiento psicopedagógico',
                    style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMedium),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Selector de estudiante (scroll horizontal) ───
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _students.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final student = _students[i];
                  final isSelected = i == _selectedStudent;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedStudent = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 160,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.primaryGradient : null,
                        color: isSelected ? null : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isSelected ? AppColors.cardShadow : AppColors.softShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            student['name']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            student['course']!,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: isSelected ? Colors.white70 : AppColors.textMedium,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${student['sessions']} sesiones',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white70 : AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ── Tarjeta de resumen del estudiante ────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SoftCard(
                color: AppColors.mintGreen,
                padding: const EdgeInsets.all(16),
                shadow: AppColors.softShadow,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estado actual',
                            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMedium),
                          ),
                          Text(
                            'En seguimiento activo',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatPill(label: 'Sesiones', value: _students[_selectedStudent]['sessions']!),
                    const SizedBox(width: 8),
                    _StatPill(label: 'Semanas', value: '5'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Título de la línea de tiempo ─────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Línea de tiempo',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Línea de tiempo scrolleable ──────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _timeline.length,
                itemBuilder: (_, i) => _TimelineItem(
                  event: _timeline[i],
                  isLast: i == _timeline.length - 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widget: ítem de la línea de tiempo ───────────────────────
class _TimelineItem extends StatelessWidget {
  final _TimelineEvent event;
  final bool isLast;

  const _TimelineItem({required this.event, required this.isLast});

  // Color e ícono según el tipo de evento
  Color get _dotColor {
    switch (event.type) {
      case 'improvement': return const Color(0xFF43A047);
      case 'alert': return const Color(0xFFE53935);
      case 'session': return const Color(0xFF7C4DFF);
      default: return const Color(0xFF1E88E5);
    }
  }

  IconData get _icon {
    switch (event.type) {
      case 'improvement': return Icons.trending_up_rounded;
      case 'alert': return Icons.warning_amber_rounded;
      case 'session': return Icons.psychology_rounded;
      default: return Icons.event_note_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna izquierda: punto + línea vertical
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _dotColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, size: 18, color: _dotColor),
              ),
              // Línea vertical que conecta los eventos
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          // Columna derecha: tarjeta con información
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SoftCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          event.title,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          event.date,
                          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textLight),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event.description,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textMedium,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widget: píldora de estadística ───────────────────────────
class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMedium),
          ),
        ],
      ),
    );
  }
}
