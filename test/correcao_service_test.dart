import 'package:flutter_test/flutter_test.dart';
import 'package:gabarito_plus/mocks/mock_correcao.dart';
import 'package:gabarito_plus/mocks/mock_leitura.dart';
import 'package:gabarito_plus/models/gabarito_lido.dart';
import 'package:gabarito_plus/services/correcao_service.dart';

void main() {
  final service = CorrecaoService();

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
    test('apura média, extremos e aprovação da turma mockada', () {
      final resumo = service.resumoDaTurma(correcoesMock);

      expect(resumo.totalCorrigidas, 8);
      expect(resumo.media, 6.5);
      expect(resumo.maiorNota, 10.0);
      expect(resumo.menorNota, 3.0);
      expect(resumo.aprovados, 5);
      expect(resumo.reprovados, 3);
    });

    test('distribui todas as notas entre as faixas, sem perder nenhuma', () {
      final resumo = service.resumoDaTurma(correcoesMock);
      final somaDasFaixas = resumo.distribuicao
          .fold<int>(0, (total, faixa) => total + faixa.quantidade);

      expect(somaDasFaixas, correcoesMock.length);
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
        correcoesMock,
        enunciados: enunciadosMock,
      );
      final questao6 = estatisticas[5];

      expect(questao6.marcacoesPorAlternativa, [0, 6, 1, 1]);
      expect(questao6.totalCorrecoes, correcoesMock.length);
      expect(questao6.acertos, 1);
      expect(questao6.enunciado, enunciadosMock[5]);
    });

    test('identifica a alternativa errada mais marcada', () {
      final estatisticas = service.estatisticasPorQuestao(correcoesMock);
      final questao6 = estatisticas[5];

      // Quase toda a turma marcou "Python" em vez de "Dart".
      expect(questao6.distratorMaisMarcado, 1);
      expect(questao6.marcacoesDoDistrator, 6);
      expect(alternativasMock[5][questao6.distratorMaisMarcado!], 'Python');
    });

    test('não aponta distrator quando a turma inteira acertou', () {
      final estatisticas = service.estatisticasPorQuestao(correcoesMock);
      final questao1 = estatisticas[0];

      expect(questao1.acertos, 7);
      expect(questao1.distratorMaisMarcado, 0);
    });

    test('contabiliza questões em branco fora das alternativas', () {
      final estatisticas = service.estatisticasPorQuestao(correcoesMock);
      final questao3 = estatisticas[2];

      expect(questao3.emBranco, 1);
      expect(questao3.acertos, 2);
      expect(questao3.erros, 5);
      expect(
        questao3.acertos + questao3.erros + questao3.emBranco,
        correcoesMock.length,
      );
    });

    test('ordena as questões da mais errada para a menos errada', () {
      final ordenadas = service.questoesMaisErradas(correcoesMock);

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
      final ordenadas = service.ordenadasPorNota(correcoesMock);

      expect(ordenadas.first.nomeAluno, 'Ana Maria');
      expect(ordenadas.first.nota, 10.0);
      expect(ordenadas.last.nota, 3.0);
    });
  });

  group('mocks de leitura', () {
    test('busca por código encontra o gabarito e a folha do mesmo aluno', () {
      final gabarito = gabaritoMockPorCodigo('es2025a-002');
      final folha = folhaMockPorCodigo('ES2025A-002');

      expect(gabarito?.nomeAluno, 'Ana Maria');
      expect(folha?.codigoVersao, gabarito?.codigoVersao);
    });

    test('código inexistente devolve null', () {
      expect(gabaritoMockPorCodigo('NAO-EXISTE'), isNull);
    });

    test('simulação percorre a turma e volta ao primeiro aluno', () {
      reiniciarSimulacaoDeLeitura();

      final percorridos = List.generate(
        gabaritosLidosMock.length,
        (_) => proximoGabaritoSimulado().nomeAluno,
      );

      expect(percorridos.first, 'José Perreira');
      expect(percorridos.toSet().length, gabaritosLidosMock.length);
      expect(proximoGabaritoSimulado().nomeAluno, 'José Perreira');
    });
  });

  test('letra da alternativa acompanha o índice, e branco vira traço', () {
    expect(letraAlternativa(0), 'A');
    expect(letraAlternativa(3), 'D');
    expect(letraAlternativa(null), '—');
  });
}
