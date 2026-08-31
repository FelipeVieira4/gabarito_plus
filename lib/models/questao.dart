import 'alternativa.dart';

class Questao {
  final String id;
  final String enunciado;
  final String disciplina;
  final String assunto;
  final List<Alternativa> alternativas;

  Questao({
    required this.id,
    required this.enunciado,
    required this.disciplina,
    required this.assunto,
    required this.alternativas,
  });
}