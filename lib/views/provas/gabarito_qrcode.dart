import 'package:flutter/material.dart';
import 'package:gabarito_plus/models/prova.dart';
import 'package:gabarito_plus/models/versao_prova.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GabaritoQrCode extends StatelessWidget {
  const GabaritoQrCode({super.key, required this.prova, required this.versao});

  final Prova prova;
  final VersaoProva versao;

  String _gerarConteudoGabarito() {
    final buffer = StringBuffer()
      ..writeln('GABARITO - ${prova.titulo}')
      ..writeln('Turma: ${prova.turma.nomeTurma}')
      ..writeln('Aluno: ${versao.aluno.nome}')
      ..writeln('Código da versão: ${versao.codigo}')
      ..writeln();

    for (var i = 0; i < versao.questoes.length; i++) {
      final letra = String.fromCharCode(65 + versao.questoes[i].respostaCorreta);
      buffer.writeln('Questão ${i + 1}: $letra');
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final qrData = _gerarConteudoGabarito();

    return Scaffold(
      appBar: AppBar(title: const Text('Gabarito')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(prova.titulo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(prova.turma.nomeTurma, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: QrImageView(
                        data: qrData,
                        size: 180,
                        gapless: false,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      versao.codigo,
                      style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Aluno: ${versao.aluno.nome}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ao escanear com a câmera do celular, o gabarito desta versão\n'
                      'aparece como texto, pronto para copiar ou compartilhar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500], fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Respostas corretas', style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: versao.questoes.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final letra = String.fromCharCode(65 + versao.questoes[index].respostaCorreta);
                  return ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text('Alternativa correta: $letra'),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exportação do gabarito em breve')),
                );
              },
              icon: const Icon(Icons.print),
              label: const Text('Imprimir / Exportar'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
