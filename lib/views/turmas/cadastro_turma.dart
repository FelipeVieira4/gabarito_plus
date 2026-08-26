import 'package:flutter/material.dart';
import 'package:gabarito_plus/mocks/mock_aluno.dart';
import 'package:gabarito_plus/mocks/mock_turma.dart';
import 'package:gabarito_plus/models/aluno.dart';
import 'package:gabarito_plus/models/turma.dart';

class CadastroTurma extends StatefulWidget {
  const CadastroTurma({super.key, required this.title, this.turma});

  final String title;
  final Turma? turma; // se vier preenchido, já abre em modo edição

  @override
  State<CadastroTurma> createState() => _CadastroTurmaState();
}

class _CadastroTurmaState extends State<CadastroTurma> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nomeTurmaController = TextEditingController();

  final Set<Aluno> _alunosSelecionados = {};

  Turma? _turmaEncontrada; // null = ID em branco ou não encontrado

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

  // Busca a turma pelo ID digitado e preenche o formulário
  void _carregarTurma(String id) {
    final encontrada = listaTurma.where((t) => t.id == id).toList();

    setState(() {
      if (encontrada.isNotEmpty) {
        _turmaEncontrada = encontrada.first;
        _nomeTurmaController.text = _turmaEncontrada!.nomeTurma;
        _alunosSelecionados
          ..clear()
          ..addAll(_turmaEncontrada!.listaAlunos);
      } else {
        _turmaEncontrada = null;
        _nomeTurmaController.clear();
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
      // Edição: atualiza a turma encontrada
      final index = listaTurma.indexWhere((t) => t.id == _turmaEncontrada!.id);
      if (index != -1) {
        setState(() {
          listaTurma[index] = Turma(
            id: _turmaEncontrada!.id,
            nomeTurma: _nomeTurmaController.text.trim(),
            listaAlunos: _alunosSelecionados.toList(),
          );
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Turma atualizada com sucesso!')),
      );
    } else {
      // Cadastro novo: usa o ID digitado se veio preenchido, senão gera um
      final novoId = idDigitado.isNotEmpty
          ? idDigitado
          : (listaTurma.length + 1).toString();

      final novaTurma = Turma(
        id: novoId,
        nomeTurma: _nomeTurmaController.text.trim(),
        listaAlunos: _alunosSelecionados.toList(),
      );

      setState(() {
        listaTurma.add(novaTurma);
        _turmaEncontrada = novaTurma; // vira edição, útil pra corrigir na hora
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: 'ID da Turma',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.badge),
                  helperText: _idController.text.trim().isEmpty
                      ? 'Deixe em branco para nova turma'
                      : (_isEdicao ? 'Turma encontrada' : 'ID não encontrado — será criado ao salvar'),
                  helperStyle: TextStyle(
                    color: _isEdicao ? Colors.green : Colors.grey[600],
                  ),
                ),
                onChanged: _carregarTurma,
              ),
              const SizedBox(height: 16),
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
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final aluno = listaAlunos[index];
                          // Compara por ID, não por instância, pra funcionar
                          // corretamente quando os alunos vierem recarregados da turma
                          final selecionado =
                              _alunosSelecionados.any((a) => a.id == aluno.id);

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
                                  _alunosSelecionados
                                      .removeWhere((a) => a.id == aluno.id);
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
                label: Text(_isEdicao ? 'Salvar Alterações' : 'Cadastrar Turma'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}