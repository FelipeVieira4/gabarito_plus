import 'package:cloud_firestore/cloud_firestore.dart';

class Aluno {
  final String id;
  final String nome;
  final String email;
  final bool isAtivo;

  Aluno({
    required this.id,
    required this.nome,
    required this.email,
    required this.isAtivo,
  });

  factory Aluno.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Aluno(
      id: doc.id,
      nome: data['nome'] ?? '',
      email: data['email'] ?? '',
      isAtivo: data['isAtivo'] ?? true,
    );
  }

  /// O id não vai no corpo: ele é o ID do documento.
  Map<String, dynamic> toMap() => {
        'nome': nome,
        'email': email,
        'isAtivo': isAtivo,
        'nomeBusca': nome.toLowerCase(),
      };
}