import 'package:gabarito_plus/features/geracao_prova/data/gabarito_lido.dart';
import 'package:gabarito_plus/features/geracao_prova/data/prova.dart';
import 'package:gabarito_plus/features/geracao_prova/data/versao_prova.dart';
import 'package:gabarito_plus/features/geracao_prova/service/prova_repository.dart';

/// Repositório de provas em memória para os testes de widget, que não
/// inicializam o Firebase. Monta o gabarito do mesmo jeito que o real.
class ProvaRepositoryMemoria implements ProvaRepository {
  final Map<String, Map<String, dynamic>> _provas = {};
  final Map<String, VersaoProva> _versoes = {};

  @override
  Future<void> salvar(Prova prova, List<VersaoProva> versoes) async {
    if (_provas.containsKey(prova.id)) {
      throw StateError('Já existe uma prova com o código ${prova.id}.');
    }
    _provas[prova.id] = prova.toMap();
    for (final versao in versoes) {
      _versoes[versao.codigo] = versao;
    }
  }

  @override
  Future<GabaritoLido?> buscarGabarito(String codigoVersao) async {
    final codigo = codigoVersao.trim().toUpperCase();
    final versao = _versoes[codigo];
    if (versao == null) return null;

    final provaId = codigo.substring(0, codigo.indexOf('-'));
    return GabaritoLido.daVersao(
      provaId: provaId,
      dadosProva: _provas[provaId]!,
      versao: versao,
    );
  }
}
