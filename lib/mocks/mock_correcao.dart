import 'package:gabarito_plus/mocks/mock_leitura.dart';
import 'package:gabarito_plus/models/correcao.dart';
import 'package:gabarito_plus/services/correcao_service.dart';


final DateTime dataAplicacaoMock = DateTime(2026, 9, 10, 14, 30);

final List<Correcao> correcoesMock = _gerarCorrecoesMock();

List<Correcao> _gerarCorrecoesMock() {
  final service = CorrecaoService();

  return List.generate(gabaritosLidosMock.length, (indice) {
    return service.corrigir(
      gabarito: gabaritosLidosMock[indice],
      folha: folhasLidasMock[indice],
      
      dataHora: dataAplicacaoMock.add(Duration(minutes: indice)),
    );
  });
}
