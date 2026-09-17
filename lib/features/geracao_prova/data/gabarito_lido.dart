
String letraAlternativa(int? indice) {
  if (indice == null) return '—';
  return String.fromCharCode(65 + indice);
}


class GabaritoLido {
  final String codigoVersao;
  final String tituloProva;
  final String nomeTurma;
  final String nomeAluno;

  final List<int> respostasCorretas;

  final int quantidadeAlternativas;

  GabaritoLido({
    required this.codigoVersao,
    required this.tituloProva,
    required this.nomeTurma,
    required this.nomeAluno,
    required this.respostasCorretas,
    required this.quantidadeAlternativas,
  });

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
