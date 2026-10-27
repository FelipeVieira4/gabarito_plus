import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gabarito_plus/features/geracao_prova/data/correcao.dart';

/// Ponto único de acesso às correções salvas. As telas usam [instancia];
/// os testes de widget trocam por uma versão em memória, já que não
/// inicializam o Firebase.
abstract class CorrecaoRepository {
  static CorrecaoRepository instancia = CorrecaoRepositoryFirestore();

  Future<List<Correcao>> obterTodas();

  Future<Correcao?> obterPorCodigo(String codigoVersao);

  Future<bool> jaCorrigida(String codigoVersao);

  /// Corrigir de novo a mesma versão sobrescreve a correção anterior.
  Future<void> salvar(Correcao correcao);

  Future<void> remover(String codigoVersao);
}

class CorrecaoRepositoryFirestore implements CorrecaoRepository {
  // late: só acessa o Firebase no primeiro uso, não ao criar a instância
  late final _correcoes = FirebaseFirestore.instance.collection('correcoes');

  @override
  Future<List<Correcao>> obterTodas() async {
    final snap = await _correcoes.get();
    final lista = snap.docs.map(Correcao.fromFirestore).toList();
    lista.sort((a, b) => b.dataHora.compareTo(a.dataHora));
    return lista;
  }

  @override
  Future<Correcao?> obterPorCodigo(String codigoVersao) async {
    final doc = await _correcoes.doc(codigoVersao).get();
    return doc.exists ? Correcao.fromFirestore(doc) : null;
  }

  @override
  Future<bool> jaCorrigida(String codigoVersao) async {
    final doc = await _correcoes.doc(codigoVersao).get();
    return doc.exists;
  }

  @override
  Future<void> salvar(Correcao correcao) =>
      _correcoes.doc(correcao.codigoVersao).set(correcao.toMap());

  @override
  Future<void> remover(String codigoVersao) =>
      _correcoes.doc(codigoVersao).delete();
}
