import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gabarito_plus/features/aluno/data/aluno.dart';
import 'package:gabarito_plus/features/turma/data/turma.dart';

class TurmaService {
  final _turmas = FirebaseFirestore.instance.collection('turmas');
  final _alunos = FirebaseFirestore.instance.collection('alunos');

  Aluno _alunoFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Aluno(
      id: doc.id,
      nome: d['nome'] ?? '',
      email: d['email'] ?? '',
      isAtivo: d['isAtivo'] ?? true,
    );
  }

  Future<List<Aluno>> listarAlunos() async {
    final snap = await _alunos.get();
    final lista = snap.docs.map(_alunoFromDoc).toList();
    lista.sort((a, b) => a.nome.compareTo(b.nome));
    return lista;
  }

  Future<List<Turma>> listarTurmas({bool apenasAtivas = false}) async {
    Query<Map<String, dynamic>> query = _turmas;
    if (apenasAtivas) {
      query = query.where('ativa', isEqualTo: true);
    }

    final turmasSnap = await query.get();
    final alunos = await listarAlunos();
    final alunosPorId = {for (final a in alunos) a.id: a};

    final lista = turmasSnap.docs.map((doc) {
      final d = doc.data();
      final ids = List<String>.from(d['alunosIds'] ?? []);
      return Turma(
        id: doc.id,
        nomeTurma: d['nomeTurma'] ?? '',
        ativa: d['ativa'] ?? true,
        // ignora IDs de alunos que foram excluídos
        listaAlunos: ids
            .map((id) => alunosPorId[id])
            .whereType<Aluno>()
            .toList(),
      );
    }).toList();

    lista.sort((a, b) => a.nomeTurma.compareTo(b.nomeTurma));
    return lista;
  }

  /// Cria (id vazio) ou atualiza uma turma.
  Future<void> salvar(Turma turma) async {
    if (turma.id.isEmpty) {
      await _turmas.add(turma.toMap());
    } else {
      await _turmas.doc(turma.id).set(turma.toMap());
    }
  }

  Future<void> excluir(String id) => _turmas.doc(id).delete();
}