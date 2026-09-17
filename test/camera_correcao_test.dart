import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabarito_plus/mocks/mock_leitura.dart';
import 'package:gabarito_plus/services/correcao_repository.dart';
import 'package:gabarito_plus/views/correcao/camera_correcao.dart';

void main() {
  setUp(() {
    // A simulação e o repositório são estado global: sem reiniciar, um teste
    // começa de onde o anterior parou.
    reiniciarSimulacaoDeLeitura();
    CorrecaoRepository.instancia.reiniciar();
  });

  Future<void> abrirTela(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CameraCorrecao()),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tocar(WidgetTester tester, String texto) async {
    await tester.tap(find.text(texto));
    await tester.pumpAndSettle();
  }

  testWidgets('percorre o fluxo do QR até a nota', (tester) async {
    await abrirTela(tester);

    // Etapa 1: leitura do QR Code.
    expect(find.text('Ler gabarito'), findsOneWidget);
    expect(find.text('Aponte para o QR Code do gabarito'), findsOneWidget);

    await tocar(tester, 'Simular leitura do QR');

    // Etapa 2: o aluno já aparece identificado antes de ler a folha.
    expect(find.text('Ler folha de respostas'), findsOneWidget);
    expect(find.text('José Perreira'), findsOneWidget);
    expect(find.text('ES2025A-001'), findsOneWidget);

    await tocar(tester, 'Simular leitura da folha');

    // Etapa 3: conferência, com a grade das 10 questões.
    expect(find.text('Conferir marcações'), findsOneWidget);
    expect(find.byKey(const ValueKey('q1-alt0')), findsOneWidget);
    expect(find.byKey(const ValueKey('q10-alt3')), findsOneWidget);

    await tocar(tester, 'Confirmar e ver nota');

    // Etapa 4: resultado. José acerta 8 das 10 questões.
    expect(find.text('Resultado'), findsOneWidget);
    expect(find.text('8,0'), findsOneWidget);
    expect(find.text('8 de 10 questões'), findsOneWidget);
    expect(find.text('8 acertos'), findsOneWidget);
    expect(find.text('2 erros'), findsOneWidget);
    expect(find.text('0 em branco'), findsOneWidget);
  });

  testWidgets('salvar grava no repositório e volta para o QR', (tester) async {
    final repositorio = CorrecaoRepository.instancia;
    final totalAntes = repositorio.total;

    await abrirTela(tester);
    await tocar(tester, 'Simular leitura do QR');
    await tocar(tester, 'Simular leitura da folha');
    await tocar(tester, 'Confirmar e ver nota');
    await tocar(tester, 'Salvar e corrigir a próxima');

    // Volta sozinho para a leitura do QR, sem passar pelo menu.
    expect(find.text('Ler gabarito'), findsOneWidget);
    expect(find.text('1 corrigidas'), findsOneWidget);

    final salva = repositorio.obterPorCodigo('ES2025A-001');
    expect(salva, isNotNull);
    expect(salva!.nomeAluno, 'José Perreira');
    expect(salva.nota, 8.0);

    // José já vinha corrigido nos mocks: salvar substitui, não duplica.
    expect(repositorio.total, totalAntes);
  });

  testWidgets('simulação segue para o próximo aluno da turma', (tester) async {
    await abrirTela(tester);

    await tocar(tester, 'Simular leitura do QR');
    expect(find.text('José Perreira'), findsOneWidget);

    await tocar(tester, 'Simular leitura da folha');
    await tocar(tester, 'Confirmar e ver nota');
    await tocar(tester, 'Salvar e corrigir a próxima');

    await tocar(tester, 'Simular leitura do QR');
    expect(find.text('Ana Maria'), findsOneWidget);
  });

  testWidgets('corrigir marcação à mão muda a nota', (tester) async {
    await abrirTela(tester);
    await tocar(tester, 'Simular leitura do QR');
    await tocar(tester, 'Simular leitura da folha');

    // A folha de José traz a questão 3 marcada em A; a correta é B.
    final alternativaB = find.byKey(const ValueKey('q3-alt1'));
    await tester.ensureVisible(alternativaB);
    await tester.tap(alternativaB);
    await tester.pumpAndSettle();

    await tocar(tester, 'Confirmar e ver nota');
    expect(find.text('9,0'), findsOneWidget);
  });

  testWidgets('tocar na alternativa já marcada deixa a questão em branco',
      (tester) async {
    await abrirTela(tester);
    await tocar(tester, 'Simular leitura do QR');
    await tocar(tester, 'Simular leitura da folha');

    // Questão 1 de José está marcada em B, e está certa.
    final alternativaB = find.byKey(const ValueKey('q1-alt1'));
    await tester.ensureVisible(alternativaB);
    await tester.tap(alternativaB);
    await tester.pumpAndSettle();

    await tocar(tester, 'Confirmar e ver nota');
    expect(find.text('7,0'), findsOneWidget);
    expect(find.text('1 em branco'), findsOneWidget);
  });

  testWidgets('folha de outro aluno é recusada', (tester) async {
    await abrirTela(tester);
    await tocar(tester, 'Simular leitura do QR');
    await tocar(tester, 'Simular folha trocada');

    // Continua na etapa da folha, avisando em vez de lançar a nota errada.
    expect(find.text('Ler folha de respostas'), findsOneWidget);
    expect(find.textContaining('não é a folha do gabarito'), findsOneWidget);
  });

  testWidgets('código digitado à mão encontra a prova', (tester) async {
    await abrirTela(tester);
    await tocar(tester, 'Digitar código da prova');

    await tester.enterText(find.byType(TextField), 'ES2025A-005');
    await tocar(tester, 'Buscar');

    expect(find.text('Ricardo Diaz'), findsOneWidget);
  });

  testWidgets('código inexistente avisa e não avança', (tester) async {
    await abrirTela(tester);
    await tocar(tester, 'Digitar código da prova');

    await tester.enterText(find.byType(TextField), 'NAO-EXISTE');
    await tocar(tester, 'Buscar');

    expect(find.text('Ler gabarito'), findsOneWidget);
    expect(find.textContaining('Nenhuma prova encontrada'), findsOneWidget);
  });

  testWidgets('avisa que a prova já foi corrigida antes', (tester) async {
    await abrirTela(tester);
    await tocar(tester, 'Simular leitura do QR');

    expect(find.textContaining('já foi corrigida antes'), findsOneWidget);
  });

  testWidgets('voltar uma etapa não sai da tela', (tester) async {
    await abrirTela(tester);
    await tocar(tester, 'Simular leitura do QR');

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Ler gabarito'), findsOneWidget);
  });
}
