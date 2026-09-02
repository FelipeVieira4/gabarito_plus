import 'package:flutter/material.dart';
import 'package:gabarito_plus/models/alternativa.dart';
import 'package:gabarito_plus/models/assunto.dart';
import 'package:gabarito_plus/models/disciplina.dart';
import 'package:gabarito_plus/services/questoes_service.dart';

class CadastroQuestaoView extends StatefulWidget {
  const CadastroQuestaoView({super.key});

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
  }

  @override
  Widget build(BuildContext context) {
    final assuntosDaDisciplina = _disciplinaSelecionada?.assuntos ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Questão'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            DropdownButtonFormField<Disciplina>(
              initialValue: _disciplinaSelecionada,
              decoration: const InputDecoration(
                  labelText: 'Disciplina', border: OutlineInputBorder()),
              items: _disciplinas
                  .map((disciplina) => DropdownMenuItem(
                        value: disciplina,
                        child: Text(disciplina.descricao),
                      ))
                  .toList(),
              onChanged: (disciplina) {
                setState(() {
                  _disciplinaSelecionada = disciplina;
                  // Assunto pertence a uma disciplina específica, então
                  // toda vez que a disciplina muda a seleção antiga não
                  // faz mais sentido.
                  _assuntoSelecionado = null;
                });
              },
              validator: (disciplina) =>
                  disciplina == null ? 'Selecione uma disciplina' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Assunto>(
              initialValue: _assuntoSelecionado,
              decoration: const InputDecoration(
                  labelText: 'Assunto', border: OutlineInputBorder()),
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
              validator: (assunto) =>
                  assunto == null ? 'Selecione um assunto' : null,
              hint: _disciplinaSelecionada == null
                  ? const Text('Selecione a disciplina primeiro')
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _enunciadoController,
              decoration: const InputDecoration(
                  labelText: 'Enunciado da Questão',
                  border: OutlineInputBorder()),
              maxLines: 3,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 24),
            const Text('Alternativas (Marque a correta):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Column(
              children: List.generate(4, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
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
                            labelText:
                                'Alternativa ${String.fromCharCode(65 + index)}',
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty
                                  ? 'Campo obrigatório'
                                  : null,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final novaQuestao = _service.criarQuestao(
                    enunciado: _enunciadoController.text,
                    alternativas: List.generate(4, (index) {
                      return Alternativa(
                        texto: _alternativasControllers[index].text,
                        isCorreta: index == _alternativaCorretaIndex,
                      );
                    }),
                  );

                  _service.adicionarQuestao(
                    disciplinaId: _disciplinaSelecionada!.id,
                    assuntoId: _assuntoSelecionado!.id,
                    questao: novaQuestao,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Questão cadastrada com sucesso!'),
                        backgroundColor: Colors.green),
                  );

                  // Só avisa a tela anterior que precisa recarregar a
                  // lista; quem detém os dados agora é o QuestoesService.
                  Navigator.pop(context, true);
                }
              },
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child:
                  const Text('Salvar Questão', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
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