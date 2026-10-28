import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gabarito_plus/features/geracao_prova/data/gabarito_lido.dart';
import 'package:gabarito_plus/features/geracao_prova/data/prova.dart';
import 'package:gabarito_plus/features/geracao_prova/data/versao_prova.dart';

/// Sem 0/O, 1/I/L: o código é digitado à mão na correção.
const alfabetoCodigoProva = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
const tamanhoCodigoProva = 6;

/// Id curto da prova, que também é o começo do código de cada versão
/// (ex.: `K7Q2XM-03`).
String gerarIdProva([Random? random]) {
  final gerador = random ?? Random.secure();
  return List.generate(
    tamanhoCodigoProva,
    (_) => alfabetoCodigoProva[gerador.nextInt(alfabetoCodigoProva.length)],
  ).join();
}

/// Provas geradas e os gabaritos de cada versão. As telas usam [instancia];
/// os testes de widget trocam por uma versão em memória, já que não
/// inicializam o Firebase.
abstract class ProvaRepository {
  static ProvaRepository instancia = ProvaRepositoryFirestore();

  /// Grava a prova e todas as versões juntas: ou entra tudo, ou nada.
  Future<void> salvar(Prova prova, List<VersaoProva> versoes);

  /// Gabarito da versão com esse código, ou null se não existir.
  Future<GabaritoLido?> buscarGabarito(String codigoVersao);
}

class ProvaRepositoryFirestore implements ProvaRepository {
  // late: só acessa o Firebase no primeiro uso, não ao criar a instância
  late final _db = FirebaseFirestore.instance;
  late final _provas = _db.collection('provas');

  @override
  Future<void> salvar(Prova prova, List<VersaoProva> versoes) async {
    final provaRef = _provas.doc(prova.id);

    if ((await provaRef.get()).exists) {
      throw StateError(
        'Já existe uma prova com o código ${prova.id}. Gere as provas de novo.',
      );
    }

    final batch = _db.batch();
    batch.set(provaRef, prova.toMap());
    for (final versao in versoes) {
      batch.set(provaRef.collection('versoes').doc(versao.codigo), versao.toMap());
    }
    await batch.commit();
  }

  @override
  Future<GabaritoLido?> buscarGabarito(String codigoVersao) async {
    final codigo = codigoVersao.trim().toUpperCase();
    final separador = codigo.indexOf('-');
    if (separador <= 0) return null;

    final provaRef = _provas.doc(codigo.substring(0, separador));
    final provaDoc = await provaRef.get();
    if (!provaDoc.exists) return null;

    final versaoDoc = await provaRef.collection('versoes').doc(codigo).get();
    if (!versaoDoc.exists) return null;

    return GabaritoLido.daVersao(
      provaId: provaDoc.id,
      dadosProva: provaDoc.data()!,
      versao: VersaoProva.fromFirestore(versaoDoc),
    );
  }
}
