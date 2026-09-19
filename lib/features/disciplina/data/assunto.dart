import 'package:gabarito_plus/features/questoes/data/questao.dart';
 
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