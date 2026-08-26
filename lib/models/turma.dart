import 'package:gabarito_plus/models/aluno.dart';

class Turma {
  final String id;
  final String nomeTurma;
  final List<Aluno> listaAlunos;
  final bool ativa;

  Turma({
    required this.id,
    required this.nomeTurma,
    required this.listaAlunos,
    required this.ativa
  });
}
