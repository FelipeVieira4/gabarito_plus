import 'dart:math';

import 'package:gabarito_plus/features/geracao_prova/data/prova.dart';
import 'package:gabarito_plus/features/geracao_prova/data/versao_prova.dart';

class Embaralhador {
  static List<VersaoProva> gerarVersoes(Prova prova) {
    final random = Random();

    final alunos = prova.turma.listaAlunos;

    return List.generate(alunos.length, (indice) {
      final aluno = alunos[indice];
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

      // O código começa com o id da prova: a câmera encontra a versão
      // em provas/{provaId}/versoes/{codigo} sem precisar de busca.
      return VersaoProva(
        codigo: '${prova.id}-${(indice + 1).toString().padLeft(2, '0')}',
        aluno: aluno,
        questoes: questoesEmbaralhadas,
      );
    });
  }
}
