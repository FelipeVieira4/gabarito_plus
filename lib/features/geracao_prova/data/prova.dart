import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gabarito_plus/features/disciplina/data/assunto.dart';
import 'package:gabarito_plus/features/questoes/data/questao.dart';
import 'package:gabarito_plus/features/turma/data/turma.dart';

class Prova {
  final String id;
  final String titulo;
  final Turma turma;
  final Assunto assunto;
  final List<Questao> questoes;
  final bool embaralharQuestoes;
  final bool embaralharAlternativas;

  Prova({
    required this.id,
    required this.titulo,
    required this.turma,
    required this.assunto,
    required this.questoes,
    required this.embaralharQuestoes,
    required this.embaralharAlternativas,
  });

  /// Formato salvo no Firestore (o id fica no documento, não nos campos).
  /// Turma e assunto são guardados por id, com o nome copiado para exibição.
  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'turmaId': turma.id,
        'nomeTurma': turma.nomeTurma,
        'assuntoId': assunto.id,
        'nomeAssunto': assunto.nome,
        'questoesIds': questoes.map((q) => q.id).toList(),
        'embaralharQuestoes': embaralharQuestoes,
        'embaralharAlternativas': embaralharAlternativas,
        'criadaEm': FieldValue.serverTimestamp(),
      };
}
