
class RespostaMarcada {
  final int numeroQuestao;

  final int? indiceMarcado;

  final int indiceCorreto;

  RespostaMarcada({
    required this.numeroQuestao,
    required this.indiceMarcado,
    required this.indiceCorreto,
  });

  bool get emBranco => indiceMarcado == null;

  bool get acertou => indiceMarcado != null && indiceMarcado == indiceCorreto;

  bool get errou => indiceMarcado != null && indiceMarcado != indiceCorreto;

  RespostaMarcada copyWith({int? indiceMarcado, bool limparMarcacao = false}) {
    return RespostaMarcada(
      numeroQuestao: numeroQuestao,
      indiceMarcado: limparMarcacao ? null : (indiceMarcado ?? this.indiceMarcado),
      indiceCorreto: indiceCorreto,
    );
  }
}

class Correcao {
  final String codigoVersao;
  final String tituloProva;
  final String nomeTurma;
  final String nomeAluno;
  final List<RespostaMarcada> respostas;

  final int quantidadeAlternativas;

  final DateTime dataHora;

  Correcao({
    required this.codigoVersao,
    required this.tituloProva,
    required this.nomeTurma,
    required this.nomeAluno,
    required this.respostas,
    required this.quantidadeAlternativas,
    required this.dataHora,
  });

  int get totalQuestoes => respostas.length;

  int get acertos => respostas.where((resposta) => resposta.acertou).length;

  int get erros => respostas.where((resposta) => resposta.errou).length;

  int get emBranco => respostas.where((resposta) => resposta.emBranco).length;

  double get nota {
    if (totalQuestoes == 0) return 0;
    return ((acertos / totalQuestoes) * 100).round() / 10;
  }

  double get percentualAcerto {
    if (totalQuestoes == 0) return 0;
    return (acertos / totalQuestoes) * 100;
  }

  RespostaMarcada respostaDaQuestao(int numeroQuestao) {
    return respostas.firstWhere(
      (resposta) => resposta.numeroQuestao == numeroQuestao,
      orElse: () => throw ArgumentError(
        'Questão $numeroQuestao não existe nesta correção',
      ),
    );
  }

  Correcao comRespostaAlterada(int numeroQuestao, int? novoIndice) {
    if (novoIndice != null &&
        (novoIndice < 0 || novoIndice >= quantidadeAlternativas)) {
      throw ArgumentError(
        'Alternativa $novoIndice não existe: a prova tem '
        '$quantidadeAlternativas alternativas por questão',
      );
    }

    final atualizadas = respostas.map((resposta) {
      if (resposta.numeroQuestao != numeroQuestao) return resposta;
      return resposta.copyWith(
        indiceMarcado: novoIndice,
        limparMarcacao: novoIndice == null,
      );
    }).toList();

    return Correcao(
      codigoVersao: codigoVersao,
      tituloProva: tituloProva,
      nomeTurma: nomeTurma,
      nomeAluno: nomeAluno,
      respostas: atualizadas,
      quantidadeAlternativas: quantidadeAlternativas,
      dataHora: dataHora,
    );
  }
}
