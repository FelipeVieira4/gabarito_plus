import 'package:flutter/material.dart';
import 'package:gabarito_plus/mocks/mock_assunto.dart';
import 'package:gabarito_plus/mocks/mock_turma.dart';
import 'package:gabarito_plus/models/assunto.dart';
import 'package:gabarito_plus/models/prova.dart';
import 'package:gabarito_plus/models/questao.dart';
import 'package:gabarito_plus/models/turma.dart';
import 'package:gabarito_plus/views/provas/visualizacao_embaralhamento.dart';

class ConfiguracaoProva extends StatefulWidget {
  const ConfiguracaoProva({super.key});

  @override
  State<ConfiguracaoProva> createState() => _ConfiguracaoProvaState();
}

class _ConfiguracaoProvaState extends State<ConfiguracaoProva> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();

  Turma? _turmaSelecionada;
  Assunto? _assuntoSelecionado;
  final Set<Questao> _questoesSelecionadas = {};

  bool _embaralharQuestoes = true;
  bool _embaralharAlternativas = true;

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  void _gerarProvas() {
    if (!_formKey.currentState!.validate()) return;

    if (_turmaSelecionada == null) {
      _mostrarAviso('Selecione uma turma para aplicar a prova');
      return;
    }

    if (_assuntoSelecionado == null) {
      _mostrarAviso('Selecione o assunto da prova');
      return;
    }

    if (_questoesSelecionadas.isEmpty) {
      _mostrarAviso('Selecione ao menos uma questão para a prova');
      return;
    }

    if (_turmaSelecionada!.listaAlunos.isEmpty) {
      _mostrarAviso('A turma selecionada não possui alunos cadastrados');
      return;
    }

    final prova = Prova(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: _tituloController.text.trim(),
      turma: _turmaSelecionada!,
      assunto: _assuntoSelecionado!,
      questoes: _questoesSelecionadas.toList(),
      embaralharQuestoes: _embaralharQuestoes,
      embaralharAlternativas: _embaralharAlternativas,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VisualizacaoEmbaralhamento(prova: prova),
      ),
    );
  }

  void _mostrarAviso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  Widget build(BuildContext context) {
    final totalQuestoesSelecionadas = _questoesSelecionadas.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuração da Prova')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título da Prova',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o título da prova';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Turma>(
                initialValue: _turmaSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Turma',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.class_),
                ),
                items: listaTurma
                    .map(
                      (turma) => DropdownMenuItem(
                        value: turma,
                        child: Text(turma.nomeTurma),
                      ),
                    )
                    .toList(),
                onChanged: (turma) => setState(() => _turmaSelecionada = turma),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Assunto>(
                initialValue: _assuntoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Assunto da Prova',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.topic),
                ),
                items: bancoAssuntosMock
                    .map(
                      (assunto) => DropdownMenuItem(
                        value: assunto,
                        child: Text('${assunto.nome} (${assunto.questoes.length} questões)'),
                      ),
                    )
                    .toList(),
                onChanged: (assunto) => setState(() {
                  _assuntoSelecionado = assunto;
                  _questoesSelecionadas.clear();
                }),
              ),
              const SizedBox(height: 24),
              if (_assuntoSelecionado == null)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Selecione um assunto para listar as questões relacionadas',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Questões de ${_assuntoSelecionado!.nome}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
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
                    itemCount: _assuntoSelecionado!.questoes.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final questao = _assuntoSelecionado!.questoes[index];
                      final selecionada = _questoesSelecionadas.contains(questao);

                      return CheckboxListTile(
                        value: selecionada,
                        title: Text(questao.enunciado),
                        subtitle: Text('${questao.alternativas.length} alternativas'),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _questoesSelecionadas.add(questao);
                            } else {
                              _questoesSelecionadas.remove(questao);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$totalQuestoesSelecionadas ${totalQuestoesSelecionadas == 1 ? "questão selecionada" : "questões selecionadas"}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Embaralhamento',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      value: _embaralharQuestoes,
                      title: const Text('Embaralhar ordem das questões'),
                      subtitle: const Text('Cada aluno recebe as questões em uma ordem diferente'),
                      onChanged: (value) => setState(() => _embaralharQuestoes = value),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      value: _embaralharAlternativas,
                      title: const Text('Embaralhar ordem das alternativas'),
                      subtitle: const Text('A posição da alternativa correta muda a cada prova'),
                      onChanged: (value) => setState(() => _embaralharAlternativas = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _gerarProvas,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Gerar Provas da Turma'),
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
