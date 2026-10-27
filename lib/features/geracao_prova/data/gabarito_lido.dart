import 'package:gabarito_plus/features/geracao_prova/data/versao_prova.dart';


String letraAlternativa(int? indice) {
  if (indice == null) return '—';
  return String.fromCharCode(65 + indice);
}


class GabaritoLido {
  final String codigoVersao;
  final String provaId;
  final String turmaId;
  final String alunoId;
  final String tituloProva;
  final String nomeTurma;
  final String nomeAluno;

  final List<int> respostasCorretas;

  final int quantidadeAlternativas;

  GabaritoLido({
    required this.codigoVersao,
    this.provaId = '',
    this.turmaId = '',
    this.alunoId = '',
    required this.tituloProva,
    required this.nomeTurma,
    required this.nomeAluno,
    required this.respostasCorretas,
    required this.quantidadeAlternativas,
  });

  /// Monta o gabarito de uma versão salva. [dadosProva] é o documento da
  /// prova no Firestore (o mesmo formato de `Prova.toMap()`).
  factory GabaritoLido.daVersao({
    required String provaId,
    required Map<String, dynamic> dadosProva,
    required VersaoProva versao,
  }) {
    final maiorQuantidade = versao.questoes.fold<int>(
      0,
      (maior, q) => q.alternativas.length > maior ? q.alternativas.length : maior,
    );

    return GabaritoLido(
      codigoVersao: versao.codigo,
      provaId: provaId,
      turmaId: dadosProva['turmaId'] ?? '',
      alunoId: versao.aluno.id,
      tituloProva: dadosProva['titulo'] ?? '',
      nomeTurma: dadosProva['nomeTurma'] ?? '',
      nomeAluno: versao.aluno.nome,
      respostasCorretas: versao.questoes.map((q) => q.respostaCorreta).toList(),
      quantidadeAlternativas: maiorQuantidade,
    );
  }

  int get totalQuestoes => respostasCorretas.length;
}

class FolhaLida {
  final String codigoVersao;
  final List<int?> respostasMarcadas;

  FolhaLida({
    required this.codigoVersao,
    required this.respostasMarcadas,
  });

  int get totalQuestoes => respostasMarcadas.length;

  int get totalEmBranco =>
      respostasMarcadas.where((resposta) => resposta == null).length;
}
