import 'package:gabarito_plus/features/geracao_prova/data/correcao.dart';
import 'package:gabarito_plus/features/geracao_prova/data/estatistica_prova.dart';
import 'package:gabarito_plus/features/geracao_prova/data/gabarito_lido.dart';


class CorrecaoService {

  Correcao corrigir({
    required GabaritoLido gabarito,
    required FolhaLida folha,
    DateTime? dataHora,
  }) {
    if (gabarito.codigoVersao != folha.codigoVersao) {
      throw ArgumentError(
        'A folha lida (${folha.codigoVersao}) não é a folha do gabarito '
        'escaneado (${gabarito.codigoVersao})',
      );
    }

    if (gabarito.totalQuestoes != folha.totalQuestoes) {
      throw ArgumentError(
        'O gabarito tem ${gabarito.totalQuestoes} questões, mas a folha lida '
        'trouxe ${folha.totalQuestoes}',
      );
    }

    final respostas = <RespostaMarcada>[];

    for (var i = 0; i < gabarito.totalQuestoes; i++) {
      final marcado = folha.respostasMarcadas[i];

      final marcadoValido = marcado != null &&
              marcado >= 0 &&
              marcado < gabarito.quantidadeAlternativas
          ? marcado
          : null;

      respostas.add(
        RespostaMarcada(
          numeroQuestao: i + 1,
          indiceMarcado: marcadoValido,
          indiceCorreto: gabarito.respostasCorretas[i],
        ),
      );
    }

    return Correcao(
      codigoVersao: gabarito.codigoVersao,
      tituloProva: gabarito.tituloProva,
      nomeTurma: gabarito.nomeTurma,
      nomeAluno: gabarito.nomeAluno,
      respostas: respostas,
      quantidadeAlternativas: gabarito.quantidadeAlternativas,
      dataHora: dataHora ?? DateTime.now(),
    );
  }

  ResumoTurma resumoDaTurma(
    List<Correcao> correcoes, {
    double notaCorte = 6.0,
  }) {
    if (correcoes.isEmpty) return ResumoTurma.vazio(notaCorte: notaCorte);

    final notas = correcoes.map((correcao) => correcao.nota).toList()..sort();
    final soma = notas.fold<double>(0, (total, nota) => total + nota);

    return ResumoTurma(
      totalCorrigidas: correcoes.length,
      media: (soma / notas.length * 10).round() / 10,
      maiorNota: notas.last,
      menorNota: notas.first,
      notaCorte: notaCorte,
      aprovados: notas.where((nota) => nota >= notaCorte).length,
      distribuicao: _montarDistribuicao(notas),
    );
  }

  List<EstatisticaQuestao> estatisticasPorQuestao(
    List<Correcao> correcoes, {
    List<String>? enunciados,
  }) {
    if (correcoes.isEmpty) return [];

    final referencia = correcoes.first;
    final totalQuestoes = referencia.totalQuestoes;
    final quantidadeAlternativas = referencia.quantidadeAlternativas;

    final divergente = correcoes.any(
      (correcao) => correcao.totalQuestoes != totalQuestoes,
    );
    if (divergente) {
      throw ArgumentError(
        'As correções têm quantidades diferentes de questões e não podem ser '
        'somadas na mesma estatística',
      );
    }

    final estatisticas = <EstatisticaQuestao>[];

    for (var numero = 1; numero <= totalQuestoes; numero++) {
      final marcacoes = List<int>.filled(quantidadeAlternativas, 0);
      var emBranco = 0;

      for (final correcao in correcoes) {
        final resposta = correcao.respostaDaQuestao(numero);
        if (resposta.indiceMarcado == null) {
          emBranco++;
        } else {
          marcacoes[resposta.indiceMarcado!]++;
        }
      }

      estatisticas.add(
        EstatisticaQuestao(
          numeroQuestao: numero,
          enunciado: _enunciadoDe(enunciados, numero),
          indiceCorreta: referencia.respostaDaQuestao(numero).indiceCorreto,
          marcacoesPorAlternativa: marcacoes,
          emBranco: emBranco,
        ),
      );
    }

    return estatisticas;
  }

  List<EstatisticaQuestao> questoesMaisErradas(
    List<Correcao> correcoes, {
    List<String>? enunciados,
  }) {
    final estatisticas = estatisticasPorQuestao(
      correcoes,
      enunciados: enunciados,
    );

    estatisticas.sort((a, b) {
      final comparacao = a.percentualAcerto.compareTo(b.percentualAcerto);
      return comparacao != 0
          ? comparacao
          : a.numeroQuestao.compareTo(b.numeroQuestao);
    });

    return estatisticas;
  }

  List<Correcao> ordenadasPorNota(List<Correcao> correcoes) {
    final ordenadas = List<Correcao>.of(correcoes);

    ordenadas.sort((a, b) {
      final comparacao = b.nota.compareTo(a.nota);
      return comparacao != 0 ? comparacao : a.nomeAluno.compareTo(b.nomeAluno);
    });

    return ordenadas;
  }

  String _enunciadoDe(List<String>? enunciados, int numeroQuestao) {
    if (enunciados == null || numeroQuestao > enunciados.length) {
      return 'Questão $numeroQuestao';
    }
    return enunciados[numeroQuestao - 1];
  }

  List<FaixaNota> _montarDistribuicao(List<double> notas) {
    const limites = [
      [0.0, 2.0],
      [2.0, 4.0],
      [4.0, 6.0],
      [6.0, 8.0],
      [8.0, 10.0],
    ];

    return limites.map((faixa) {
      final minimo = faixa[0];
      final maximo = faixa[1];
      final ultimaFaixa = maximo == 10.0;

      final quantidade = notas.where((nota) {
        final dentroDoTeto = ultimaFaixa ? nota <= maximo : nota < maximo;
        return nota >= minimo && dentroDoTeto;
      }).length;

      return FaixaNota(
        rotulo: '${minimo.toStringAsFixed(0)} - ${maximo.toStringAsFixed(0)}',
        minimo: minimo,
        maximo: maximo,
        quantidade: quantidade,
      );
    }).toList();
  }
}
