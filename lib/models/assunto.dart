import 'package:gabarito_plus/models/questao.dart';

class Assunto {
  final String id;
  final String nome;
  final List<Questao> questoes;

  Assunto({
    required this.id,
    required this.nome,
    required this.questoes,
  });
}
