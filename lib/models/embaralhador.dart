import 'dart:math';

import 'package:gabarito_plus/models/prova.dart';
import 'package:gabarito_plus/models/versao_prova.dart';

class Embaralhador {
  static List<VersaoProva> gerarVersoes(Prova prova) {
    final random = Random();

    return prova.turma.listaAlunos.map((aluno) {
      final questoes = List.of(prova.questoes);
      if (prova.embaralharQuestoes) {
        questoes.shuffle(random);
      }

      final questoesEmbaralhadas = questoes.map((questao) {
        final indices = List.generate(questao.alternativas.length, (i) => i);
        if (prova.embaralharAlternativas) {
          indices.shuffle(random);
        }

        return QuestaoEmbaralhada(
          questao: questao,
          alternativas: indices.map((i) => questao.alternativas[i]).toList(),
          respostaCorreta: indices.indexOf(questao.respostaCorreta),
        );
      }).toList();

      return VersaoProva(
        codigo: '${prova.id.toUpperCase()}-${aluno.id.padLeft(3, '0')}',
        aluno: aluno,
        questoes: questoesEmbaralhadas,
      );
    }).toList();
  }
}
