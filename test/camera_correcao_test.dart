import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabarito_plus/features/correcao_prova/services/correcao_repository.dart';
import 'package:gabarito_plus/features/correcao_prova/services/correcao_service.dart';
import 'package:gabarito_plus/features/correcao_prova/views/correcao/camera_correcao.dart';
import 'package:gabarito_plus/features/geracao_prova/data/embaralhador.dart';
import 'package:gabarito_plus/features/geracao_prova/data/gabarito_lido.dart';
import 'package:gabarito_plus/features/geracao_prova/service/prova_repository.dart';

import 'helpers/correcao_repository_memoria.dart';
import 'helpers/fixtures_correcao.dart';
import 'helpers/prova_repository_memoria.dart';

// Marcações do José: 8 acertos (erra a 3 e a 6).
const _marcacoesJose = <int?>[1, 0, 0, 1, 1, 1, 1, 0, 0, 1];

void main() {
  setUp(() async {
    CorrecaoRepository.instancia = CorrecaoRepositoryMemoria();

    final prova = provaDeTeste();
    final repositorio = ProvaRepositoryMemoria();
    await repositorio.salvar(prova, Embaralhador.gerarVersoes(prova));
    ProvaRepository.instancia = repositorio;
  });

  Future<void> abrirTela(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: CameraCorrecao()));
    await tester.pumpAndSettle();
  }

  Future<void> tocar(WidgetTester tester, String texto) async {
    final alvo = find.text(texto);
    await tester.ensureVisible(alvo);
    await tester.pumpAndSettle();
    await tester.tap(alvo, warnIfMissed: false);
    await tester.pumpAndSettle();
  }

  Future<void> tocarAlternativa(WidgetTester tester, String chave) async {
    final alternativa = find.byKey(ValueKey(chave));
    await tester.ensureVisible(alternativa);
    await tester.pumpAndSettle();
    await tester.tap(alternativa);
    await tester.pumpAndSettle();
  }

  Future<void> marcar(WidgetTester tester, List<int?> marcadas) async {
    for (var i = 0; i < marcadas.length; i++) {
      final indice = marcadas[i];
      if (indice == null) continue;
      await tocarAlternativa(tester, 'q${i + 1}-alt$indice');
    }
  }

  Future<void> digitarCodigo(WidgetTester tester, String codigo) async {
    // Fecha o aviso (SnackBar) da correção anterior, se houver,
    // porque ele pode cobrir o botão.
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold).first))
        .hideCurrentSnackBar();
    await tester.pumpAndSettle();

    await tocar(tester, 'Digitar código da prova');
    await tester.enterText(find.byType(TextField), codigo);
    await tocar(tester, 'Buscar');
  }

  Future<void> abrirConferencia(WidgetTester tester, String codigo) async {
    await abrirTela(tester);
    await digitarCodigo(tester, codigo);
    await tocar(tester, 'Marcar respostas manualmente');
  }

  testWidgets('percorre o fluxo do código até a nota', (tester) async {
    await abrirTela(tester);

    expect(find.text('Ler gabarito'), findsOneWidget);
    expect(find.text('Aponte para o QR Code do gabarito'), findsOneWidget);

    await digitarCodigo(tester, 'ABC234-01');

    expect(find.text('Ler folha de respostas'), findsOneWidget);
    expect(find.text('José Perreira'), findsOneWidget);
    expect(find.text('ABC234-01'), findsOneWidget);

    await tocar(tester, 'Marcar respostas manualmente');

    expect(find.text('Conferir marcações'), findsOneWidget);
    expect(find.byKey(const ValueKey('q1-alt0')), findsOneWidget);
    expect(find.byKey(const ValueKey('q10-alt3')), findsOneWidget);

    await marcar(tester, _marcacoesJose);
    await tocar(tester, 'Confirmar e ver nota');

    expect(find.text('Resultado'), findsOneWidget);
    expect(find.text('8,0'), findsOneWidget);
    expect(find.text('8 de 10 questões'), findsOneWidget);
    expect(find.text('8 acertos'), findsOneWidget);
    expect(find.text('2 erros'), findsOneWidget);
    expect(find.text('0 em branco'), findsOneWidget);
  });

  testWidgets('salvar grava no repositório e volta para o QR', (tester) async {
    await abrirConferencia(tester, 'abc234-01');
    await marcar(tester, _marcacoesJose);
    await tocar(tester, 'Confirmar e ver nota');
    await tocar(tester, 'Salvar e corrigir a próxima');

    expect(find.text('Ler gabarito'), findsOneWidget);
    expect(find.text('1 corrigidas'), findsOneWidget);

    final salva =
        await CorrecaoRepository.instancia.obterPorCodigo('ABC234-01');
    expect(salva, isNotNull);
    expect(salva!.nomeAluno, 'José Perreira');
    expect(salva.nota, 8.0);
    expect(salva.provaId, 'ABC234');
    expect(salva.turmaId, 'turma-1');
    expect(salva.alunoId, 'aluno-1');
    expect(salva.tituloProva, tituloProvaTeste);
    expect(salva.acertos, 8);
  });

  testWidgets('segue para o próximo aluno da turma', (tester) async {
    await abrirTela(tester);
    await digitarCodigo(tester, 'ABC234-01');
    expect(find.text('José Perreira'), findsOneWidget);

    await tocar(tester, 'Marcar respostas manualmente');
    await tocar(tester, 'Confirmar e ver nota');
    await tocar(tester, 'Salvar e corrigir a próxima');

    await digitarCodigo(tester, 'ABC234-02');
    expect(find.text('Ana Maria'), findsOneWidget);
  });

  testWidgets('corrigir marcação à mão muda a nota', (tester) async {
    await abrirConferencia(tester, 'ABC234-01');
    await marcar(tester, _marcacoesJose);

    // A questão 3 está marcada em A; a correta é B.
    await tocarAlternativa(tester, 'q3-alt1');

    await tocar(tester, 'Confirmar e ver nota');
    expect(find.text('9,0'), findsOneWidget);
  });

  testWidgets('tocar na alternativa já marcada deixa a questão em branco',
      (tester) async {
    await abrirConferencia(tester, 'ABC234-01');
    await marcar(tester, _marcacoesJose);

    // A questão 1 está marcada em B (certa): tocar de novo limpa.
    await tocarAlternativa(tester, 'q1-alt1');

    await tocar(tester, 'Confirmar e ver nota');
    expect(find.text('7,0'), findsOneWidget);
    expect(find.text('1 em branco'), findsOneWidget);
  });

  testWidgets('folha começa em branco numa prova real', (tester) async {
    await abrirConferencia(tester, 'ABC234-01');

    expect(find.textContaining('Folha em branco'), findsOneWidget);
  });

  testWidgets('código inexistente avisa e não avança', (tester) async {
    await abrirTela(tester);
    await digitarCodigo(tester, 'NAO-EXISTE');

    expect(find.text('Ler gabarito'), findsOneWidget);
    expect(find.textContaining('Nenhuma prova encontrada'), findsOneWidget);
  });

  testWidgets('avisa que já foi corrigida e salvar substitui, sem duplicar',
      (tester) async {
    final anterior = CorrecaoService().corrigir(
      gabarito: GabaritoLido(
        codigoVersao: 'ABC234-01',
        tituloProva: tituloProvaTeste,
        nomeTurma: turmaProvaTeste,
        nomeAluno: 'José Perreira',
        respostasCorretas: respostasCorretasTeste,
        quantidadeAlternativas: 4,
      ),
      folha: FolhaLida(
        codigoVersao: 'ABC234-01',
        respostasMarcadas: List.filled(respostasCorretasTeste.length, null),
      ),
    );
    CorrecaoRepository.instancia = CorrecaoRepositoryMemoria([anterior]);

    await abrirTela(tester);
    await digitarCodigo(tester, 'ABC234-01');
    expect(find.textContaining('já foi corrigida antes'), findsOneWidget);

    await tocar(tester, 'Marcar respostas manualmente');
    await marcar(tester, _marcacoesJose);
    await tocar(tester, 'Confirmar e ver nota');
    await tocar(tester, 'Salvar e corrigir a próxima');

    final todas = await CorrecaoRepository.instancia.obterTodas();
    expect(todas, hasLength(1));
    expect(todas.single.nota, 8.0);
  });

  testWidgets('voltar uma etapa não sai da tela', (tester) async {
    await abrirTela(tester);
    await digitarCodigo(tester, 'ABC234-01');

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Ler gabarito'), findsOneWidget);
  });
}