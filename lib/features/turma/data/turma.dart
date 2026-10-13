import 'package:gabarito_plus/features/aluno/data/aluno.dart';

class Turma {
  final String id;
  final String nomeTurma;
  final List<Aluno> listaAlunos;
  final bool ativa;

  Turma({
    required this.id,
    required this.nomeTurma,
    required this.listaAlunos,
    required this.ativa,
  });

  /// Formato salvo no Firestore (o id fica no documento, não nos campos).
  Map<String, dynamic> toMap() => {
        'nomeTurma': nomeTurma,
        'ativa': ativa,
        'alunosIds': listaAlunos.map((a) => a.id).toList(),
      };
}