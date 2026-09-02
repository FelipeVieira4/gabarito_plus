import 'package:flutter/material.dart';
import 'package:gabarito_plus/models/assunto.dart';
import 'package:gabarito_plus/models/disciplina.dart';
import 'package:gabarito_plus/models/questao.dart';

class DetalhesQuestaoView extends StatelessWidget {
  final Questao questao;
  final Disciplina disciplina;
  final Assunto assunto;

  const DetalhesQuestaoView({
    super.key,
    required this.questao,
    required this.disciplina,
    required this.assunto,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Questão'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com Disciplina e Assunto
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${disciplina.descricao} > ${assunto.nome}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Enunciado
            const Text(
              'Enunciado:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              questao.enunciado,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),

            // Alternativas
            const Text(
              'Alternativas:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            // Lista visual com as alternativas (destacando a correta em verde)
            ...questao.alternativas.map((alternativa) {
              return Card(
                color:
                    alternativa.isCorreta ? Colors.green.shade100 : Colors.white,
                margin: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  leading: Icon(
                    alternativa.isCorreta
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: alternativa.isCorreta ? Colors.green : Colors.grey,
                  ),
                  title: Text(alternativa.texto),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}