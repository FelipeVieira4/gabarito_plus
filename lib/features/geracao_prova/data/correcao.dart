import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String provaId;
  final String turmaId;
  final String alunoId;
  final String tituloProva;
  final String nomeTurma;
  final String nomeAluno;
  final List<RespostaMarcada> respostas;

  final int quantidadeAlternativas;

  final DateTime dataHora;

  Correcao({
    required this.codigoVersao,
    this.provaId = '',
    this.turmaId = '',
    this.alunoId = '',
    required this.tituloProva,
    required this.nomeTurma,
    required this.nomeAluno,
    required this.respostas,
    required this.quantidadeAlternativas,
    required this.dataHora,
  });

  factory Correcao.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Correcao.fromMap(doc.id, doc.data() ?? {});
  }

  /// O id do documento é o código da versão lido no QR Code.
  factory Correcao.fromMap(String codigoVersao, Map<String, dynamic> data) {
    final marcadas = List<int?>.from(data['respostasMarcadas'] ?? []);
    final corretas = List<int>.from(data['respostasCorretas'] ?? []);
    final dataHora = data['dataHora'];

    return Correcao(
      codigoVersao: codigoVersao,
      provaId: data['provaId'] ?? '',
      turmaId: data['turmaId'] ?? '',
      alunoId: data['alunoId'] ?? '',
      tituloProva: data['tituloProva'] ?? '',
      nomeTurma: data['nomeTurma'] ?? '',
      nomeAluno: data['nomeAluno'] ?? '',
      respostas: [
        for (var i = 0; i < corretas.length; i++)
          RespostaMarcada(
            numeroQuestao: i + 1,
            indiceMarcado: i < marcadas.length ? marcadas[i] : null,
            indiceCorreto: corretas[i],
          ),
      ],
      quantidadeAlternativas: data['quantidadeAlternativas'] ?? 0,
      dataHora: dataHora is Timestamp ? dataHora.toDate() : DateTime.now(),
    );
  }

  /// Acertos, erros, em branco e nota também são gravados para que a consulta
  /// consiga filtrar e ordenar por eles (o Firestore não enxerga os getters).
  Map<String, dynamic> toMap() => {
        'provaId': provaId,
        'turmaId': turmaId,
        'alunoId': alunoId,
        'tituloProva': tituloProva,
        'nomeTurma': nomeTurma,
        'nomeAluno': nomeAluno,
        'respostasMarcadas': respostas.map((r) => r.indiceMarcado).toList(),
        'respostasCorretas': respostas.map((r) => r.indiceCorreto).toList(),
        'quantidadeAlternativas': quantidadeAlternativas,
        'acertos': acertos,
        'erros': erros,
        'emBranco': emBranco,
        'nota': nota,
        'dataHora': Timestamp.fromDate(dataHora),
      };

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
      provaId: provaId,
      turmaId: turmaId,
      alunoId: alunoId,
      tituloProva: tituloProva,
      nomeTurma: nomeTurma,
      nomeAluno: nomeAluno,
      respostas: atualizadas,
      quantidadeAlternativas: quantidadeAlternativas,
      dataHora: dataHora,
    );
  }
}
