import 'package:flutter_test/flutter_test.dart';
import 'package:gabarito_plus/features/correcao_prova/services/correcao_service.dart';
import 'package:gabarito_plus/features/geracao_prova/data/gabarito_lido.dart';

import 'helpers/fixtures_correcao.dart';

void main() {
  final service = CorrecaoService();
  final correcoes = gerarCorrecoesDeTeste();

  GabaritoLido gabaritoDe(List<int> corretas) => GabaritoLido(
        codigoVersao: 'TESTE-001',
        tituloProva: 'Prova de teste',
        nomeTurma: 'Turma de teste',
        nomeAluno: 'Aluno de teste',
        respostasCorretas: corretas,
        quantidadeAlternativas: 4,
      );

  FolhaLida folhaDe(List<int?> marcadas, {String codigo = 'TESTE-001'}) =>
      FolhaLida(codigoVersao: codigo, respostasMarcadas: marcadas);

  group('corrigir', () {
    test('conta acertos, erros e questões em branco separadamente', () {
      final correcao = service.corrigir(
        gabarito: gabaritoDe([0, 1, 2, 3]),
        folha: folhaDe([0, 1, 3, null]),
      );

      expect(correcao.acertos, 2);
      expect(correcao.erros, 1);
      expect(correcao.emBranco, 1);
      expect(correcao.nota, 5.0);
    });

    test('trata marcação fora do intervalo de alternativas como em branco', () {
      final correcao = service.corrigir(
        gabarito: gabaritoDe([0, 1]),
        folha: folhaDe([0, 9]),
      );

      expect(correcao.acertos, 1);
      expect(correcao.emBranco, 1);
      expect(correcao.erros, 0);
    });

    test('recusa folha de outra prova', () {
      expect(
        () => service.corrigir(
          gabarito: gabaritoDe([0, 1]),
          folha: folhaDe([0, 1], codigo: 'OUTRA-002'),
        ),
        throwsArgumentError,
      );
    });

    test('recusa folha com quantidade de questões diferente do gabarito', () {
      expect(
        () => service.corrigir(
          gabarito: gabaritoDe([0, 1, 2]),
          folha: folhaDe([0, 1]),
        ),
        throwsArgumentError,
      );
    });
  });

  group('correção manual na conferência', () {
    test('trocar a marcação recalcula a nota', () {
      final correcao = service.corrigir(
        gabarito: gabaritoDe([0, 1]),
        folha: folhaDe([0, 0]),
      );
      expect(correcao.nota, 5.0);

      final ajustada = correcao.comRespostaAlterada(2, 1);

      expect(ajustada.nota, 10.0);
      expect(correcao.nota, 5.0, reason: 'a correção original não muda');
    });

    test('marcar como em branco remove o acerto', () {
      final correcao = service
          .corrigir(gabarito: gabaritoDe([0, 1]), folha: folhaDe([0, 1]))
          .comRespostaAlterada(1, null);

      expect(correcao.acertos, 1);
      expect(correcao.emBranco, 1);
    });

    test('recusa alternativa que não existe na prova', () {
      final correcao = service.corrigir(
        gabarito: gabaritoDe([0, 1]),
        folha: folhaDe([0, 1]),
      );

      expect(() => correcao.comRespostaAlterada(1, 7), throwsArgumentError);
    });
  });

  group('resumo da turma', () {
    test('apura média, extremos e aprovação da turma de teste', () {
      final resumo = service.resumoDaTurma(correcoes);

      expect(resumo.totalCorrigidas, 8);
      expect(resumo.media, 6.5);
      expect(resumo.maiorNota, 10.0);
      expect(resumo.menorNota, 3.0);
      expect(resumo.aprovados, 5);
      expect(resumo.reprovados, 3);
    });

    test('distribui todas as notas entre as faixas, sem perder nenhuma', () {
      final resumo = service.resumoDaTurma(correcoes);
      final somaDasFaixas = resumo.distribuicao
          .fold<int>(0, (total, faixa) => total + faixa.quantidade);

      expect(somaDasFaixas, correcoes.length);
    });

    test('turma sem correções não quebra', () {
      final resumo = service.resumoDaTurma([]);

      expect(resumo.totalCorrigidas, 0);
      expect(resumo.media, 0);
      expect(resumo.percentualAprovacao, 0);
    });
  });

  group('estatísticas por questão', () {
    test('conta as marcações de cada alternativa', () {
      final estatisticas = service.estatisticasPorQuestao(
        correcoes,
        enunciados: enunciadosTeste,
      );
      final questao6 = estatisticas[5];

      expect(questao6.marcacoesPorAlternativa, [0, 6, 1, 1]);
      expect(questao6.totalCorrecoes, correcoes.length);
      expect(questao6.acertos, 1);
      expect(questao6.enunciado, enunciadosTeste[5]);
    });

    test('identifica a alternativa errada mais marcada', () {
      final estatisticas = service.estatisticasPorQuestao(correcoes);
      final questao6 = estatisticas[5];

      expect(questao6.distratorMaisMarcado, 1);
      expect(questao6.marcacoesDoDistrator, 6);
    });

    test('não aponta distrator quando a turma inteira acertou', () {
      final estatisticas = service.estatisticasPorQuestao(correcoes);
      final questao1 = estatisticas[0];

      expect(questao1.acertos, 7);
      expect(questao1.distratorMaisMarcado, 0);
    });

    test('contabiliza questões em branco fora das alternativas', () {
      final estatisticas = service.estatisticasPorQuestao(correcoes);
      final questao3 = estatisticas[2];

      expect(questao3.emBranco, 1);
      expect(questao3.acertos, 2);
      expect(questao3.erros, 5);
      expect(
        questao3.acertos + questao3.erros + questao3.emBranco,
        correcoes.length,
      );
    });

    test('ordena as questões da mais errada para a menos errada', () {
      final ordenadas = service.questoesMaisErradas(correcoes);

      expect(ordenadas.first.numeroQuestao, 6);
      expect(
        ordenadas.first.percentualAcerto <= ordenadas.last.percentualAcerto,
        isTrue,
      );
    });

    test('lista vazia devolve estatística vazia', () {
      expect(service.estatisticasPorQuestao([]), isEmpty);
    });
  });

  group('ordenação por nota', () {
    test('lista da maior para a menor nota', () {
      final ordenadas = service.ordenadasPorNota(correcoes);

      expect(ordenadas.first.nomeAluno, 'Ana Maria');
      expect(ordenadas.first.nota, 10.0);
      expect(ordenadas.last.nota, 3.0);
    });
  });

  test('letra da alternativa acompanha o índice, e branco vira traço', () {
    expect(letraAlternativa(0), 'A');
    expect(letraAlternativa(3), 'D');
    expect(letraAlternativa(null), '—');
  });
}