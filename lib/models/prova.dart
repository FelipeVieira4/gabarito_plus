import 'package:gabarito_plus/models/questao.dart';
import 'package:gabarito_plus/models/turma.dart';

class Prova {
  final String id;
  final String titulo;
  final Turma turma;
  final List<Questao> questoes;
  final bool embaralharQuestoes;
  final bool embaralharAlternativas;

  Prova({
    required this.id,
    required this.titulo,
    required this.turma,
    required this.questoes,
    required this.embaralharQuestoes,
    required this.embaralharAlternativas,
  });
}
