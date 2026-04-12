// ============================================================
// pdf_report_generator.dart — Generación de PDF profesional
// para reportes estudiantiles de Serenia
// ============================================================

import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/report_model.dart';

class PdfReportGenerator {
  static const _primaryColor = PdfColor.fromInt(0xFF7C4DFF);
  static const _headerBg = PdfColor.fromInt(0xFF9575CD);
  static const _lightBg = PdfColor.fromInt(0xFFF8FAFF);
  static const _borderColor = PdfColor.fromInt(0xFFE0E0E0);
  static const _textDark = PdfColor.fromInt(0xFF2D2D3A);
  static const _textMedium = PdfColor.fromInt(0xFF6B6B80);

  static const _highBg = PdfColor.fromInt(0xFFFFCDD2);
  static const _highText = PdfColor.fromInt(0xFFE53935);
  static const _medBg = PdfColor.fromInt(0xFFFFF9C4);
  static const _medText = PdfColor.fromInt(0xFFF9A825);
  static const _lowBg = PdfColor.fromInt(0xFFD3F3DB);
  static const _lowText = PdfColor.fromInt(0xFF43A047);

  static PdfColor _priorityBg(String p) {
    switch (p) {
      case 'Alta':
        return _highBg;
      case 'Media':
        return _medBg;
      default:
        return _lowBg;
    }
  }

  static PdfColor _priorityText(String p) {
    switch (p) {
      case 'Alta':
        return _highText;
      case 'Media':
        return _medText;
      default:
        return _lowText;
    }
  }

  static Future<Uint8List> generate(List<ReportModel> reports) async {
    final pdf = pw.Document(
      title: 'Reportes Estudiantiles — Serenia',
      author: 'Departamento de Psicología',
      creator: 'Serenia App',
    );

    final now = DateTime.now();
    final dateFormat = DateFormat("d 'de' MMMM 'de' yyyy", 'es');
    final generatedDate = dateFormat.format(now);
    final timeStr = DateFormat('HH:mm', 'es').format(now);

    final countByPriority = <String, int>{'Alta': 0, 'Media': 0, 'Baja': 0};
    for (final r in reports) {
      countByPriority[r.priority] = (countByPriority[r.priority] ?? 0) + 1;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildPageHeader(context, generatedDate),
        footer: (context) => _buildPageFooter(context, timeStr),
        build: (context) => [
          _buildTitleSection(generatedDate, reports.length, countByPriority),
          pw.SizedBox(height: 20),
          ...reports.asMap().entries.map(
                (entry) => _buildReportBlock(entry.value, entry.key + 1, reports.length),
              ),
          pw.SizedBox(height: 24),
          _buildSignatureSection(),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPageHeader(pw.Context context, String date) {
    if (context.pageNumber == 1) return pw.SizedBox.shrink();

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _borderColor, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'SERENIA — Reportes Estudiantiles',
            style: pw.TextStyle(fontSize: 9, color: _textMedium, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            date,
            style: pw.TextStyle(fontSize: 9, color: _textMedium),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPageFooter(pw.Context context, String time) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _borderColor, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Documento generado por Serenia — $time',
            style: pw.TextStyle(fontSize: 8, color: _textMedium),
          ),
          pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 8, color: _textMedium),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTitleSection(
    String date,
    int totalReports,
    Map<String, int> countByPriority,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: pw.BoxDecoration(
            color: _headerBg,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'POLITÉCNICO ALTAGRACIA IGLESIAS DE LORA',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  letterSpacing: 4,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Sistema de Gestión de Reportes Estudiantiles',
                style: pw.TextStyle(fontSize: 11, color: PdfColors.white),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Departamento de Psicología',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.white,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 16),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: _lightBg,
            borderRadius: pw.BorderRadius.circular(6),
            border: pw.Border.all(color: _borderColor, width: 0.5),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'INFORME DE REPORTES ESTUDIANTILES',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: _primaryColor,
                      letterSpacing: 1,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Fecha de generación: $date',
                    style: pw.TextStyle(fontSize: 9, color: _textMedium),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Total de reportes incluidos: $totalReports',
                    style: pw.TextStyle(fontSize: 9, color: _textMedium),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  _buildStatBadge('Alta', countByPriority['Alta'] ?? 0, _highBg, _highText),
                  pw.SizedBox(width: 6),
                  _buildStatBadge('Media', countByPriority['Media'] ?? 0, _medBg, _medText),
                  pw.SizedBox(width: 6),
                  _buildStatBadge('Baja', countByPriority['Baja'] ?? 0, _lowBg, _lowText),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildStatBadge(String label, int count, PdfColor bg, PdfColor text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            '$count',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: text),
          ),
          pw.Text(label, style: pw.TextStyle(fontSize: 7, color: text)),
        ],
      ),
    );
  }

