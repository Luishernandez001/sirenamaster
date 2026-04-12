// ============================================================
// groq_chat_service.dart — Servicio de chat con IA (Groq API)
// Actúa como asistente pedagógico para orientación escolar
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/report_model.dart';

class ChatMessage {
  final String role; // 'user', 'assistant', 'system'
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, String> toApiMap() => {'role': role, 'content': content};
}

class GroqChatService {
  static const _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const _apiKey =
      'GROQ_API_KEY';
  static const _model = 'llama-3.3-70b-versatile';

  final List<ChatMessage> _history = [];

  List<ChatMessage> get history => List.unmodifiable(_history);

  /// Construye el resumen anonimizado de los reportes seleccionados.
  static String buildReportContext(List<ReportModel> reports) {
    final buffer = StringBuffer();
    buffer.writeln('=== REPORTES ESCOLARES SELECCIONADOS ===\n');

    for (var i = 0; i < reports.length; i++) {
      final r = reports[i];
      buffer.writeln('--- Reporte ${i + 1} ---');
      buffer.writeln('Estudiante: Nº de lista ${r.listNumber ?? "N/A"}');
      buffer.writeln('Curso: ${r.course}');
      buffer.writeln('Área: ${r.area.isNotEmpty ? r.area : "N/A"}');
      buffer.writeln('Categoría: ${r.category}');
      buffer.writeln('Prioridad: ${r.priority}');
      buffer.writeln('Descripción del incidente: ${r.description}');
      buffer.writeln('');
    }

    return buffer.toString();
  }

  static const _systemPrompt = '''
Eres un asistente pedagógico experto en orientación escolar y psicología educativa.
Tu rol es apoyar al psicólogo escolar con estrategias profesionales, empáticas y accionables.

REGLAS ESTRICTAS:
- NUNCA solicites ni menciones nombres, apellidos ni datos personales de estudiantes.
- Refiere a los estudiantes únicamente por su número de lista y curso.
- Basa tus respuestas exclusivamente en la información de los reportes proporcionados.
- Responde siempre en español.
- Sé conciso, profesional y orientado a la acción.

FORMATO DE RESPUESTA INICIAL:
Cuando recibas los reportes, proporciona:
1. Un breve análisis del caso o los casos (2-3 oraciones).
2. De 2 a 5 estrategias de apoyo y comunicación concretas, numeradas.
3. Una recomendación de seguimiento.

Para preguntas posteriores del psicólogo, responde de forma directa y profesional,
siempre manteniendo la confidencialidad y sin pedir datos personales.
''';

  /// Inicia la conversación con el contexto de los reportes.
  Future<String> startConversation(List<ReportModel> reports) async {
    _history.clear();

    final reportContext = buildReportContext(reports);
    final userMessage =
        '$reportContext\nCon base en los reportes anteriores, sugiere de 2 a 5 estrategias de apoyo y comunicación para abordar el caso o los casos descritos.';

    _history.add(ChatMessage(role: 'user', content: userMessage));

    return _sendToApi();
  }

  /// Envía un mensaje de seguimiento del psicólogo.
  Future<String> sendMessage(String message) async {
    _history.add(ChatMessage(role: 'user', content: message));
    return _sendToApi();
  }

  Future<String> _sendToApi() async {
    final messages = [
      {'role': 'system', 'content': _systemPrompt},
      ..._history.map((m) => m.toApiMap()),
    ];

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 2048,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>;
        final content =
            (choices[0]['message'] as Map<String, dynamic>)['content'] as String;

        _history.add(ChatMessage(role: 'assistant', content: content));
        return content;
      } else {
        final errorBody = response.body;
        throw Exception('Error ${response.statusCode}: $errorBody');
      }
    } catch (e) {
      if (e is Exception && e.toString().contains('Error ')) {
        rethrow;
      }
      throw Exception(
          'No se pudo conectar con el servicio de IA. Verifica tu conexión a internet.');
    }
  }

  void clearHistory() => _history.clear();
}
