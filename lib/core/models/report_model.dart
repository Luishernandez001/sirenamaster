// ============================================================
// report_model.dart — Modelo de datos para un reporte estudiantil
// ============================================================

class ReportModel {
  final String id;
  final String studentName;
  final String course;
  final int? listNumber;
  final String priority;   // 'Alta', 'Media', 'Baja'
  final String category;   // 'Conductual', 'Académico', 'Emocional', 'Familiar'
  final String description;
  final DateTime date;
  final String reportedBy;

  ReportModel({
    required this.id,
    required this.studentName,
    required this.course,
    this.listNumber,
    required this.priority,
    required this.category,
    required this.description,
    required this.date,
    required this.reportedBy,
  });
}

/// Convierte valores de Firestore (`int`, `num` o `"12"`) a [int] para listas y formularios.
int? parseFirestoreOptionalInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

// Datos de ejemplo para mostrar en la app sin base de datos
final List<ReportModel> sampleReports = [
  ReportModel(
    id: '001',
    studentName: 'Valentina Torres',
    course: '3° Básico A',
    priority: 'Alta',
    category: 'Conductual',
    description: 'Presenta dificultades para mantener la atención en clases y conflictos con compañeros durante el recreo.',
    date: DateTime(2026, 3, 28),
    reportedBy: 'Prof. Martínez',
  ),
  ReportModel(
    id: '002',
    studentName: 'Mateo Rodríguez',
    course: '5° Básico B',
    priority: 'Media',
    category: 'Académico',
    description: 'Bajo rendimiento en matemáticas. Requiere apoyo adicional y evaluación diferenciada.',
    date: DateTime(2026, 3, 25),
    reportedBy: 'Prof. González',
  ),
  ReportModel(
    id: '003',
    studentName: 'Sofía Herrera',
    course: '2° Medio C',
    priority: 'Baja',
    category: 'Emocional',
    description: 'Estudiante muestra signos de ansiedad ante evaluaciones. Se recomienda seguimiento.',
    date: DateTime(2026, 3, 20),
    reportedBy: 'Prof. Soto',
  ),
  ReportModel(
    id: '004',
    studentName: 'Benjamín Castro',
    course: '4° Básico A',
    priority: 'Alta',
    category: 'Familiar',
    description: 'Situación familiar compleja. Padres en proceso de separación. Requiere apoyo psicológico urgente.',
    date: DateTime(2026, 3, 15),
    reportedBy: 'Prof. Díaz',
  ),
];
