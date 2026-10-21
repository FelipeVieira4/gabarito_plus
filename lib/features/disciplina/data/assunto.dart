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

  Map<String, dynamic> toMap({required String disciplinaId}) => {
        'nome': nome,
        'disciplinaId': disciplinaId,
      };

  @override
  bool operator ==(Object other) => other is Assunto && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
