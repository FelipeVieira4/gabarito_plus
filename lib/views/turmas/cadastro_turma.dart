import 'package:flutter/material.dart';
import 'package:gabarito_plus/mocks/mock_aluno.dart';
import 'package:gabarito_plus/mocks/mock_turma.dart';
import 'package:gabarito_plus/models/aluno.dart';
import 'package:gabarito_plus/models/turma.dart';

class CadastroTurma extends StatefulWidget {
  const CadastroTurma({super.key, required this.title});

  final String title;

  @override
  State<CadastroTurma> createState() => _CadastroTurmaState();
}

class _CadastroTurmaState extends State<CadastroTurma> {
  final _formKey = GlobalKey<FormState>();
  final _nomeTurmaController = TextEditingController();

  // Guarda os alunos selecionados pra essa turma
  final Set<Aluno> _alunosSelecionados = {};

  @override
  void dispose() {
    _nomeTurmaController.dispose();
    super.dispose();
  }

  void _salvarTurma() {
    if (_formKey.currentState!.validate()) {
      if (_alunosSelecionados.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione ao menos um aluno para a turma'),
          ),
        );
        return;
      }

      final novaTurma = Turma(
        id: (listaTurma.length + 1).toString(),
        nomeTurma: _nomeTurmaController.text.trim(),
        listaAlunos: _alunosSelecionados.toList(),
      );

      setState(() {
        listaTurma.add(novaTurma);
      });

      _nomeTurmaController.clear();
      _alunosSelecionados.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Turma cadastrada com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Selecione os alunos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              // Lista de alunos disponíveis pra vincular na turma
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
                          final selecionado = _alunosSelecionados.contains(aluno);

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
                                  _alunosSelecionados.remove(aluno);
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
                label: const Text('Cadastrar Turma'),
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