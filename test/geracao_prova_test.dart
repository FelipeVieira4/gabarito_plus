import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:gabarito_plus/features/aluno/data/aluno.dart';
import 'package:gabarito_plus/features/correcao_prova/services/correcao_service.dart';
import 'package:gabarito_plus/features/disciplina/data/assunto.dart';
import 'package:gabarito_plus/features/geracao_prova/data/embaralhador.dart';
import 'package:gabarito_plus/features/geracao_prova/data/gabarito_lido.dart';
import 'package:gabarito_plus/features/geracao_prova/data/prova.dart';
import 'package:gabarito_plus/features/geracao_prova/service/prova_repository.dart';
import 'package:gabarito_plus/features/questoes/data/alternativa.dart';
import 'package:gabarito_plus/features/questoes/data/questao.dart';
import 'package:gabarito_plus/features/turma/data/turma.dart';

import 'helpers/prova_repository_memoria.dart';

void main() {
  Questao questao(String id, int correta, {int alternativas = 4}) => Questao(
        id: id,
        enunciado: 'Enunciado $id',
        alternativas: [
          for (var i = 0; i < alternativas; i++)
            Alternativa(texto: 'Alt $i', isCorreta: i == correta),
        ],
      );

  Prova provaDeTeste({bool embaralhar = false}) => Prova(
        id: 'K7Q2XM',
        titulo: 'Prova de Teste',
        turma: Turma(
          id: 'turma-1',
          nomeTurma: '3º Ano A',
          listaAlunos: [
            Aluno(id: 'aluno-a', nome: 'Ana', email: '', isAtivo: true),
            Aluno(id: 'aluno-b', nome: 'Bruno', email: '', isAtivo: true),
          ],
          ativa: true,
        ),
        assunto: Assunto(id: 'assunto-1', nome: 'Soma', questoes: const []),
        questoes: [questao('q1', 2), questao('q2', 0, alternativas: 5)],
        embaralharQuestoes: embaralhar,
        embaralharAlternativas: embaralhar,
      );

  group('gerarIdProva', () {
    test('gera 6 caracteres do alfabeto sem caracteres ambíguos', () {
      final random = Random(42);
      for (var i = 0; i < 200; i++) {
        final id = gerarIdProva(random);
        expect(id, hasLength(tamanhoCodigoProva));
        expect(id.split('').every(alfabetoCodigoProva.contains), isTrue);
      }
    });

    test('o alfabeto não tem 0, O, 1, I nem L', () {
      for (final ambiguo in ['0', 'O', '1', 'I', 'L']) {
        expect(alfabetoCodigoProva.contains(ambiguo), isFalse);
      }
    });
  });

  group('Embaralhador', () {
    test('código da versão é o id da prova mais a posição do aluno', () {
      final versoes = Embaralhador.gerarVersoes(provaDeTeste(embaralhar: true));

      expect(versoes.map((v) => v.codigo), ['K7Q2XM-01', 'K7Q2XM-02']);
      expect(versoes.map((v) => v.aluno.nome), ['Ana', 'Bruno']);
    });
  });

  group('GabaritoLido.daVersao', () {
    test('usa as respostas da versão e os dados da prova', () {
      final prova = provaDeTeste();
      final versao = Embaralhador.gerarVersoes(prova).last;

      final gabarito = GabaritoLido.daVersao(
        provaId: prova.id,
        dadosProva: prova.toMap(),
        versao: versao,
      );

      expect(gabarito.codigoVersao, 'K7Q2XM-02');
      expect(gabarito.provaId, 'K7Q2XM');
      expect(gabarito.turmaId, 'turma-1');
      expect(gabarito.alunoId, 'aluno-b');
      expect(gabarito.tituloProva, 'Prova de Teste');
      expect(gabarito.nomeTurma, '3º Ano A');
      expect(gabarito.nomeAluno, 'Bruno');
      expect(gabarito.respostasCorretas, [2, 0]);
      // a maior questão tem 5 alternativas
      expect(gabarito.quantidadeAlternativas, 5);
    });
  });

  group('ProvaRepository (memória)', () {
    test('encontra o gabarito pelo código, sem diferenciar maiúsculas', () async {
      final repositorio = ProvaRepositoryMemoria();
      final prova = provaDeTeste();
      await repositorio.salvar(prova, Embaralhador.gerarVersoes(prova));

      final gabarito = await repositorio.buscarGabarito(' k7q2xm-01 ');

      expect(gabarito, isNotNull);
      expect(gabarito!.nomeAluno, 'Ana');
      expect(await repositorio.buscarGabarito('K7Q2XM-99'), isNull);
    });

    test('recusa salvar duas provas com o mesmo código', () async {
      final repositorio = ProvaRepositoryMemoria();
      final prova = provaDeTeste();
      await repositorio.salvar(prova, Embaralhador.gerarVersoes(prova));

      await expectLater(
        repositorio.salvar(prova, Embaralhador.gerarVersoes(prova)),
        throwsStateError,
      );
    });
  });

  test('CorrecaoService leva prova, turma e aluno do gabarito para a correção',
      () {
    final gabarito = GabaritoLido(
      codigoVersao: 'K7Q2XM-01',
      provaId: 'K7Q2XM',
      turmaId: 'turma-1',
      alunoId: 'aluno-a',
      tituloProva: 'Prova de Teste',
      nomeTurma: '3º Ano A',
      nomeAluno: 'Ana',
      respostasCorretas: [2, 0],
      quantidadeAlternativas: 4,
    );

    final correcao = CorrecaoService().corrigir(
      gabarito: gabarito,
      folha: FolhaLida(codigoVersao: 'K7Q2XM-01', respostasMarcadas: [2, 1]),
    );

    expect(correcao.provaId, 'K7Q2XM');
    expect(correcao.turmaId, 'turma-1');
    expect(correcao.alunoId, 'aluno-a');
    expect(correcao.acertos, 1);
  });
}
