class Questao {
  final String id;
  final String enunciado;
  final List<String> alternativas;
  final int respostaCorreta;

  Questao({
    required this.id,
    required this.enunciado,
    required this.alternativas,
    required this.respostaCorreta,
  });
}
