// ============================================================
// reports_list_screen.dart — Lista de todos los reportes
// Con filtros por prioridad y búsqueda por nombre
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/colors.dart';
import '../core/models/report_model.dart';
import '../widgets/soft_card.dart';
import '../widgets/decorative_background.dart';
import '../widgets/priority_badge.dart';

class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({super.key});

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  // Filtro activo: 'Todos', 'Alta', 'Media', 'Baja'
  String _activeFilter = 'Todos';

  // Texto de búsqueda
  String _searchQuery = '';

  final _searchController = TextEditingController();
  DateTime? _selectedDate;

  // Filtros disponibles
  final List<String> _filters = ['Todos', 'Alta', 'Media', 'Baja'];

  late final Stream<QuerySnapshot> _reportesStream;

  @override
  void initState() {
    super.initState();
    _reportesStream = FirebaseFirestore.instance.collection('reportes').orderBy('fechaHora', descending: true).snapshots();
  }

  // Retorna los reportes filtrados según búsqueda y prioridad
  List<ReportModel> _applyFilters(List<ReportModel> list) {
    return list.where((r) {
      final matchesPriority = _activeFilter == 'Todos' || r.priority == _activeFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          r.studentName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.course.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesDate = _selectedDate == null ||
          (r.date.year == _selectedDate!.year && r.date.month == _selectedDate!.month && r.date.day == _selectedDate!.day);
      return matchesPriority && matchesSearch && matchesDate;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecorativeBackground(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Text(
                'Reportes',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _reportesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error cargando reportes', style: GoogleFonts.poppins(color: AppColors.textMedium)));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final reports = docs.map((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final datos = data['datosEstudiante'] as Map<String, dynamic>? ?? {};
                    final autor = data['autor'] as Map<String, dynamic>? ?? {};
                    final clas = data['clasificacion'] as Map<String, dynamic>? ?? {};
                    return ReportModel(
                      id: d.id,
                      studentName: datos['nombre'] ?? '',
                      course: datos['curso'] ?? '',
                      listNumber: parseFirestoreOptionalInt(datos['numeroLista']),
                      priority: clas['prioridad'] ?? 'Media',
                      category: clas['categoria'] ?? 'Otro',
                      description: data['descripcion'] ?? '',
                      date: (data['fechaHora'] is Timestamp) ? (data['fechaHora'] as Timestamp).toDate() : DateTime.now(),
                      reportedBy: autor['nombre'] ?? '',
                    );
                  }).toList();

                  final filtered = _applyFilters(reports);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          '${reports.length} reportes registrados',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppColors.softShadow,
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) => setState(() => _searchQuery = v),
                            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
                            decoration: InputDecoration(
                              hintText: 'Buscar estudiante o curso...',
                              hintStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.textLight),
                              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textLight, size: 20),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                      child: const Icon(Icons.close_rounded, color: AppColors.textLight, size: 18),
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (picked != null) setState(() => _selectedDate = picked);
                                },
                                child: Container(
                                  height: 44,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: AppColors.softShadow,
                                    border: Border.all(color: const Color(0xFFEEEEEE)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined, color: AppColors.textLight, size: 18),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _selectedDate == null ? 'Filtrar por fecha' : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                          style: GoogleFonts.poppins(fontSize: 14, color: _selectedDate == null ? AppColors.textLight : AppColors.textDark),
                                        ),
                                      ),
                                      if (_selectedDate != null)
                                        GestureDetector(
                                          onTap: () => setState(() => _selectedDate = null),
                                          child: const Icon(Icons.close_rounded, color: AppColors.textLight, size: 18),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _filters.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final filter = _filters[i];
                            final isActive = filter == _activeFilter;
                            return GestureDetector(
                              onTap: () => setState(() => _activeFilter = filter),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: isActive ? AppColors.primaryGradient : null,
                                  color: isActive ? null : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: isActive ? AppColors.cardShadow : AppColors.softShadow,
                                ),
                                child: Text(
                                  filter,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isActive ? Colors.white : AppColors.textMedium,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: filtered.isEmpty
                            ? const _EmptyState()
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                itemCount: filtered.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 12),
                                itemBuilder: (_, i) => _ReportCard(report: filtered[i]),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widget: tarjeta de reporte completa ───────────────────────
class _ReportCard extends StatelessWidget {
  final ReportModel report;
  const _ReportCard({required this.report});

  // Retorna el ícono según la categoría del reporte
  IconData get _categoryIcon {
    switch (report.category) {
      case 'Conductual': return Icons.psychology_alt_rounded;
      case 'Académico': return Icons.menu_book_rounded;
      case 'Emocional': return Icons.favorite_border_rounded;
      case 'Familiar': return Icons.family_restroom_rounded;
      default: return Icons.description_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila superior: nombre + badge de prioridad
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lila,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_categoryIcon, color: const Color(0xFF7C4DFF), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.studentName,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      report.course,
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMedium),
                    ),
                  ],
                ),
              ),
              PriorityBadge(priority: report.priority),
            ],
          ),

          const SizedBox(height: 12),

          // Descripción del reporte (máximo 2 líneas)
          Text(
            report.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textMedium,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 12),

          // Fila inferior: categoría + fecha + reportado por
          Row(
            children: [
              _InfoChip(label: report.category, icon: Icons.label_outline_rounded),
              const SizedBox(width: 8),
              _InfoChip(
                label: '${report.date.day}/${report.date.month}/${report.date.year}',
                icon: Icons.calendar_today_rounded,
              ),
              const Spacer(),
              Text(
                report.reportedBy,
                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textLight),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Widget: chip de información pequeño ──────────────────────
class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _InfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.smokeWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.textLight),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMedium),
          ),
        ],
      ),
    );
  }
}

// ── Widget: estado vacío ──────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Estado vacío con imagen real
          Image.asset(
            'assets/images/empty_state.png',
            width: 160,
            height: 160,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            'Sin resultados',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No se encontraron reportes\ncon ese criterio de búsqueda',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMedium),
          ),
        ],
      ),
    );
  }
}
