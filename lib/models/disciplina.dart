import 'package:gabarito_plus/models/assunto.dart';
 
class Disciplina {
  final String id;
  final String descricao;
  final List<Assunto> assuntos;
 
  Disciplina({
    required this.id,
    required this.descricao,
    required this.assuntos,
  });
}