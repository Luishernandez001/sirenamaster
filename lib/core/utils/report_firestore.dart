import 'package:cloud_firestore/cloud_firestore.dart';

/// Ordena por `fechaHora` (más reciente primero). Documentos sin campo o con
/// tipo inesperado van al final. Evita depender de `orderBy` en Firestore (índices
/// y datos legacy en prototipos).
void sortReportDocsByFechaDesc(List<QueryDocumentSnapshot<Object?>> docs) {
  int millis(QueryDocumentSnapshot<Object?> d) {
    final data = d.data();
    if (data is! Map<String, dynamic>) return 0;
    final fh = data['fechaHora'];
    if (fh is Timestamp) return fh.millisecondsSinceEpoch;
    return 0;
  }

  docs.sort((a, b) => millis(b).compareTo(millis(a)));
}

Future<List<QueryDocumentSnapshot<Object?>>> fetchSortedReportDocs() async {
  final snapshot = await FirebaseFirestore.instance.collection('reportes').get();
  final docs = List<QueryDocumentSnapshot<Object?>>.from(snapshot.docs);
  sortReportDocsByFechaDesc(docs);
  return docs;
}
