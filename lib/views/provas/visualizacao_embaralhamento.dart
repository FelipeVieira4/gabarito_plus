import 'package:flutter/material.dart';
import 'package:gabarito_plus/models/embaralhador.dart';
import 'package:gabarito_plus/models/prova.dart';
import 'package:gabarito_plus/models/versao_prova.dart';
import 'package:gabarito_plus/views/provas/gabarito_qrcode.dart';

class VisualizacaoEmbaralhamento extends StatefulWidget {
  const VisualizacaoEmbaralhamento({super.key, required this.prova});

  final Prova prova;

  @override
  State<VisualizacaoEmbaralhamento> createState() => _VisualizacaoEmbaralhamentoState();
}

class _VisualizacaoEmbaralhamentoState extends State<VisualizacaoEmbaralhamento> {
  late List<VersaoProva> _versoes;

  @override
  void initState() {
    super.initState();
    _versoes = Embaralhador.gerarVersoes(widget.prova);
  }

  void _regerarVersoes() {
    setState(() => _versoes = Embaralhador.gerarVersoes(widget.prova));
  }

  @override
  Widget build(BuildContext context) {
    final prova = widget.prova;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Embaralhamento das Provas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Gerar nova distribuição',
            onPressed: _regerarVersoes,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(prova.titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text('${prova.turma.nomeTurma} · ${prova.questoes.length} questões · ${_versoes.length} variações geradas'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildChip(
                          prova.embaralharQuestoes ? Icons.check_circle : Icons.cancel,
                          'Ordem das questões',
                          prova.embaralharQuestoes,
                        ),
                        _buildChip(
                          prova.embaralharAlternativas ? Icons.check_circle : Icons.cancel,
                          'Ordem das alternativas',
                          prova.embaralharAlternativas,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Cada aluno recebe uma prova com a mesma dificuldade, mas em uma ordem diferente',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: _versoes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final versao = _versoes[index];
                return _VersaoProvaCard(
                  versao: versao,
                  onVerGabarito: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GabaritoQrCode(prova: prova, versao: versao),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, bool ativo) {
    return Chip(
      avatar: Icon(icon, size: 16, color: ativo ? Colors.green : Colors.grey),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _VersaoProvaCard extends StatelessWidget {
  const _VersaoProvaCard({required this.versao, required this.onVerGabarito});

  final VersaoProva versao;
  final VoidCallback onVerGabarito;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: CircleAvatar(child: Text(versao.aluno.nome[0])),
        title: Text(versao.aluno.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Código da versão: ${versao.codigo}'),
        children: [
          ...versao.questoes.asMap().entries.map((entry) {
            final numero = entry.key + 1;
            final questaoEmbaralhada = entry.value;

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Questão $numero',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                  ),
                  Text(questaoEmbaralhada.questao.enunciado),
                  const SizedBox(height: 4),
                  ...questaoEmbaralhada.alternativas.asMap().entries.map((alt) {
                    final letra = String.fromCharCode(65 + alt.key);
                    final correta = alt.key == questaoEmbaralhada.respostaCorreta;
                    return Text(
                      '$letra) ${alt.value}',
                      style: TextStyle(
                        color: correta ? Colors.green[700] : null,
                        fontWeight: correta ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onVerGabarito,
                icon: const Icon(Icons.qr_code_2),
                label: const Text('Ver Gabarito'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
