// ============================================================
// message_model.dart — Modelo para mensajes a padres/apoderados
// ============================================================

class MessageModel {
  final String id;
  final String parentName;
  final String studentName;
  final String text;
  final DateTime time;
  final bool isFromCounselor; // true = enviado por orientador, false = del padre

  MessageModel({
    required this.id,
    required this.parentName,
    required this.studentName,
    required this.text,
    required this.time,
    required this.isFromCounselor,
  });
}

// Conversaciones de ejemplo
final List<MessageModel> sampleMessages = [
  MessageModel(
    id: '1',
    parentName: 'Sra. Torres',
    studentName: 'Valentina Torres',
    text: 'Buenos días, ¿podría agendar una reunión para hablar sobre Valentina?',
    time: DateTime(2026, 3, 30, 9, 15),
    isFromCounselor: false,
  ),
  MessageModel(
    id: '2',
    parentName: 'Sra. Torres',
    studentName: 'Valentina Torres',
    text: 'Claro, con gusto. Tengo disponibilidad el miércoles a las 15:00 hrs. ¿Le acomoda?',
    time: DateTime(2026, 3, 30, 9, 30),
    isFromCounselor: true,
  ),
  MessageModel(
    id: '3',
    parentName: 'Sra. Torres',
    studentName: 'Valentina Torres',
    text: 'Perfecto, ahí estaré. Muchas gracias.',
    time: DateTime(2026, 3, 30, 9, 45),
    isFromCounselor: false,
  ),
  MessageModel(
    id: '4',
    parentName: 'Sr. Rodríguez',
    studentName: 'Mateo Rodríguez',
    text: 'Hola, recibí la notificación del reporte de Mateo. ¿Qué podemos hacer?',
    time: DateTime(2026, 3, 29, 14, 0),
    isFromCounselor: false,
  ),
  MessageModel(
    id: '5',
    parentName: 'Sr. Rodríguez',
    studentName: 'Mateo Rodríguez',
    text: 'Hola Sr. Rodríguez. Le recomendamos reforzar matemáticas en casa con ejercicios cortos diarios. Podemos coordinar un plan juntos.',
    time: DateTime(2026, 3, 29, 14, 20),
    isFromCounselor: true,
  ),
];
