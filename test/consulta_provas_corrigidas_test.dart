import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabarito_plus/features/correcao_prova/mocks/mock_leitura.dart';
import 'package:gabarito_plus/features/correcao_prova/services/correcao_repository.dart';
import 'package:gabarito_plus/features/correcao_prova/views/correcao/consulta_provas_corrigidas.dart';
import 'package:gabarito_plus/features/dashboard/ui/dashboard_view.dart';
import 'package:gabarito_plus/features/geracao_prova/data/correcao.dart';

void main() {
  setUp(() {
    reiniciarSimulacaoDeLeitura();
    CorrecaoRepository.instancia.reiniciar();
  });

  Future<void> abrirTela(
    WidgetTester tester, {
    void Function(Correcao)? onSelecionarCorrecao,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ConsultaProvasCorrigidasView(
          onSelecionarCorrecao: onSelecionarCorrecao,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('exibe painel de resumo da turma e lista de provas corrigidas',
      (tester) async {
    await abrirTela(tester);

    expect(find.text('Provas Corrigidas'), findsOneWidget);

    // O CorrecaoRepository inicia com as 6 primeiras correções do mock:
    // Notas: 8.0, 10.0, 5.0, 6.0, 3.0, 9.0 -> média 6.8, maior 10.0, menor 3.0, 4 aprovados
    expect(find.text('Corrigidas'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('6,8'), findsOneWidget);
    expect(find.text('10,0 / 3,0'), findsOneWidget);
    expect(find.text('4/6 (67%)'), findsOneWidget);

    // Por padrão ordena por maior nota: Ana Maria (10,0) vem no topo
    expect(find.text('Ana Maria'), findsOneWidget);
    expect(find.text('10,0'), findsOneWidget);
    expect(find.text('ES2025A-002'), findsOneWidget);
  });

  testWidgets('filtra correções por busca de nome ou código da versão',
      (tester) async {
    await abrirTela(tester);

    await tester.enterText(find.byType(TextField), 'Ricardo');
    await tester.pumpAndSettle();

    expect(find.text('Ricardo Diaz'), findsOneWidget);
    expect(find.text('ES2025A-005'), findsOneWidget);
    expect(find.text('Ana Maria'), findsNothing);

    // O painel de resumo reflete apenas a prova filtrada (nota 3,0)
    expect(find.text('1/1 (100%)'), findsNothing);
    expect(find.text('0/1 (0%)'), findsOneWidget);

    // Limpar busca pelo botão clear
    await tester.tap(find.byTooltip('Limpar busca'));
    await tester.pumpAndSettle();

    expect(find.text('Ana Maria'), findsOneWidget);
  });

  testWidgets('exibe estado vazio quando busca não encontra resultados',
      (tester) async {
    await abrirTela(tester);

    await tester.enterText(find.byType(TextField), 'ALUNO-INEXISTENTE-XYZ');
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Nenhuma prova corrigida encontrada para os filtros aplicados.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Limpar filtros'));
    await tester.pumpAndSettle();

    expect(find.text('Ana Maria'), findsOneWidget);
  });

  testWidgets('permite remover uma correção após confirmação no diálogo',
      (tester) async {
    final repo = CorrecaoRepository.instancia;
    expect(repo.jaCorrigida('ES2025A-002'), isTrue);

    await abrirTela(tester);

    final cardAna = find.byKey(const ValueKey('card-correcao-ES2025A-002'));
    expect(cardAna, findsOneWidget);

    final botaoRemover = find.descendant(
      of: cardAna,
      matching: find.byIcon(Icons.delete_outline),
    );
    await tester.tap(botaoRemover);
    await tester.pumpAndSettle();

    expect(find.text('Remover correção'), findsOneWidget);
    await tester.tap(find.text('Remover'));
    await tester.pumpAndSettle();

    expect(repo.jaCorrigida('ES2025A-002'), isFalse);
    expect(find.text('Ana Maria'), findsNothing);
  });

  testWidgets('aciona callback onSelecionarCorrecao ao tocar no card',
      (tester) async {
    Correcao? selecionada;
    await abrirTela(
      tester,
      onSelecionarCorrecao: (correcao) => selecionada = correcao,
    );

    await tester.tap(find.byKey(const ValueKey('card-correcao-ES2025A-002')));
    await tester.pumpAndSettle();

    expect(selecionada, isNotNull);
    expect(selecionada!.codigoVersao, 'ES2025A-002');
    expect(selecionada!.nomeAluno, 'Ana Maria');
  });

  testWidgets('DashboardView possui atalho para Provas Corrigidas',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardView()));
    await tester.pumpAndSettle();

    final cardConsulta = find.text('Provas Corrigidas');
    expect(cardConsulta, findsOneWidget);

    await tester.ensureVisible(cardConsulta);
    await tester.tap(cardConsulta);
    await tester.pumpAndSettle();

    expect(find.byType(ConsultaProvasCorrigidasView), findsOneWidget);
    expect(find.text('Ana Maria'), findsOneWidget);
  });
}
