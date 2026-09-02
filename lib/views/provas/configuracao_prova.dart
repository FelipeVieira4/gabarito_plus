import 'package:flutter/material.dart';
import 'package:gabarito_plus/mocks/mock_turma.dart';
import 'package:gabarito_plus/models/disciplina.dart';
import 'package:gabarito_plus/models/prova.dart';
import 'package:gabarito_plus/models/questao.dart';
import 'package:gabarito_plus/models/turma.dart';
import 'package:gabarito_plus/services/questoes_service.dart';
import 'package:gabarito_plus/views/provas/visualizacao_embaralhamento.dart';

class ConfiguracaoProva extends StatefulWidget {
  const ConfiguracaoProva({super.key});

  @override
  State<ConfiguracaoProva> createState() => _ConfiguracaoProvaState();
}

class _ConfiguracaoProvaState extends State<ConfiguracaoProva> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _questoesService = QuestoesService();

  late final List<Disciplina> _disciplinas;
  
  Disciplina? _disciplinaSelecionada;
  Turma? _turmaSelecionada;

  final Set<Questao> _questoesSelecionadas = {};

  bool _embaralharQuestoes = true;
  bool _embaralharAlternativas = true;

  @override
  void initState() {
    super.initState();
    _disciplinas = _questoesService.obterDisciplinas();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  List<Questao> get _todasQuestoesDaDisciplina {
    if (_disciplinaSelecionada == null) return [];
    return _disciplinaSelecionada!.assuntos
        .expand((assunto) => assunto.questoes)
        .toList();
  }

  void _gerarProvas() {
    if (!_formKey.currentState!.validate()) return;

    if (_turmaSelecionada == null) {
      _mostrarAviso('Selecione uma turma para aplicar a prova');
      return;
    }

    if (_disciplinaSelecionada == null) {
      _mostrarAviso('Selecione a disciplina da prova');
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

    // Como o campo Assunto da Prova foi removido na interface, se a model Prova exigir 
    // obrigatoriamente um único Assunto, pegamos o do primeiro item selecionado ou o primeiro da disciplina.
    final primeiroAssunto = _disciplinaSelecionada!.assuntos.firstWhere(
      (a) => a.questoes.any((q) => _questoesSelecionadas.contains(q)),
      orElse: () => _disciplinaSelecionada!.assuntos.first,
    );

    final prova = Prova(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: _tituloController.text.trim(),
      turma: _turmaSelecionada!,
      assunto: primeiroAssunto,
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  void _alternarSelecaoTodasQuestoes(bool? selecionarTodas) {
    setState(() {
      if (selecionarTodas == true) {
        _questoesSelecionadas.addAll(_todasQuestoesDaDisciplina);
      } else {
        _questoesSelecionadas.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuração da Prova'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo Título
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

              // Seleção de Turma
              DropdownButtonFormField<Turma>(
                initialValue: _turmaSelecionada,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Turma',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.class_),
                ),
                items: listaTurma
                    .map((turma) => DropdownMenuItem(
                          value: turma,
                          child: Text(
                            turma.nomeTurma,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (turma) => setState(() => _turmaSelecionada = turma),
                validator: (value) => value == null ? 'Selecione uma turma' : null,
              ),
              const SizedBox(height: 16),

              // Seleção de Disciplina
              DropdownButtonFormField<Disciplina>(
                initialValue: _disciplinaSelecionada,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Disciplina',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school),
                ),
                items: _disciplinas
                    .map((disciplina) => DropdownMenuItem(
                          value: disciplina,
                          child: Text(
                            disciplina.descricao,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (disciplina) {
                  setState(() {
                    _disciplinaSelecionada = disciplina;
                    _questoesSelecionadas.clear();
                  });
                },
                validator: (value) =>
                    value == null ? 'Selecione uma disciplina' : null,
              ),
              const SizedBox(height: 24),

              // Listagem de Questões Agrupadas por Assunto
              _buildSecaoQuestoes(),
              const SizedBox(height: 24),

              // Opções de Embaralhamento
              _buildSecaoEmbaralhamento(),
              const SizedBox(height: 24),

              // Botão Principal
              ElevatedButton.icon(
                onPressed: _gerarProvas,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Gerar Provas da Turma'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecaoQuestoes() {
    if (_disciplinaSelecionada == null) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Selecione uma disciplina para listar as questões disponíveis.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final totalQuestoes = _todasQuestoesDaDisciplina.length;
    final todasSelecionadas = totalQuestoes > 0 &&
        _questoesSelecionadas.length == totalQuestoes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Questões de ${_disciplinaSelecionada!.descricao}',
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (totalQuestoes > 0)
              TextButton(
                onPressed: () => _alternarSelecaoTodasQuestoes(!todasSelecionadas),
                child: Text(todasSelecionadas ? 'Desmarcar todas' : 'Marcar todas'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Column(
            children: _disciplinaSelecionada!.assuntos.map((assunto) {
              if (assunto.questoes.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cabeçalho do Assunto
                  Container(
                    color: Theme.of(context).colorScheme.primaryContainer.withAlpha(50),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text(
                      'Assunto: ${assunto.nome}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const Divider(height: 1),

                  // Lista de Questões do Assunto
                  ...assunto.questoes.map((questao) {
                    final selecionada = _questoesSelecionadas.contains(questao);

                    return Column(
                      children: [
                        CheckboxListTile(
                          value: selecionada,
                          title: Text(questao.enunciado),
                          subtitle: Text(
                            'Assunto: ${assunto.nome} • ${questao.alternativas.length} alternativas',
                          ),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _questoesSelecionadas.add(questao);
                              } else {
                                _questoesSelecionadas.remove(questao);
                              }
                            });
                          },
                        ),
                        const Divider(height: 1),
                      ],
                    );
                  }),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_questoesSelecionadas.length} de $totalQuestoes questões selecionadas',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSecaoEmbaralhamento() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Embaralhamento',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
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
                subtitle: const Text(
                  'Cada aluno recebe as questões em uma ordem diferente',
                ),
                onChanged: (value) => setState(() => _embaralharQuestoes = value),
              ),
              const Divider(height: 1),
              SwitchListTile(
                value: _embaralharAlternativas,
                title: const Text('Embaralhar ordem das alternativas'),
                subtitle: const Text(
                  'A posição da alternativa correta muda a cada prova',
                ),
                onChanged: (value) =>
                    setState(() => _embaralharAlternativas = value),
              ),
            ],
          ),
        ),
      ],
    );
  }
}