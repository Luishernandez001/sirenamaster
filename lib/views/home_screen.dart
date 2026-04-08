// ============================================================
// home_screen.dart — Dashboard premium con BottomNav animado
// BottomNav estilo "bubble" donde el ícono activo sube en círculo
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/colors.dart';
import '../core/models/report_model.dart';
import '../widgets/decorative_background.dart';
import '../widgets/priority_badge.dart';
import 'reports_list_screen.dart';
import 'create_report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;

  late final List<Widget> _screens;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _screens = [
      const _DashboardTab(),
      const ReportsListScreen(),
    ];
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    _fadeController.reverse().then((_) {
      setState(() => _currentIndex = index);
      _fadeController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.smokeWhite,
      extendBody: true,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: IndexedStack(index: _currentIndex, children: _screens),
      ),
      bottomNavigationBar: _BubbleNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
        onAddTap: () => Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (context, anim, secAnim) => const CreateReportScreen(),
            transitionsBuilder: (context, anim, secAnim, child) => SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                  .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// _BubbleNavBar — BottomNav con burbuja perfectamente alineada
// Usa 3 slots: Inicio | Reportes | [+]
// La burbuja se posiciona exactamente debajo del ícono activo
// ============================================================
class _BubbleNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onAddTap;

  const _BubbleNavBar({required this.currentIndex, required this.onTap, required this.onAddTap});

  @override
  State<_BubbleNavBar> createState() => _BubbleNavBarState();
}

class _BubbleNavBarState extends State<_BubbleNavBar> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_BubbleNavBar old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double barHeight = 68.0;
    const double bubbleSize = 54.0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final slotWidth = totalWidth / 3;

            // Centro X de cada slot de navegación (slots 0 and 1 are pages)
            final List<double> slotCenters = [
              slotWidth * 0.5, // Inicio → slot 0
              slotWidth * 1.5, // Reportes → slot 1
            ];

            final bubbleLeft = slotCenters[widget.currentIndex] - bubbleSize / 2;

            return SizedBox(
              height: barHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ── Barra oscura ─────────────────────────────
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2D3A),
                        borderRadius: BorderRadius.circular(34),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Burbuja animada (detrás de los íconos) ────
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    left: bubbleLeft,
                    top: (barHeight - bubbleSize) / 2,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: Container(
                        width: bubbleSize,
                        height: bubbleSize,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF9575CD), Color(0xFF5E35B1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7C4DFF).withValues(alpha: 0.5),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Íconos encima de la burbuja ───────────────
                  Positioned.fill(
                    child: Row(
                      children: [
                        Expanded(child: _BubbleNavItem(icon: Icons.home_rounded, index: 0, currentIndex: widget.currentIndex, onTap: widget.onTap)),
                        Expanded(child: _BubbleNavItem(icon: Icons.description_rounded, index: 1, currentIndex: widget.currentIndex, onTap: widget.onTap)),
                        // Botón + al final
                        Expanded(
                          child: GestureDetector(
                            onTap: widget.onAddTap,
                            behavior: HitTestBehavior.opaque,
                            child: Center(
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white30, width: 1.5),
                                ),
                                child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BubbleNavItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final int currentIndex;
  final Function(int) onTap;

  const _BubbleNavItem({required this.icon, required this.index, required this.currentIndex, required this.onTap});

  bool get _isActive => index == currentIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Icon(
          icon,
          size: 24,
          color: _isActive ? Colors.white : Colors.white38,
        ),
      ),
    );
  }
}

// ============================================================
// _DashboardTab — Dashboard premium
// ============================================================
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final total = sampleReports.length;
    final high = sampleReports.where((r) => r.priority == 'Alta').length;
    final medium = sampleReports.where((r) => r.priority == 'Media').length;
    final low = sampleReports.where((r) => r.priority == 'Baja').length;

    return DecorativeBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Header: logo grande + saludo + avatar ───────
              Row(
                children: [
                  // Logo más grande
                  Image.asset('assets/images/logo_serenia.png', width: 64, height: 64, fit: BoxFit.contain),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hola, Orientador 👋',
                            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                        Text('Jueves, 2 de Abril 2026',
                            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMedium)),
                      ],
                    ),
                  ),
                  // Avatar con gradiente
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Banner premium con gradiente oscuro ─────────
              _AnimatedBanner(total: total, high: high),

              const SizedBox(height: 24),

              // ── Estadísticas con animación de entrada ───────
              Text('Estadísticas', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _StatCard(label: 'Alta', count: high, color: AppColors.priorityHigh, textColor: AppColors.priorityHighText, icon: Icons.warning_amber_rounded)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(label: 'Media', count: medium, color: AppColors.priorityMedium, textColor: AppColors.priorityMediumText, icon: Icons.info_outline_rounded)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(label: 'Baja', count: low, color: AppColors.priorityLow, textColor: AppColors.priorityLowText, icon: Icons.check_circle_outline_rounded)),
                ],
              ),

              const SizedBox(height: 28),

              // ── Accesos rápidos ─────────────────────────────
              Text('Accesos rápidos', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.add_circle_outline_rounded,
                      label: 'Nuevo\nReporte',
                      color: AppColors.lila,
                      iconColor: const Color(0xFF7C4DFF),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateReportScreen())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.psychology_rounded,
                      label: 'Seguimiento\nPsicológico',
                      color: AppColors.mintGreen,
                      iconColor: const Color(0xFF43A047),
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Banner animado con shimmer y gradiente ────────────────────
class _AnimatedBanner extends StatefulWidget {
  final int total;
  final int high;
  const _AnimatedBanner({required this.total, required this.high});

  @override
  State<_AnimatedBanner> createState() => _AnimatedBannerState();
}

class _AnimatedBannerState extends State<_AnimatedBanner> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _slideAnim = Tween<double>(begin: 30, end: 0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _slideAnim.value),
        child: Opacity(opacity: _fadeAnim.value, child: child),
      ),
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A148C), Color(0xFF7C4DFF), Color(0xFFB39DDB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C4DFF).withValues(alpha: 0.4),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Círculo decorativo interno
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            // Contenido
            Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Resumen del mes',
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white60)),
                        const SizedBox(height: 4),
                        Text('${widget.total} reportes activos',
                            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: Text('${widget.high} urgentes · atención requerida',
                              style: GoogleFonts.poppins(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                  Image.asset('assets/images/illustration_home.png', width: 120, height: 120, fit: BoxFit.contain),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tarjeta de estadística ────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color textColor;
  final IconData icon;

  const _StatCard({required this.label, required this.count, required this.color, required this.textColor, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: textColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text('$count', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800, color: textColor)),
          Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: textColor.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}

// ── Acceso rápido ─────────────────────────────────────────────
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.color, required this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 10),
            Text(label, textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark, height: 1.3)),
          ],
        ),
      ),
    );
  }
}

// ── Tarjeta de reporte reciente ───────────────────────────────
class _RecentReportCard extends StatelessWidget {
  final ReportModel report;
  const _RecentReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.studentName, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                Text('${report.course} · ${report.category}', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMedium)),
              ],
            ),
          ),
          PriorityBadge(priority: report.priority),
        ],
      ),
    );
  }
}
