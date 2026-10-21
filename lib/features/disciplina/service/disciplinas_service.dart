import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gabarito_plus/features/disciplina/data/assunto.dart';
import 'package:gabarito_plus/features/disciplina/data/disciplina.dart';
import 'package:gabarito_plus/features/questoes/data/questao.dart';

class DisciplinasService {
  final _disciplinas = FirebaseFirestore.instance.collection('disciplinas');
  final _assuntos = FirebaseFirestore.instance.collection('assuntos');
  final _questoes = FirebaseFirestore.instance.collection('questoes');


  Future<List<Disciplina>> listarDisciplinas() async {
    final snaps = await Future.wait([
      _disciplinas.get(),
      _assuntos.get(),
      _questoes.get(),
    ]);
    final disciplinasSnap = snaps[0];
    final assuntosSnap = snaps[1];
    final questoesSnap = snaps[2];

    final questoesPorAssunto = <String, List<Questao>>{};
    for (final doc in questoesSnap.docs) {
      final assuntoId = doc.data()['assuntoId'] as String? ?? '';
      questoesPorAssunto
          .putIfAbsent(assuntoId, () => [])
          .add(Questao.fromFirestore(doc));
    }

    final assuntosPorDisciplina = <String, List<Assunto>>{};
    for (final doc in assuntosSnap.docs) {
      final d = doc.data();
      final disciplinaId = d['disciplinaId'] as String? ?? '';
      assuntosPorDisciplina.putIfAbsent(disciplinaId, () => []).add(
            Assunto(
              id: doc.id,
              nome: d['nome'] ?? '',
              questoes: questoesPorAssunto[doc.id] ?? [],
            ),
          );
    }

    for (final assuntos in assuntosPorDisciplina.values) {
      assuntos.sort(
        (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
      );
    }

    final lista = disciplinasSnap.docs.map((doc) {
      return Disciplina(
        id: doc.id,
        descricao: doc.data()['descricao'] ?? '',
        assuntos: assuntosPorDisciplina[doc.id] ?? [],
      );
    }).toList();

    lista.sort(
      (a, b) => a.descricao.toLowerCase().compareTo(b.descricao.toLowerCase()),
    );
    return lista;
  }

  Future<bool> existeDisciplina(String descricao) async {
    final snap = await _disciplinas
        .where('descricaoBusca', isEqualTo: descricao.trim().toLowerCase())
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<String> criarDisciplina(String descricao) async {
    final disciplina = Disciplina(id: '', descricao: descricao, assuntos: []);
    final doc = await _disciplinas.add(disciplina.toMap());
    return doc.id;
  }

  Future<String> criarAssunto({
    required String disciplinaId,
    required String nome,
  }) async {
    final assunto = Assunto(id: '', nome: nome, questoes: []);
    final doc = await _assuntos.add(assunto.toMap(disciplinaId: disciplinaId));
    return doc.id;
  }
}
