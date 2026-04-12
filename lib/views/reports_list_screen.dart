// ============================================================
// reports_list_screen.dart — Lista de todos los reportes
// Filtros por prioridad, búsqueda, selección múltiple y
// exportación a PDF profesional
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart';
import '../core/constants/colors.dart';
import '../core/models/report_model.dart';
import '../core/utils/report_firestore.dart';
import '../core/utils/pdf_report_generator.dart';
import '../widgets/decorative_background.dart';
import '../widgets/priority_badge.dart';

class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({super.key});

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  String _activeFilter = 'Todos';
  String _searchQuery = '';

  final _searchController = TextEditingController();
  DateTime? _selectedDate;

  final List<String> _filters = ['Todos', 'Alta', 'Media', 'Baja'];

  late Future<List<QueryDocumentSnapshot<Object?>>> _reportesFuture;

  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _reportesFuture = fetchSortedReportDocs();
  }

  void _reloadReports() {
    setState(() {
      _reportesFuture = fetchSortedReportDocs();
      _selectedIds.clear();
    });
  }

  static String _normalizeForSearch(String input) {
    var s = input.toLowerCase();
    const from = 'áàäâãåéèëêíìïîóòöôõúùüûñ';
    const to = 'aaaaaaeeeeiiiiooooouuuun';
    for (var i = 0; i < from.length; i++) {
      s = s.replaceAll(from[i], to[i]);
    }
    return s.trim();
  }

  static bool _fieldContainsQuery(String fieldValue, String queryNormalized) {
    if (queryNormalized.isEmpty) return true;
    return _normalizeForSearch(fieldValue).contains(queryNormalized);
  }

  bool _matchesTextSearch(ReportModel r, String rawQuery) {
    final trimmed = rawQuery.trim();
    if (trimmed.isEmpty) return true;
    final qn = _normalizeForSearch(trimmed);

    if (_fieldContainsQuery(r.studentName, qn)) return true;
    if (_fieldContainsQuery(r.course, qn)) return true;
    if (_fieldContainsQuery(r.area, qn)) return true;
    if (_fieldContainsQuery(r.category, qn)) return true;
    if (_fieldContainsQuery(r.priority, qn)) return true;

    if (RegExp(r'^\d+$').hasMatch(trimmed)) {
      final n = int.tryParse(trimmed);
      if (n != null && r.listNumber == n) return true;
    }
    if (r.listNumber != null && _normalizeForSearch('${r.listNumber}').contains(qn)) return true;

    return false;
  }

  List<ReportModel> _applyFilters(List<ReportModel> list) {
    return list.where((r) {
      final matchesPriority = _activeFilter == 'Todos' || r.priority == _activeFilter;
      final matchesSearch = _matchesTextSearch(r, _searchQuery);
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

  List<ReportModel> _mapDocsToReports(List<QueryDocumentSnapshot<Object?>> docs) {
    return docs.map((d) {
      final data = d.data() as Map<String, dynamic>;
      final datos = data['datosEstudiante'] as Map<String, dynamic>? ?? {};
      final autor = data['autor'] as Map<String, dynamic>? ?? {};
      final clas = data['clasificacion'] as Map<String, dynamic>? ?? {};
      return ReportModel(
        id: d.id,
        studentName: datos['nombre']?.toString() ?? '',
        course: datos['curso']?.toString() ?? '',
        listNumber: parseFirestoreOptionalInt(datos['numeroLista']),
        area: datos['area']?.toString() ?? '',
        priority: clas['prioridad']?.toString() ?? 'Media',
        category: clas['categoria']?.toString() ?? 'Otro',
        description: data['descripcion']?.toString() ?? '',
        date: (data['fechaHora'] is Timestamp) ? (data['fechaHora'] as Timestamp).toDate() : DateTime.now(),
        reportedBy: autor['nombre']?.toString() ?? '',
      );
    }).toList();
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _toggleSelectAll(List<ReportModel> filtered) {
    setState(() {
      final allVisibleSelected = filtered.every((r) => _selectedIds.contains(r.id));
      if (allVisibleSelected) {
        for (final r in filtered) {
          _selectedIds.remove(r.id);
        }
      } else {
        for (final r in filtered) {
          _selectedIds.add(r.id);
        }
      }
    });
  }

  Future<void> _printSelected(List<ReportModel> allReports) async {
    final selected = allReports.where((r) => _selectedIds.contains(r.id)).toList();
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Selecciona al menos un reporte para imprimir',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: const Color(0xFF9575CD),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final pdfBytes = await PdfReportGenerator.generate(selected);

    if (!mounted) return;

    await Printing.layoutPdf(
      onLayout: (_) => pdfBytes,
      name: 'Serenia_Reportes_${DateTime.now().millisecondsSinceEpoch}',
    );
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
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Reportes',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _reloadReports,
                    icon: const Icon(Icons.refresh_rounded),
                    color: AppColors.textMedium,
                    tooltip: 'Recargar reportes',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FutureBuilder<List<QueryDocumentSnapshot<Object?>>>(
                future: _reportesFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(
                      'No se pudo cargar el conteo',
                      style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMedium),
                    );
                  }
                  final n = snapshot.data?.length;
                  final label = n == null ? '…' : '$n';
                  return Text(
                    '$label reportes registrados',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textMedium,
                    ),
                  );
                },
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
                    hintText: 'Nombre, curso, área, Nº lista, categoría o prioridad…',
                    hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight),
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

            // Fila de filtros + botón imprimir
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
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
                  ),
                  const SizedBox(width: 8),
                  _PrintButton(
                    count: _selectedIds.length,
                    onPressed: () {
                      // Will be connected inside FutureBuilder via callback
                      _printSelectedFromState();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Select-all row (visible when there are filtered results)
            Expanded(
              child: FutureBuilder<List<QueryDocumentSnapshot<Object?>>>(
                future: _reportesFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error cargando reportes',
                            style: GoogleFonts.poppins(color: AppColors.textMedium),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _reloadReports,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data ?? const <QueryDocumentSnapshot<Object?>>[];
                  _allReports = _mapDocsToReports(docs);
                  final filtered = _applyFilters(_allReports);

                  if (filtered.isEmpty) {
                    return const _EmptyState();
                  }

                  final allVisibleSelected = filtered.every((r) => _selectedIds.contains(r.id));

                  return Column(
                    children: [
                      // Select all row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: GestureDetector(
                          onTap: () => _toggleSelectAll(filtered),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedIds.isNotEmpty
                                  ? const Color(0xFFEDE7F6)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedIds.isNotEmpty
                                    ? const Color(0xFFB39DDB)
                                    : const Color(0xFFEEEEEE),
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: Checkbox(
                                    value: allVisibleSelected && filtered.isNotEmpty,
                                    onChanged: (_) => _toggleSelectAll(filtered),
                                    activeColor: const Color(0xFF9575CD),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    side: const BorderSide(color: Color(0xFFB39DDB)),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedIds.isEmpty
                                        ? 'Seleccionar todos (${filtered.length})'
                                        : '${_selectedIds.length} reporte${_selectedIds.length == 1 ? '' : 's'} seleccionado${_selectedIds.length == 1 ? '' : 's'}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _selectedIds.isNotEmpty
                                          ? const Color(0xFF7C4DFF)
                                          : AppColors.textMedium,
                                    ),
                                  ),
                                ),
                                if (_selectedIds.isNotEmpty)
                                  GestureDetector(
                                    onTap: () => setState(() => _selectedIds.clear()),
                                    child: Text(
                                      'Limpiar',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textLight,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Lista de reportes
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (_, i) => _SelectableReportCard(
                            report: filtered[i],
                            isSelected: _selectedIds.contains(filtered[i].id),
                            onToggle: () => _toggleSelection(filtered[i].id),
                          ),
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

  List<ReportModel> _allReports = [];

  void _printSelectedFromState() {
    _printSelected(_allReports);
  }
}

// ── Widget: botón imprimir reportes ──────────────────────────
class _PrintButton extends StatelessWidget {
  final int count;
  final VoidCallback onPressed;
  const _PrintButton({required this.count, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final hasSelection = count > 0;
    return GestureDetector(
      onTap: hasSelection ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: hasSelection ? AppColors.primaryGradient : null,
          color: hasSelection ? null : const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(20),
          boxShadow: hasSelection ? AppColors.cardShadow : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.print_rounded,
              size: 16,
              color: hasSelection ? Colors.white : AppColors.textLight,
            ),
            const SizedBox(width: 6),
            Text(
              hasSelection ? 'Imprimir ($count)' : 'Imprimir',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: hasSelection ? Colors.white : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widget: tarjeta de reporte con checkbox ──────────────────
class _SelectableReportCard extends StatelessWidget {
  final ReportModel report;
  final bool isSelected;
  final VoidCallback onToggle;
  const _SelectableReportCard({
    required this.report,
    required this.isSelected,
    required this.onToggle,
  });

  IconData get _categoryIcon {
    switch (report.category) {
      case 'Conductual':
        return Icons.psychology_alt_rounded;
      case 'Académico':
        return Icons.menu_book_rounded;
      case 'Emocional':
        return Icons.favorite_border_rounded;
      case 'Familiar':
        return Icons.family_restroom_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF9575CD) : Colors.transparent,
            width: isSelected ? 2 : 0,
          ),
          boxShadow: isSelected ? AppColors.cardShadow : AppColors.softShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (_) => onToggle(),
                        activeColor: const Color(0xFF9575CD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF9575CD)
                              : const Color(0xFFCCCCCC),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Category icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFEDE7F6) : AppColors.lila,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_categoryIcon, color: const Color(0xFF7C4DFF), size: 20),
                  ),
                  const SizedBox(width: 12),

                  // Student info
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
                        if (report.area.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Área: ${report.area}',
                            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textLight),
                          ),
                        ],
                      ],
                    ),
                  ),
                  PriorityBadge(priority: report.priority),
                ],
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Text(
                  report.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textMedium,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Row(
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
              ),
            ],
          ),
        ),
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
