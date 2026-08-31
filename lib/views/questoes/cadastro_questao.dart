import 'package:flutter/material.dart';
import 'package:gabarito_plus/models/alternativa.dart';
import '../../models/questao.dart';

class CadastroQuestaoView extends StatefulWidget {
  const CadastroQuestaoView({super.key});

  @override
  State<CadastroQuestaoView> createState() => _CadastroQuestaoViewState();
}

class _CadastroQuestaoViewState extends State<CadastroQuestaoView> {
  final _formKey = GlobalKey<FormState>();
  final _enunciadoController = TextEditingController();
  final _disciplinaController = TextEditingController();
  final _assuntoController = TextEditingController();
  final List<TextEditingController> _alternativasControllers =
      List.generate(4, (_) => TextEditingController());
  int _alternativaCorretaIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Questão'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _disciplinaController,
              decoration: const InputDecoration(
                  labelText: 'Disciplina', border: OutlineInputBorder()),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _assuntoController,
              decoration: const InputDecoration(
                  labelText: 'Assunto', border: OutlineInputBorder()),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Campo obrigatório' : null,
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
                  final novaQuestao = Questao(
                    id: DateTime.now().toString(), // <- ID automático gerado aqui!
                    disciplina: _disciplinaController.text,
                    assunto: _assuntoController.text,
                    enunciado: _enunciadoController.text,
                    alternativas: List.generate(4, (index) {
                      return Alternativa(
                        texto: _alternativasControllers[index].text,
                        isCorreta: index == _alternativaCorretaIndex,
                      );
                    }), // <- Parêntese corrigido aqui!
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Questão cadastrada com sucesso!'),
                        backgroundColor: Colors.green),
                  );
                  
                  Navigator.pop(context, novaQuestao); 
                }
              },
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Salvar Questão', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _enunciadoController.dispose();
    _disciplinaController.dispose();
    _assuntoController.dispose();
    for (var controller in _alternativasControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}