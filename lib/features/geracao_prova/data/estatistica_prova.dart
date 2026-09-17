
class FaixaNota {
  final String rotulo;
  final double minimo;
  final double maximo;
  final int quantidade;

  FaixaNota({
    required this.rotulo,
    required this.minimo,
    required this.maximo,
    required this.quantidade,
  });
}

class ResumoTurma {
  final int totalCorrigidas;
  final double media;
  final double maiorNota;
  final double menorNota;

  final double notaCorte;
  final int aprovados;
  final List<FaixaNota> distribuicao;

  ResumoTurma({
    required this.totalCorrigidas,
    required this.media,
    required this.maiorNota,
    required this.menorNota,
    required this.notaCorte,
    required this.aprovados,
    required this.distribuicao,
  });

  factory ResumoTurma.vazio({double notaCorte = 6.0}) {
    return ResumoTurma(
      totalCorrigidas: 0,
      media: 0,
      maiorNota: 0,
      menorNota: 0,
      notaCorte: notaCorte,
      aprovados: 0,
      distribuicao: const [],
    );
  }

  int get reprovados => totalCorrigidas - aprovados;

  double get percentualAprovacao {
    if (totalCorrigidas == 0) return 0;
    return (aprovados / totalCorrigidas) * 100;
  }
}

class EstatisticaQuestao {
  final int numeroQuestao;
  final String enunciado;
  final int indiceCorreta;

  final List<int> marcacoesPorAlternativa;

  final int emBranco;

  EstatisticaQuestao({
    required this.numeroQuestao,
    required this.enunciado,
    required this.indiceCorreta,
    required this.marcacoesPorAlternativa,
    required this.emBranco,
  });

  int get totalCorrecoes =>
      marcacoesPorAlternativa.fold<int>(0, (soma, item) => soma + item) +
      emBranco;

  int get acertos => marcacoesPorAlternativa[indiceCorreta];

  int get erros => totalCorrecoes - acertos - emBranco;

  double get percentualAcerto {
    if (totalCorrecoes == 0) return 0;
    return (acertos / totalCorrecoes) * 100;
  }

  int? get distratorMaisMarcado {
    int? indice;
    var maior = 0;

    for (var i = 0; i < marcacoesPorAlternativa.length; i++) {
      if (i == indiceCorreta) continue;
      if (marcacoesPorAlternativa[i] > maior) {
        maior = marcacoesPorAlternativa[i];
        indice = i;
      }
    }

    return indice;
  }

  int get marcacoesDoDistrator {
    final indice = distratorMaisMarcado;
    return indice == null ? 0 : marcacoesPorAlternativa[indice];
  }
}
