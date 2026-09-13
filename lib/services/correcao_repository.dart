import 'package:gabarito_plus/mocks/mock_correcao.dart';
import 'package:gabarito_plus/models/correcao.dart';

class CorrecaoRepository {
  CorrecaoRepository._();

  static final CorrecaoRepository instancia = CorrecaoRepository._();

  final List<Correcao> _correcoes = List.of(correcoesMock.take(6));

  List<Correcao> obterTodas() => List.unmodifiable(_correcoes);

  int get total => _correcoes.length;

  bool jaCorrigida(String codigoVersao) {
    return _correcoes.any((correcao) => correcao.codigoVersao == codigoVersao);
  }

  Correcao? obterPorCodigo(String codigoVersao) {
    for (final correcao in _correcoes) {
      if (correcao.codigoVersao == codigoVersao) return correcao;
    }
    return null;
  }

  void salvar(Correcao correcao) {
    final indice = _correcoes.indexWhere(
      (item) => item.codigoVersao == correcao.codigoVersao,
    );

    if (indice == -1) {
      _correcoes.add(correcao);
    } else {
      _correcoes[indice] = correcao;
    }
  }

  void remover(String codigoVersao) {
    _correcoes.removeWhere((correcao) => correcao.codigoVersao == codigoVersao);
  }

  void reiniciar() {
    _correcoes
      ..clear()
      ..addAll(correcoesMock.take(6));
  }
}
