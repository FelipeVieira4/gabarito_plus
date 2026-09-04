import 'package:flutter/material.dart';
import 'package:gabarito_plus/models/alternativa.dart';
import 'package:gabarito_plus/models/assunto.dart';
import 'package:gabarito_plus/models/disciplina.dart';
import 'package:gabarito_plus/models/questao.dart';
import 'package:gabarito_plus/services/questoes_service.dart';
import 'package:gabarito_plus/widgets/responsive_container.dart'; // ajuste o caminho

class CadastroQuestaoView extends StatefulWidget {
  final Questao? questaoParaEditar;
  final Disciplina? disciplinaInicial;
  final Assunto? assuntoInicial;

  const CadastroQuestaoView({
    super.key,
    this.questaoParaEditar,
    this.disciplinaInicial,
    this.assuntoInicial,
  });

  bool get isEdicao => questaoParaEditar != null;

  @override
  State<CadastroQuestaoView> createState() => _CadastroQuestaoViewState();
}

class _CadastroQuestaoViewState extends State<CadastroQuestaoView> {
  final _service = QuestoesService();
  final _formKey = GlobalKey<FormState>();
  final _enunciadoController = TextEditingController();
  final List<TextEditingController> _alternativasControllers =
      List.generate(4, (_) => TextEditingController());
  int _alternativaCorretaIndex = 0;

  late final List<Disciplina> _disciplinas;
  Disciplina? _disciplinaSelecionada;
  Assunto? _assuntoSelecionado;

  @override
  void initState() {
    super.initState();
    _disciplinas = _service.obterDisciplinas();

    if (widget.isEdicao) {
      _carregarDadosEdicao();
    }
  }

  void _carregarDadosEdicao() {
    final q = widget.questaoParaEditar!;
    _enunciadoController.text = q.enunciado;

    _disciplinaSelecionada =
        widget.disciplinaInicial ?? _service.obterDisciplinaDaQuestao(q);

    if (_disciplinaSelecionada != null) {
      _assuntoSelecionado =
          widget.assuntoInicial ?? _service.obterAssuntoDaQuestao(q);
    }

    for (int i = 0; i < q.alternativas.length && i < 4; i++) {
      _alternativasControllers[i].text = q.alternativas[i].texto;
      if (q.alternativas[i].isCorreta) {
        _alternativaCorretaIndex = i;
      }
    }
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;

    final alternativas = List.generate(4, (index) {
      return Alternativa(
        texto: _alternativasControllers[index].text,
        isCorreta: index == _alternativaCorretaIndex,
      );
    });

    if (widget.isEdicao) {
      final questaoAtualizada = Questao(
        id: widget.questaoParaEditar!.id,
        enunciado: _enunciadoController.text,
        alternativas: alternativas,
      );

      _service.editarQuestao(
        disciplinaId: _disciplinaSelecionada!.id,
        assuntoId: _assuntoSelecionado!.id,
        questao: questaoAtualizada,
      );
    } else {
      final novaQuestao = _service.criarQuestao(
        enunciado: _enunciadoController.text,
        alternativas: alternativas,
      );

      _service.adicionarQuestao(
        disciplinaId: _disciplinaSelecionada!.id,
        assuntoId: _assuntoSelecionado!.id,
        questao: novaQuestao,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isEdicao
              ? 'Questão atualizada com sucesso!'
              : 'Questão cadastrada com sucesso!',
        ),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final assuntosDaDisciplina = _disciplinaSelecionada?.assuntos ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdicao ? 'Editar Questão' : 'Cadastrar Questão'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;

          return SingleChildScrollView(
            child: ResponsiveContainer(
              maxWidth: 800,
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Disciplina e Assunto lado a lado no desktop
                    isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _campoDisciplina()),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: _campoAssunto(assuntosDaDisciplina)),
                            ],
                          )
                        : Column(
                            children: [
                              _campoDisciplina(),
                              const SizedBox(height: 16),
                              _campoAssunto(assuntosDaDisciplina),
                            ],
                          ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _enunciadoController,
                      decoration: const InputDecoration(
                        labelText: 'Enunciado da Questão',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Campo obrigatório'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Alternativas (Marque a correta):',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),

                    // No desktop, alternativas em grid 2x2; no mobile, empilhadas
                    isWide
                        ? GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 4,
                            childAspectRatio: 6,
                            children: List.generate(
                                4, (index) => _campoAlternativa(index)),
                          )
                        : Column(
                            children:
                                List.generate(4, (index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: _campoAlternativa(index),
                              );
                            }),
                          ),

                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _salvar,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        widget.isEdicao
                            ? 'Salvar Alterações'
                            : 'Salvar Questão',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _campoDisciplina() {
    return DropdownButtonFormField<Disciplina>(
      initialValue: _disciplinaSelecionada,
      decoration: const InputDecoration(
        labelText: 'Disciplina',
        border: OutlineInputBorder(),
      ),
      items: _disciplinas
          .map((disciplina) => DropdownMenuItem(
                value: disciplina,
                child: Text(disciplina.descricao),
              ))
          .toList(),
      onChanged: (disciplina) {
        setState(() {
          _disciplinaSelecionada = disciplina;
          _assuntoSelecionado = null;
        });
      },
      validator: (disciplina) =>
          disciplina == null ? 'Selecione uma disciplina' : null,
    );
  }

  Widget _campoAssunto(List<Assunto> assuntosDaDisciplina) {
    return DropdownButtonFormField<Assunto>(
      initialValue: _assuntoSelecionado,
      decoration: const InputDecoration(
        labelText: 'Assunto',
        border: OutlineInputBorder(),
      ),
      items: assuntosDaDisciplina
          .map((assunto) => DropdownMenuItem(
                value: assunto,
                child: Text(assunto.nome),
              ))
          .toList(),
      onChanged: _disciplinaSelecionada == null
          ? null
          : (assunto) {
              setState(() {
                _assuntoSelecionado = assunto;
              });
            },
      validator: (assunto) => assunto == null ? 'Selecione um assunto' : null,
      hint: _disciplinaSelecionada == null
          ? const Text('Selecione a disciplina primeiro')
          : null,
    );
  }

  Widget _campoAlternativa(int index) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _alternativaCorretaIndex = index;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              _alternativaCorretaIndex == index
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: _alternativaCorretaIndex == index
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: TextFormField(
            controller: _alternativasControllers[index],
            decoration: InputDecoration(
              labelText: 'Alternativa ${String.fromCharCode(65 + index)}',
              border: const OutlineInputBorder(),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Campo obrigatório' : null,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _enunciadoController.dispose();
    for (var controller in _alternativasControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}