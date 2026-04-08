// ============================================================
// decorative_background.dart — Fondo con círculos decorativos
// Envuelve cualquier pantalla con este widget para el efecto
// de burbujas difuminadas en las esquinas.
// Uso: DecorativeBackground(child: TuPantalla())
// ============================================================

import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class DecorativeBackground extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const DecorativeBackground({
    super.key,
    required this.child,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo base
        Container(
          color: backgroundColor ?? AppColors.smokeWhite,
        ),

        // Círculo decorativo — esquina superior izquierda (lila)
        Positioned(
          top: -60,
          left: -60,
          child: _BlurCircle(
            size: 200,
            color: AppColors.lila.withValues(alpha: 0.6),
          ),
        ),

        // Círculo decorativo — esquina superior derecha (azul)
        Positioned(
          top: -30,
          right: -80,
          child: _BlurCircle(
            size: 180,
            color: AppColors.skyBlue.withValues(alpha: 0.5),
          ),
        ),

        // Círculo decorativo — esquina inferior derecha (verde)
        Positioned(
          bottom: -70,
          right: -50,
          child: _BlurCircle(
            size: 220,
            color: AppColors.mintGreen.withValues(alpha: 0.5),
          ),
        ),

        // Círculo decorativo — esquina inferior izquierda (lila suave)
        Positioned(
          bottom: -40,
          left: -70,
          child: _BlurCircle(
            size: 160,
            color: AppColors.lila.withValues(alpha: 0.3),
          ),
        ),

        // Contenido principal encima de los círculos
        child,
      ],
    );
  }
}

// Widget privado para cada círculo difuminado
class _BlurCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      // El efecto blur se logra con un filtro de imagen
      child: ClipOval(
        child: BackdropFilter(
          filter: const ColorFilter.mode(Colors.transparent, BlendMode.src),
          child: Container(color: color),
        ),
      ),
    );
  }
}
