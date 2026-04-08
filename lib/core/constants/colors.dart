// ============================================================
// colors.dart — Paleta de colores oficial de Serenia
// Todos los colores de la app se definen aquí para mantener
// consistencia visual en toda la aplicación.
// ============================================================

import 'package:flutter/material.dart';

class AppColors {
  // Colores principales (pastel suave)
  static const Color lila = Color(0xFFDDD0FC);       // Lila principal
  static const Color mintGreen = Color(0xFFD3F3DB);  // Verde menta
  static const Color skyBlue = Color(0xFFDEF1F7);    // Azul cielo
  static const Color smokeWhite = Color(0xFFF8FAFF); // Blanco humo (fondo)

  // Colores de acento (versiones más saturadas para botones/iconos)
  static const Color lilaAccent = Color(0xFFB39DDB);
  static const Color mintAccent = Color(0xFF81C784);
  static const Color blueAccent = Color(0xFF64B5F6);

  // Colores de texto
  static const Color textDark = Color(0xFF2D2D3A);   // Texto principal oscuro
  static const Color textMedium = Color(0xFF6B6B80); // Texto secundario
  static const Color textLight = Color(0xFFAAAAAF);  // Texto deshabilitado

  // Colores de prioridad para reportes
  static const Color priorityHigh = Color(0xFFFFCDD2);   // Rojo pastel
  static const Color priorityMedium = Color(0xFFFFF9C4); // Amarillo pastel
  static const Color priorityLow = Color(0xFFD3F3DB);    // Verde pastel

  static const Color priorityHighText = Color(0xFFE53935);
  static const Color priorityMediumText = Color(0xFFF9A825);
  static const Color priorityLowText = Color(0xFF43A047);

  // Gradiente principal para botones
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFB39DDB), Color(0xFF9575CD)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Gradiente secundario (verde-azul)
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF81C784), Color(0xFF4DD0E1)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Sombra suave estándar para tarjetas flotantes
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFFB39DDB).withValues(alpha: 0.18),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // Sombra más sutil para elementos secundarios
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}
