import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gabarito_plus/features/aluno/data/aluno.dart';

class AlunoService {
  final _col = FirebaseFirestore.instance.collection('alunos');

  /// Lista em tempo real. O filtro por nome é feito no app,
  /// porque o Firestore não tem "contains" nativo.
  Stream<List<Aluno>> streamAlunosFiltrado({
    String? nomeAluno,
    bool apenasAtivos = false,
  }) {
    Query<Map<String, dynamic>> query = _col;

    if (apenasAtivos) {
      query = query.where('isAtivo', isEqualTo: true);
    }

    return query.snapshots().map((snap) {
      var lista = snap.docs.map(Aluno.fromFirestore).toList();

      if (nomeAluno != null && nomeAluno.trim().isNotEmpty) {
        final termo = nomeAluno.toLowerCase();
        lista = lista
            .where((a) => a.nome.toLowerCase().contains(termo))
            .toList();
      }

      lista.sort(
        (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
      );
      return lista;
    });
  }

  Future<Aluno?> buscarPorId(String id) async {
    if (id.isEmpty) return null;
    final doc = await _col.doc(id).get();
    return doc.exists ? Aluno.fromFirestore(doc) : null;
  }

  /// Cria ou atualiza. Se [id] for vazio, o Firestore gera um ID automático.
  /// Retorna o id do documento salvo.
  Future<String> salvar({
    required String id,
    required String nome,
    required String email,
    required bool isAtivo,
  }) async {
    final aluno = Aluno(id: id, nome: nome, email: email, isAtivo: isAtivo);
    final doc = id.isEmpty ? _col.doc() : _col.doc(id);
    await doc.set(aluno.toMap());
    return doc.id;
  }

  Future<void> excluir(String id) => _col.doc(id).delete();
}