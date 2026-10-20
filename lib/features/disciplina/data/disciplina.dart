import 'package:gabarito_plus/features/disciplina/data/assunto.dart';

class Disciplina {
  final String id;
  final String descricao;
  final List<Assunto> assuntos;

  Disciplina({
    required this.id,
    required this.descricao,
    required this.assuntos,
  });

  Map<String, dynamic> toMap() => {
        'descricao': descricao,
        'descricaoBusca': descricao.toLowerCase(),
      };

  @override
  bool operator ==(Object other) => other is Disciplina && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
