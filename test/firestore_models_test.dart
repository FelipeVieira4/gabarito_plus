import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabarito_plus/features/aluno/data/aluno.dart';
import 'package:gabarito_plus/features/disciplina/data/assunto.dart';
import 'package:gabarito_plus/features/geracao_prova/data/correcao.dart';
import 'package:gabarito_plus/features/geracao_prova/data/prova.dart';
import 'package:gabarito_plus/features/geracao_prova/data/versao_prova.dart';
import 'package:gabarito_plus/features/questoes/data/alternativa.dart';
import 'package:gabarito_plus/features/questoes/data/questao.dart';
import 'package:gabarito_plus/features/turma/data/turma.dart';

void main() {
  final aluno = Aluno(
    id: 'aluno-1',
    nome: 'Maria',
    email: 'maria@escola.com',
    isAtivo: true,
  );

  final questao = Questao(
    id: 'questao-1',
    enunciado: 'Quanto é 2 + 2?',
    alternativas: [
      Alternativa(texto: '3', isCorreta: false),
      Alternativa(texto: '4', isCorreta: true),
      Alternativa(texto: '5', isCorreta: false),
    ],
  );

  final embaralhada = QuestaoEmbaralhada(
    questao: questao,
    alternativas: ['5', '3', '4'],
    respostaCorreta: 2,
  );

  Correcao correcaoDeTeste() => Correcao(
        codigoVersao: 'PROVA1-ALUNO1',
        provaId: 'prova-1',
        turmaId: 'turma-1',
        alunoId: 'aluno-1',
        tituloProva: 'Prova de Matemática',
        nomeTurma: '3º Ano A',
        nomeAluno: 'Maria',
        respostas: [
          RespostaMarcada(numeroQuestao: 1, indiceMarcado: 0, indiceCorreto: 0),
          RespostaMarcada(numeroQuestao: 2, indiceMarcado: 3, indiceCorreto: 1),
          RespostaMarcada(numeroQuestao: 3, indiceMarcado: null, indiceCorreto: 2),
          RespostaMarcada(numeroQuestao: 4, indiceMarcado: 3, indiceCorreto: 3),
        ],
        quantidadeAlternativas: 4,
        dataHora: DateTime(2026, 10, 20, 14, 30),
      );

  group('Prova.toMap', () {
    test('guarda turma, assunto e questões por id, com os nomes copiados', () {
      final prova = Prova(
        id: 'prova-1',
        titulo: 'Prova de Matemática',
        turma: Turma(
          id: 'turma-1',
          nomeTurma: '3º Ano A',
          listaAlunos: [aluno],
          ativa: true,
        ),
        assunto: Assunto(id: 'assunto-1', nome: 'Soma', questoes: [questao]),
        questoes: [questao],
        embaralharQuestoes: true,
        embaralharAlternativas: false,
      );

      final map = prova.toMap();

      expect(map.containsKey('id'), isFalse);
      expect(map['titulo'], 'Prova de Matemática');
      expect(map['turmaId'], 'turma-1');
      expect(map['nomeTurma'], '3º Ano A');
      expect(map['assuntoId'], 'assunto-1');
      expect(map['nomeAssunto'], 'Soma');
      expect(map['questoesIds'], ['questao-1']);
      expect(map['embaralharQuestoes'], isTrue);
      expect(map['embaralharAlternativas'], isFalse);
      expect(map['criadaEm'], isA<FieldValue>());
    });
  });

  group('QuestaoEmbaralhada', () {
    test('toMap guarda uma cópia do enunciado e das alternativas embaralhadas', () {
      expect(embaralhada.toMap(), {
        'questaoId': 'questao-1',
        'enunciado': 'Quanto é 2 + 2?',
        'alternativas': ['5', '3', '4'],
        'respostaCorreta': 2,
      });
    });

    test('fromMap remonta a questão marcando a alternativa correta', () {
      final lida = QuestaoEmbaralhada.fromMap(embaralhada.toMap());

      expect(lida.questao.id, 'questao-1');
      expect(lida.questao.enunciado, 'Quanto é 2 + 2?');
      expect(lida.alternativas, ['5', '3', '4']);
      expect(lida.respostaCorreta, 2);
      expect(
        lida.questao.alternativas.map((a) => a.isCorreta).toList(),
        [false, false, true],
      );
    });
  });

  group('VersaoProva', () {
    test('ida e volta preserva aluno e questões', () {
      final versao = VersaoProva(
        codigo: 'PROVA1-ALUNO1',
        aluno: aluno,
        questoes: [embaralhada],
      );

      final map = versao.toMap();
      final lida = VersaoProva.fromMap(versao.codigo, map);

      expect(map.containsKey('codigo'), isFalse);
      expect(map['alunoId'], 'aluno-1');
      expect(map['nomeAluno'], 'Maria');
      expect(lida.codigo, 'PROVA1-ALUNO1');
      expect(lida.aluno.id, 'aluno-1');
      expect(lida.aluno.nome, 'Maria');
      expect(lida.questoes, hasLength(1));
      expect(lida.questoes.single.respostaCorreta, 2);
    });

    test('documento vazio não quebra a leitura', () {
      final lida = VersaoProva.fromMap('X', {});

      expect(lida.aluno.nome, '');
      expect(lida.questoes, isEmpty);
    });
  });

  group('Correcao', () {
    test('toMap grava respostas em arrays paralelos, com branco como null', () {
      final map = correcaoDeTeste().toMap();

      expect(map['respostasMarcadas'], [0, 3, null, 3]);
      expect(map['respostasCorretas'], [0, 1, 2, 3]);
    });

    test('toMap grava os valores calculados e a data como Timestamp', () {
      final map = correcaoDeTeste().toMap();

      expect(map['acertos'], 2);
      expect(map['erros'], 1);
      expect(map['emBranco'], 1);
      expect(map['nota'], 5.0);
      expect(map['dataHora'], Timestamp.fromDate(DateTime(2026, 10, 20, 14, 30)));
      expect(map.containsKey('codigoVersao'), isFalse);
    });

    test('ida e volta preserva todos os campos', () {
      final original = correcaoDeTeste();
      final lida = Correcao.fromMap(original.codigoVersao, original.toMap());

      expect(lida.codigoVersao, 'PROVA1-ALUNO1');
      expect(lida.provaId, 'prova-1');
      expect(lida.turmaId, 'turma-1');
      expect(lida.alunoId, 'aluno-1');
      expect(lida.tituloProva, 'Prova de Matemática');
      expect(lida.nomeTurma, '3º Ano A');
      expect(lida.nomeAluno, 'Maria');
      expect(lida.quantidadeAlternativas, 4);
      expect(lida.dataHora, DateTime(2026, 10, 20, 14, 30));
      expect(lida.acertos, original.acertos);
      expect(lida.emBranco, original.emBranco);
      expect(lida.nota, original.nota);
      expect(lida.respostaDaQuestao(3).emBranco, isTrue);
    });

    test('comRespostaAlterada mantém provaId, turmaId e alunoId', () {
      final alterada = correcaoDeTeste().comRespostaAlterada(3, 2);

      expect(alterada.provaId, 'prova-1');
      expect(alterada.turmaId, 'turma-1');
      expect(alterada.alunoId, 'aluno-1');
      expect(alterada.acertos, 3);
    });

    test('ids de prova, turma e aluno são opcionais', () {
      final correcao = Correcao(
        codigoVersao: 'X',
        tituloProva: '',
        nomeTurma: '',
        nomeAluno: '',
        respostas: const [],
        quantidadeAlternativas: 4,
        dataHora: DateTime(2026),
      );

      expect(correcao.toMap()['provaId'], '');
    });
  });
}
