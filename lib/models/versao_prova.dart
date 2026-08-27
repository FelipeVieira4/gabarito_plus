import 'package:gabarito_plus/models/aluno.dart';
import 'package:gabarito_plus/models/questao.dart';

class QuestaoEmbaralhada {
  final Questao questao;
  final List<String> alternativas;
  final int respostaCorreta;

  QuestaoEmbaralhada({
    required this.questao,
    required this.alternativas,
    required this.respostaCorreta,
  });
}

class VersaoProva {
  final String codigo;
  final Aluno aluno;
  final List<QuestaoEmbaralhada> questoes;

  VersaoProva({
    required this.codigo,
    required this.aluno,
    required this.questoes,
  });
}
