import 'package:flutter/material.dart';
import 'package:gabarito_plus/features/geracao_prova/data/correcao.dart';
import 'package:gabarito_plus/features/geracao_prova/data/gabarito_lido.dart'
    show letraAlternativa;

class DetalhesProvaCorrigidaView extends StatelessWidget {
  const DetalhesProvaCorrigidaView({
    super.key,
    required this.correcao,
    this.notaCorte = 6.0,
  });

  final Correcao correcao;
  final double notaCorte;

  @override
  Widget build(BuildContext context) {
    final respostas = correcao.respostas;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da Prova')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            // índice 0 = cabeçalho + resumo; os demais = uma linha por questão
            itemCount: respostas.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _Topo(correcao: correcao, notaCorte: notaCorte);
              }
              return _LinhaQuestao(resposta: respostas[index - 1]);
            },
          ),
        ),
      ),
    );
  }
}

String _formatarNota(double valor) =>
    valor.toStringAsFixed(1).replaceAll('.', ',');

String _formatarDataHora(DateTime data) {
  String dois(int n) => n.toString().padLeft(2, '0');
  return '${dois(data.day)}/${dois(data.month)}/${data.year} '
      'às ${dois(data.hour)}:${dois(data.minute)}';
}

class _Topo extends StatelessWidget {
  const _Topo({required this.correcao, required this.notaCorte});

  final Correcao correcao;
  final double notaCorte;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final aprovado = correcao.nota >= notaCorte;
    final corNota = aprovado ? Colors.green.shade700 : Colors.red.shade700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // a) Cabeçalho
        Text(
          correcao.tituloProva,
          style: textos.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.person_outline, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(correcao.nomeAluno, style: textos.titleMedium),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.class_outlined, size: 18),
            const SizedBox(width: 6),
            Expanded(child: Text(correcao.nomeTurma)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${correcao.codigoVersao} • ${_formatarDataHora(correcao.dataHora)}',
          style: textos.bodySmall?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),

        // b) Painel de estatísticas
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itens = [
                  _Estatistica(
                    rotulo: aprovado ? 'Nota final' : 'Nota (abaixo da média)',
                    valor: _formatarNota(correcao.nota),
                    cor: corNota,
                    icone: Icons.grade_outlined,
                  ),
                  _Estatistica(
                    rotulo: 'Acertos',
                    valor: '${correcao.acertos}',
                    cor: Colors.green.shade700,
                    icone: Icons.check_circle_outline,
                  ),
                  _Estatistica(
                    rotulo: 'Erros',
                    valor: '${correcao.erros}',
                    cor: Colors.red.shade700,
                    icone: Icons.cancel_outlined,
                  ),
                  _Estatistica(
                    rotulo: 'Em branco',
                    valor: '${correcao.emBranco}',
                    cor: Colors.grey.shade600,
                    icone: Icons.remove_circle_outline,
                  ),
                ];

                if (constraints.maxWidth >= 500) {
                  return Row(
                    children: [for (final item in itens) Expanded(child: item)],
                  );
                }
                return Wrap(
                  spacing: 12,
                  runSpacing: 16,
                  children: [
                    for (final item in itens)
                      SizedBox(
                        width: (constraints.maxWidth - 12) / 2,
                        child: item,
                      ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Questão a questão', style: textos.titleMedium),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _Estatistica extends StatelessWidget {
  const _Estatistica({
    required this.rotulo,
    required this.valor,
    required this.cor,
    required this.icone,
  });

  final String rotulo;
  final String valor;
  final Color cor;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: cor.withValues(alpha: 0.12),
          child: Icon(icone, size: 20, color: cor),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                valor,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: cor,
                  height: 1.1,
                ),
              ),
              Text(
                rotulo,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LinhaQuestao extends StatelessWidget {
  const _LinhaQuestao({required this.resposta});

  final RespostaMarcada resposta;

  @override
  Widget build(BuildContext context) {
    final Color cor;
    final String rotuloBadge;
    final IconData icone;

    if (resposta.acertou) {
      cor = Colors.green.shade700;
      rotuloBadge = 'Acerto';
      icone = Icons.check_circle;
    } else if (resposta.emBranco) {
      cor = Colors.grey.shade600;
      rotuloBadge = 'Em branco';
      icone = Icons.remove_circle_outline;
    } else {
      cor = Colors.red.shade700;
      rotuloBadge = 'Erro';
      icone = Icons.cancel;
    }

    return Card(
      key: ValueKey('questao-${resposta.numeroQuestao}'),
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: cor.withValues(alpha: 0.12),
              child: Text(
                '${resposta.numeroQuestao}',
                style: TextStyle(color: cor, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  Text(
                    'Marcada: ${letraAlternativa(resposta.indiceMarcado)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: resposta.errou ? cor : null,
                    ),
                  ),
                  Text(
                    'Correta: ${letraAlternativa(resposta.indiceCorreto)}',
                    style: TextStyle(color: Colors.green.shade700),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icone, size: 14, color: cor),
                  const SizedBox(width: 4),
                  Text(
                    rotuloBadge,
                    style: TextStyle(
                      color: cor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}