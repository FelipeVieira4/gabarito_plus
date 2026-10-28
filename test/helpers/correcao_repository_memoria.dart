import 'package:gabarito_plus/features/correcao_prova/services/correcao_repository.dart';
import 'package:gabarito_plus/features/geracao_prova/data/correcao.dart';

/// Repositório em memória para os testes de widget, que não inicializam o
/// Firebase. Mesmo comportamento do repositório real: o código da versão é a
/// chave, e salvar de novo substitui.
class CorrecaoRepositoryMemoria implements CorrecaoRepository {
  CorrecaoRepositoryMemoria([Iterable<Correcao> iniciais = const []])
      : _correcoes = List.of(iniciais);

  final List<Correcao> _correcoes;

  @override
  Future<List<Correcao>> obterTodas() async => List.unmodifiable(_correcoes);

  @override
  Future<Correcao?> obterPorCodigo(String codigoVersao) async {
    for (final correcao in _correcoes) {
      if (correcao.codigoVersao == codigoVersao) return correcao;
    }
    return null;
  }

  @override
  Future<bool> jaCorrigida(String codigoVersao) async =>
      _correcoes.any((correcao) => correcao.codigoVersao == codigoVersao);

  @override
  Future<void> salvar(Correcao correcao) async {
    final indice = _correcoes.indexWhere(
      (item) => item.codigoVersao == correcao.codigoVersao,
    );

    if (indice == -1) {
      _correcoes.add(correcao);
    } else {
      _correcoes[indice] = correcao;
    }
  }

  @override
  Future<void> remover(String codigoVersao) async {
    _correcoes.removeWhere((correcao) => correcao.codigoVersao == codigoVersao);
  }
}
