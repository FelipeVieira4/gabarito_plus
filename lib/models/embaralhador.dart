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
        
        final alternativasEmbaralhadas = List.of(questao.alternativas);

        if (prova.embaralharAlternativas) {
          alternativasEmbaralhadas.shuffle(random);
        }

        final indexCorreta = alternativasEmbaralhadas.indexWhere((alt) => alt.isCorreta);

        return QuestaoEmbaralhada(
          questao: questao,
        alternativas: alternativasEmbaralhadas.map((alt) => alt.texto).toList(),
          respostaCorreta: indexCorreta,
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
