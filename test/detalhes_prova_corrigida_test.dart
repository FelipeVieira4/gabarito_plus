import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabarito_plus/features/correcao_prova/views/correcao/detalhes_prova_corrigida_view.dart';
import 'package:gabarito_plus/features/geracao_prova/data/correcao.dart';

void main() {
  final correcao = Correcao(
    codigoVersao: 'ABC234-01',
    tituloProva: 'Prova Real',
    nomeTurma: 'Turma X',
    nomeAluno: 'Carla Souza',
    respostas: [
      RespostaMarcada(numeroQuestao: 1, indiceMarcado: 0, indiceCorreto: 0),
      RespostaMarcada(numeroQuestao: 2, indiceMarcado: 3, indiceCorreto: 1),
      RespostaMarcada(numeroQuestao: 3, indiceMarcado: null, indiceCorreto: 2),
    ],
    quantidadeAlternativas: 4,
    dataHora: DateTime(2026, 10, 25, 10, 0),
  );

  testWidgets('mostra cabeçalho, estatísticas e badges por questão',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: DetalhesProvaCorrigidaView(correcao: correcao)),
    );

    expect(find.text('Prova Real'), findsOneWidget);
    expect(find.text('Carla Souza'), findsOneWidget);
    expect(find.text('Turma X'), findsOneWidget);
    expect(find.text('Acerto'), findsOneWidget);
    expect(find.text('Erro'), findsOneWidget);
    expect(find.text('Em branco'), findsWidgets);
    expect(find.text('Marcada: —'), findsOneWidget);
  });
}