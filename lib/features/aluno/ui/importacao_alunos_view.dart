import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gabarito_plus/features/aluno/data/importacao_alunos.dart';
import 'package:gabarito_plus/features/aluno/service/aluno_service.dart';

class ImportacaoAlunosView extends StatefulWidget {
  const ImportacaoAlunosView({super.key});

  @override
  State<ImportacaoAlunosView> createState() => _ImportacaoAlunosViewState();
}

class _ImportacaoAlunosViewState extends State<ImportacaoAlunosView> {
  late final _service = AlunoService();

  String? _nomeArquivo;
  ResultadoImportacao? _resultado;
  bool _carregando = false;
  bool _salvando = false;

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _escolherArquivo() async {
    final arquivo = await FilePicker.pickFile(
      dialogTitle: 'Selecione a planilha de alunos',
      type: FileType.custom,
      allowedExtensions: ImportacaoAlunosParser.extensoesSuportadas,
    );
    if (arquivo == null) return;

    setState(() => _carregando = true);
    try {
      final bytes = await arquivo.readAsBytes();
      final resultado = ImportacaoAlunosParser.parse(
        bytes,
        arquivo.extension ?? '',
      );
      if (!mounted) return;
      setState(() {
        _nomeArquivo = arquivo.name;
        _resultado = resultado;
      });
      if (resultado.validos.isEmpty && resultado.erros.isEmpty) {
        _mensagem('A planilha está vazia.');
      }
    } on ArquivoInvalidoException catch (e) {
      if (mounted) _mensagem(e.mensagem);
    } catch (e) {
      if (mounted) _mensagem('Erro ao ler o arquivo: $e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _confirmarImportacao() async {
    final validos = _resultado?.validos ?? [];
    if (validos.isEmpty) return;

    setState(() => _salvando = true);
    try {
      final r = await _service.importar(validos);
      if (!mounted) return;

      final ignorados = r.jaExistentes.length;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Importação concluída'),
          content: Text(
            '${r.criados} aluno(s) cadastrado(s).'
            '${ignorados > 0 ? '\n$ignorados ignorado(s) porque o e-mail já estava cadastrado.' : ''}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) _mensagem('Erro ao salvar: $e');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultado = _resultado;

    return Scaffold(
      appBar: AppBar(title: const Text('Importar Alunos')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _instrucoes(),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _carregando || _salvando ? null : _escolherArquivo,
              icon: const Icon(Icons.upload_file),
              label: Text(
                _nomeArquivo == null
                    ? 'Escolher arquivo (CSV ou XLSX)'
                    : 'Trocar arquivo ($_nomeArquivo)',
              ),
            ),
            const SizedBox(height: 12),
            if (_carregando)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (resultado != null)
              Expanded(child: _previa(resultado)),
          ],
        ),
      ),
      bottomNavigationBar: resultado == null || resultado.validos.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton.icon(
                  onPressed: _salvando ? null : _confirmarImportacao,
                  icon: _salvando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: Text('Importar ${resultado.validos.length} aluno(s)'),
                ),
              ),
            ),
    );
  }

  Widget _instrucoes() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Formato da planilha',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'A primeira linha deve ter as colunas "nome" e "email". '
              'A coluna "ativo" (sim/não) é opcional — se ausente, todos '
              'ficam ativos. Sem cabeçalho, a coluna A é o nome e a B o e-mail.\n'
              'Alunos com e-mail já cadastrado são ignorados.',
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _mostrarExemplo,
                icon: const Icon(Icons.table_chart_outlined),
                label: const Text('Ver exemplo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarExemplo() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exemplo de planilha'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Monte sua planilha no Excel ou no Google Planilhas assim:'),
              SizedBox(height: 12),
              _PlanilhaExemplo(),
              SizedBox(height: 12),
              Text(
                '• Linha 1: os títulos das colunas, escritos exatamente assim.',
              ),
              Text('• Da linha 2 em diante: um aluno por linha.'),
              Text(
                '• Coluna "ativo": escreva "sim" ou "não". '
                'Pode deixar em branco (conta como "sim") ou nem criar a coluna.',
              ),
              Text(
                '• Salve como .xlsx ou .csv '
                '(no Google Planilhas: Arquivo > Fazer download).',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  Widget _previa(ResultadoImportacao r) {
    return ListView(
      children: [
        if (r.erros.isNotEmpty) ...[
          Text(
            '${r.erros.length} linha(s) com problema (não serão importadas)',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          ...r.erros.map(
            (e) => ListTile(
              dense: true,
              leading: Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(e.toString()),
            ),
          ),
          const Divider(),
        ],
        Text(
          '${r.validos.length} aluno(s) prontos para importar',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        ...r.validos.map(
          (a) => ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 14,
              backgroundColor: a.isAtivo ? Colors.blue : Colors.grey,
              child: Text(
                a.nome[0],
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            title: Text(a.nome),
            subtitle: Text(a.email),
            trailing: a.isAtivo ? null : const Text('Inativo'),
          ),
        ),
      ],
    );
  }
}

class _PlanilhaExemplo extends StatelessWidget {
  const _PlanilhaExemplo();

  static const _dados = [
    ['nome', 'email', 'ativo'],
    ['Maria Silva', 'maria@escola.com', 'sim'],
    ['João Souza', 'joao@escola.com', 'sim'],
    ['Ana Lima', 'ana@escola.com', 'não'],
  ];

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final borda = BorderSide(color: cores.outlineVariant);

    Widget celula(String texto, {bool guia = false, bool titulo = false}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        color: guia
            ? cores.surfaceContainerHighest
            : titulo
            ? cores.primaryContainer
            : null,
        alignment: guia ? Alignment.center : Alignment.centerLeft,
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 12,
            fontWeight: titulo ? FontWeight.bold : null,
            color: guia ? cores.onSurfaceVariant : null,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder(
          top: borda,
          bottom: borda,
          left: borda,
          right: borda,
          horizontalInside: borda,
          verticalInside: borda,
        ),
        defaultColumnWidth: const IntrinsicColumnWidth(),
        children: [
          TableRow(
            children: [
              celula('', guia: true),
              for (final letra in ['A', 'B', 'C']) celula(letra, guia: true),
            ],
          ),
          for (var i = 0; i < _dados.length; i++)
            TableRow(
              children: [
                celula('${i + 1}', guia: true),
                for (final valor in _dados[i]) celula(valor, titulo: i == 0),
              ],
            ),
        ],
      ),
    );
  }
}
