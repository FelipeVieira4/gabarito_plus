import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gabarito_plus/features/questoes/data/alternativa.dart';

class Questao {
  final String id;
  final String enunciado;
  final List<Alternativa> alternativas;

  Questao({
    required this.id,
    required this.enunciado,
    required this.alternativas,
  });

  factory Questao.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final alternativas = (data['alternativas'] as List<dynamic>? ?? [])
        .map((a) => Alternativa.fromMap(Map<String, dynamic>.from(a as Map)))
        .toList();

    return Questao(
      id: doc.id,
      enunciado: data['enunciado'] ?? '',
      alternativas: alternativas,
    );
  }

  Map<String, dynamic> toMap({
    required String disciplinaId,
    required String assuntoId,
  }) =>
      {
        'enunciado': enunciado,
        'alternativas': alternativas.map((a) => a.toMap()).toList(),
        'disciplinaId': disciplinaId,
        'assuntoId': assuntoId,
      };
}