  static pw.Widget _buildReportBlock(ReportModel report, int index, int total) {
    final dateFormat = DateFormat("d/MM/yyyy", 'es');
    final formattedDate = dateFormat.format(report.date);

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 14),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: _borderColor, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Encabezado del reporte
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: pw.BoxDecoration(
              color: _priorityBg(report.priority),
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(6),
                topRight: pw.Radius.circular(6),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        'Reporte $index de $total',
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          color: _textDark,
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Text(
                      report.studentName,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: pw.BoxDecoration(
                    color: _priorityText(report.priority),
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Text(
                    'Prioridad ${report.priority}',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cuerpo
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Datos del estudiante en tabla
                pw.Table(
                  columnWidths: {
                    0: const pw.FixedColumnWidth(120),
                    1: const pw.FlexColumnWidth(),
                    2: const pw.FixedColumnWidth(120),
                    3: const pw.FlexColumnWidth(),
                  },
                  children: [
                    pw.TableRow(children: [
                      _fieldLabel('Estudiante:'),
                      _fieldValue(report.studentName),
                      _fieldLabel('Curso:'),
                      _fieldValue(report.course),
                    ]),
                    pw.TableRow(children: [
                      _fieldLabel('Categoría:'),
                      _fieldValue(report.category),
                      _fieldLabel('Nº Lista:'),
                      _fieldValue(report.listNumber?.toString() ?? 'N/A'),
                    ]),
                    pw.TableRow(children: [
                      _fieldLabel('Área:'),
                      _fieldValue(report.area.isNotEmpty ? report.area : 'N/A'),
                      _fieldLabel('Fecha del reporte:'),
                      _fieldValue(formattedDate),
                    ]),
                    pw.TableRow(children: [
                      _fieldLabel('Reportado por:'),
                      _fieldValue(report.reportedBy),
                      _fieldLabel('ID:'),
                      _fieldValue(report.id.length > 12 ? '${report.id.substring(0, 12)}…' : report.id),
                    ]),
                  ],
                ),

                pw.SizedBox(height: 12),

                // Descripción
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: _lightBg,
                    borderRadius: pw.BorderRadius.circular(4),
                    border: pw.Border.all(color: _borderColor, width: 0.5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'DESCRIPCIÓN DEL CASO',
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          color: _primaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        report.description,
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: _textDark,
                          lineSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _fieldLabel(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: _textMedium,
        ),
      ),
    );
  }

  static pw.Widget _fieldValue(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 10, color: _textDark),
      ),
    );
  }

  static pw.Widget _buildSignatureSection() {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 16),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
        children: [
          _signatureLine('Psicólogo(a) responsable'),
          _signatureLine('Director(a) / Coordinador(a)'),
        ],
      ),
    );
  }

  static pw.Widget _signatureLine(String label) {
    return pw.Column(
      children: [
        pw.Container(
          width: 180,
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: _textMedium, width: 0.5)),
          ),
          child: pw.SizedBox(height: 50),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 9, color: _textMedium),
        ),
      ],
    );
  }
}
