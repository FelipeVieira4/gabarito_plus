import 'package:flutter/material.dart';
import 'package:gabarito_plus/mocks/mock_aluno.dart';
import 'package:gabarito_plus/mocks/mock_turma.dart';
import 'package:gabarito_plus/models/aluno.dart';
import 'package:gabarito_plus/models/turma.dart';

class CadastroTurma extends StatefulWidget {
  const CadastroTurma({super.key, required this.title, this.turma});

  final String title;
  final Turma? turma;

  @override
  State<CadastroTurma> createState() => _CadastroTurmaState();
}

class _CadastroTurmaState extends State<CadastroTurma> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nomeTurmaController = TextEditingController();

  final Set<Aluno> _alunosSelecionados = {};
  bool _situacaoTurma = true;

  Turma? _turmaEncontrada;

  bool get _isEdicao => _turmaEncontrada != null;

  @override
  void initState() {
    super.initState();
    if (widget.turma != null) {
      _idController.text = widget.turma!.id;
      _carregarTurma(widget.turma!.id);
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nomeTurmaController.dispose();
    super.dispose();
  }

  void _carregarTurma(String id) {
    final encontrada = listaTurma.where((t) => t.id == id).toList();

    setState(() {
      if (encontrada.isNotEmpty) {
        _turmaEncontrada = encontrada.first;
        _nomeTurmaController.text = _turmaEncontrada!.nomeTurma;
        _situacaoTurma = _turmaEncontrada!.ativa;
        _alunosSelecionados
          ..clear()
          ..addAll(_turmaEncontrada!.listaAlunos);
      } else {
        _turmaEncontrada = null;
        _nomeTurmaController.clear();
        _situacaoTurma = true;
        _alunosSelecionados.clear();
      }
    });
  }

  void _salvarTurma() {
    if (!_formKey.currentState!.validate()) return;

    if (_alunosSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione ao menos um aluno para a turma'),
        ),
      );
      return;
    }

    final idDigitado = _idController.text.trim();

    if (_isEdicao) {
      final index = listaTurma.indexWhere((t) => t.id == _turmaEncontrada!.id);
      if (index != -1) {
        setState(() {
          listaTurma[index] = Turma(
            id: _turmaEncontrada!.id,
            nomeTurma: _nomeTurmaController.text.trim(),
            listaAlunos: _alunosSelecionados.toList(),
            ativa: _situacaoTurma,
          );
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Turma atualizada com sucesso!')),
      );
    } else {
      final novoId = idDigitado.isNotEmpty
          ? idDigitado
          : (listaTurma.length + 1).toString();

      final novaTurma = Turma(
        id: novoId,
        nomeTurma: _nomeTurmaController.text.trim(),
        listaAlunos: _alunosSelecionados.toList(),
        ativa: _situacaoTurma,
      );

      setState(() {
        listaTurma.add(novaTurma);
        _turmaEncontrada = novaTurma;
        _idController.text = novaTurma.id;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Turma cadastrada com sucesso!')),
      );
    }
  }

  void _excluirTurma() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir a turma ${_turmaEncontrada!.nomeTurma}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                listaTurma.removeWhere((t) => t.id == _turmaEncontrada!.id);
              });
              Navigator.pop(ctx);
              Navigator.pop(context);
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: ConstrainedBox(
                // Um pouco mais largo que o de aluno, pra acomodar a lista de alunos
                constraints: const BoxConstraints(maxWidth: 700),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ID e Nome lado a lado no desktop, empilhados no mobile
                      isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 1, child: _campoId()),
                                const SizedBox(width: 16),
                                Expanded(flex: 2, child: _campoNomeTurma()),
                              ],
                            )
                          : Column(
                              children: [
                                _campoId(),
                                const SizedBox(height: 16),
                                _campoNomeTurma(),
                              ],
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
                          onChanged: (bool? value) {
                            setState(() {
                              _situacaoTurma = value ?? true;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Selecione os alunos',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: listaAlunos.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('Nenhum aluno cadastrado ainda.'),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: listaAlunos.length,
                                separatorBuilder: (_, _) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final aluno = listaAlunos[index];
                                  final selecionado = _alunosSelecionados
                                      .any((a) => a.id == aluno.id);

                                  return CheckboxListTile(
                                    value: selecionado,
                                    title: Text(aluno.nome),
                                    subtitle: Text(aluno.email),
                                    secondary: CircleAvatar(
                                      radius: 16,
                                      child: Text(aluno.nome[0]),
                                    ),
                                    onChanged: (checked) {
                                      setState(() {
                                        if (checked == true) {
                                          _alunosSelecionados.add(aluno);
                                        } else {
                                          _alunosSelecionados.removeWhere(
                                              (a) => a.id == aluno.id);
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
                        onPressed: _salvarTurma,
                        icon: const Icon(Icons.save),
                        label: Text(
                          _isEdicao ? 'Salvar Alterações' : 'Cadastrar Turma',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _campoId() {
    return TextFormField(
      controller: _idController,
      decoration: InputDecoration(
        labelText: 'ID da Turma',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.badge),
        helperText: _idController.text.trim().isEmpty
            ? 'Deixe em branco para nova turma'
            : (_isEdicao
                ? 'Turma encontrada'
                : 'ID não encontrado — será criado ao salvar'),
        helperStyle: TextStyle(
          color: _isEdicao ? Colors.green : Colors.grey[600],
        ),
      ),
      onChanged: _carregarTurma,
    );
  }

  Widget _campoNomeTurma() {
    return TextFormField(
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
    );
  }
}