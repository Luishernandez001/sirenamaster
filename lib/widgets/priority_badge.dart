// ============================================================
// priority_badge.dart — Badge de prioridad para reportes
// Muestra "Alta", "Media" o "Baja" con color correspondiente
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/colors.dart';

class PriorityBadge extends StatelessWidget {
  final String priority; // 'Alta', 'Media', 'Baja'

  const PriorityBadge({super.key, required this.priority});

  // Retorna el color de fondo según la prioridad
  Color get _bgColor {
    switch (priority) {
      case 'Alta':
        return AppColors.priorityHigh;
      case 'Media':
        return AppColors.priorityMedium;
      default:
        return AppColors.priorityLow;
    }
  }

  // Retorna el color del texto según la prioridad
  Color get _textColor {
    switch (priority) {
      case 'Alta':
        return AppColors.priorityHighText;
      case 'Media':
        return AppColors.priorityMediumText;
      default:
        return AppColors.priorityLowText;
    }
  }

  // Retorna el ícono según la prioridad
  IconData get _icon {
    switch (priority) {
      case 'Alta':
        return Icons.arrow_upward_rounded;
      case 'Media':
        return Icons.remove_rounded;
      default:
        return Icons.arrow_downward_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12, color: _textColor),
          const SizedBox(width: 4),
          Text(
            priority,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }
}
