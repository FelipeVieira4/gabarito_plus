import 'package:flutter/material.dart';
import 'package:gabarito_plus/features/aluno/data/aluno.dart';
import 'package:gabarito_plus/features/turma/data/turma.dart';
import 'package:gabarito_plus/features/turma/service/turma_service.dart';

class CadastroTurma extends StatefulWidget {
  const CadastroTurma({super.key, required this.title, this.turma});

  final String title;
  final Turma? turma;

  @override
  State<CadastroTurma> createState() => _CadastroTurmaState();
}

class _CadastroTurmaState extends State<CadastroTurma> {
  final _formKey = GlobalKey<FormState>();
  final _nomeTurmaController = TextEditingController();
  final _service = TurmaService();

  final Set<String> _alunosSelecionados = {}; // ids
  List<Aluno> _alunos = [];
  bool _situacaoTurma = true;
  bool _carregando = true;
  bool _salvando = false;

  bool get _isEdicao => widget.turma != null;

  @override
  void initState() {
    super.initState();
    final t = widget.turma;
    if (t != null) {
      _nomeTurmaController.text = t.nomeTurma;
      _situacaoTurma = t.ativa;
      _alunosSelecionados.addAll(t.listaAlunos.map((a) => a.id));
    }
    _carregarAlunos();
  }

  @override
  void dispose() {
    _nomeTurmaController.dispose();
    super.dispose();
  }

  Future<void> _carregarAlunos() async {
    try {
      final alunos = await _service.listarAlunos();
      if (!mounted) return;
      setState(() {
        _alunos = alunos;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregando = false);
      _mensagem('Erro ao carregar alunos: $e');
    }
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

    Future<void> _salvarTurma() async {
    if (!_formKey.currentState!.validate()) return;

    if (_alunosSelecionados.isEmpty) {
      _mensagem('Selecione ao menos um aluno para a turma');
      return;
    }

    setState(() => _salvando = true);
    try {
      final turma = Turma(
        id: widget.turma?.id ?? '',
        nomeTurma: _nomeTurmaController.text.trim(),
        listaAlunos:
            _alunos.where((a) => _alunosSelecionados.contains(a.id)).toList(),
        ativa: _situacaoTurma,
      );

      await _service.salvar(turma);
      if (!mounted) return;

      if (_isEdicao) {
        _mensagem('Turma atualizada com sucesso!');
        Navigator.pop(context, true);
        return;
      }

      // Cadastro novo: permanece na tela e limpa os campos
      _nomeTurmaController.clear();
      _formKey.currentState!.reset(); // evita mostrar erro de validação no campo vazio
      setState(() {
        _alunosSelecionados.clear();
        _situacaoTurma = true;
        _salvando = false;
      });
      _mensagem('Turma cadastrada com sucesso!');
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      _mensagem('Erro ao salvar: $e');
    }
  }

  void _excluirTurma() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text(
            'Deseja realmente excluir a turma ${widget.turma!.nomeTurma}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _service.excluir(widget.turma!.id);
                if (!mounted) return;
                Navigator.pop(context, true);
              } catch (e) {
                if (!mounted) return;
                _mensagem('Erro ao excluir: $e');
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdicao ? 'Editar Turma' : widget.title),
        actions: [
          if (_isEdicao)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Excluir turma',
              onPressed: _excluirTurma,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nomeTurmaController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Turma',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.class_),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o nome da turma';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: CheckboxListTile(
                      value: _situacaoTurma,
                      title: const Text('Turma ativa'),
                      subtitle: Text(_situacaoTurma
                          ? 'A turma está em andamento'
                          : 'A turma está inativa/encerrada'),
                      onChanged: (value) =>
                          setState(() => _situacaoTurma = value ?? true),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Selecione os alunos',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: _carregando
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : _alunos.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('Nenhum aluno cadastrado ainda.'),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _alunos.length,
                                separatorBuilder: (_, _) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final aluno = _alunos[index];
                                  return CheckboxListTile(
                                    value:
                                        _alunosSelecionados.contains(aluno.id),
                                    title: Text(aluno.nome),
                                    subtitle: Text(aluno.email),
                                    secondary: CircleAvatar(
                                      radius: 16,
                                      child: Text(aluno.nome[0]),
                                    ),
                                    onChanged: (checked) {
                                      setState(() {
                                        if (checked == true) {
                                          _alunosSelecionados.add(aluno.id);
                                        } else {
                                          _alunosSelecionados.remove(aluno.id);
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_alunosSelecionados.length} aluno(s) selecionado(s)',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _salvando ? null : _salvarTurma,
                    icon: _salvando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                        _isEdicao ? 'Salvar Alterações' : 'Cadastrar Turma'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}