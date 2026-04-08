// ============================================================
// soft_card.dart — Tarjeta flotante con bordes redondeados
// Úsala como contenedor: SoftCard(child: TuWidget())
// ============================================================

import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double borderRadius;
  final List<BoxShadow>? shadow;
  final VoidCallback? onTap;

  const SoftCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderRadius = 24,
    this.shadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: shadow ?? AppColors.cardShadow,
        ),
        child: child,
      ),
    );
  }
}
