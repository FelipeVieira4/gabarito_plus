import 'alternativa.dart';

class Questao {
  String _id;
  String _enunciado;
  String _disciplina;
  String _assunto;
  List<Alternativa> _alternativas;

  Questao({
    required String id,
    required String enunciado,
    required String disciplina,
    required String assunto,
    required List<Alternativa> alternativas,
  })  : _id = id,
        _enunciado = enunciado,
        _disciplina = disciplina,
        _assunto = assunto,
        _alternativas = alternativas;


  String get id => _id;
  String get enunciado => _enunciado;
  String get disciplina => _disciplina;
  String get assunto => _assunto;
  List<Alternativa> get alternativas => _alternativas;

}