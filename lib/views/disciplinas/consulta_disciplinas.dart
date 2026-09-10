import 'package:flutter/material.dart';
import 'package:gabarito_plus/mocks/mock_disciplina.dart';
import 'package:gabarito_plus/mocks/mock_professor.dart';
import 'package:gabarito_plus/models/assunto.dart';
import 'package:gabarito_plus/models/disciplina.dart';
import 'package:gabarito_plus/services/questoes_service.dart';

class ConsultaDisciplinasView extends StatefulWidget {
  const ConsultaDisciplinasView({super.key});

  @override
  State<ConsultaDisciplinasView> createState() =>
      _ConsultaDisciplinasViewState();
}

class _ConsultaDisciplinasViewState extends State<ConsultaDisciplinasView> {
  final _service = QuestoesService();
  final _buscaController = TextEditingController();
  String? _disciplinaExpandidaId;

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  List<Disciplina> get _disciplinasFiltradas {
    final todas = _service.obterDisciplinas();
    final termo = _buscaController.text.trim().toLowerCase();
    if (termo.isEmpty) return todas;

    return todas.where((d) {
      final bateDisciplina = d.descricao.toLowerCase().contains(termo);
      final bateAssunto =
          d.assuntos.any((a) => a.nome.toLowerCase().contains(termo));
      return bateDisciplina || bateAssunto;
    }).toList();
  }

  Future<void> _exibirModalNovoAssunto() async {
    final disciplinaIdAtualizada = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (modalContext) => ModalCadastroAssunto(
        onSalvo: () {},
      ),
    );

    if (disciplinaIdAtualizada != null) {
      setState(() {
        _disciplinaExpandidaId = disciplinaIdAtualizada;
      });
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final disciplinas = _disciplinasFiltradas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disciplinas & Assuntos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo de Busca
            TextField(
              controller: _buscaController,
              decoration: InputDecoration(
                hintText: 'Buscar disciplina ou assunto...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _buscaController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _buscaController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Lista de Disciplinas e Assuntos
            Expanded(
              child: disciplinas.isEmpty
                  ? const Center(
                      child: Text('Nenhuma disciplina ou assunto encontrado.'),
                    )
                  : ListView.separated(
                      itemCount: disciplinas.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final disciplina = disciplinas[index];
                        final isExpandida =
                            disciplina.id == _disciplinaExpandidaId;

                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ExpansionTile(
                            key: ValueKey('${disciplina.id}_$isExpandida'),
                            initiallyExpanded: isExpandida,
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              child: Icon(
                                Icons.school,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            title: Text(
                              disciplina.descricao,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${disciplina.assuntos.length} assunto(s) cadastrado(s)',
                            ),
                            children: disciplina.assuntos.isEmpty
                                ? [
                                    const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        'Nenhum assunto cadastrado para esta disciplina.',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  ]
                                : disciplina.assuntos.map((assunto) {
                                    return ListTile(
                                      leading: const Icon(
                                        Icons.topic,
                                        color: Colors.purple,
                                      ),
                                      title: Text(assunto.nome),
                                      subtitle: Text(
                                        '${assunto.questoes.length} questão(ões)',
                                      ),
                                    );
                                  }).toList(),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Novo Assunto',
        onPressed: _exibirModalNovoAssunto,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ModalCadastroAssunto extends StatefulWidget {
  final VoidCallback? onSalvo;

  const ModalCadastroAssunto({super.key, this.onSalvo});

  @override
  State<ModalCadastroAssunto> createState() => _ModalCadastroAssuntoState();
}

class _ModalCadastroAssuntoState extends State<ModalCadastroAssunto> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  String? _disciplinaSelecionada;

  List<String> get _opcoesDisciplinas {
    final doProfessor = usuarioMock.disciplinas;
    final doMock = listaDisciplina.map((d) => d.descricao);
    final unificadas = <String>{...doProfessor, ...doMock};
    return unificadas.toList();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      final disciplinaNome = _disciplinaSelecionada!;
      final nomeAssunto = _nomeController.text.trim();

      // Procura a disciplina no mock listaDisciplina ou cria uma nova se não existir
      final disciplina = listaDisciplina.firstWhere(
        (d) => d.descricao.toLowerCase() == disciplinaNome.toLowerCase(),
        orElse: () {
          final novaDisciplina = Disciplina(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            descricao: disciplinaNome,
            assuntos: [],
          );
          listaDisciplina.add(novaDisciplina);
          return novaDisciplina;
        },
      );

      // Adiciona o novo assunto na disciplina no mock
      disciplina.assuntos.add(
        Assunto(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nome: nomeAssunto,
          questoes: [],
        ),
      );

      if (widget.onSalvo != null) {
        widget.onSalvo!();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Assunto cadastrado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, disciplina.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Cadastrar Novo Assunto',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: _disciplinaSelecionada,
                  decoration: const InputDecoration(
                    labelText: 'Disciplina',
                    prefixIcon: Icon(Icons.school),
                    border: OutlineInputBorder(),
                  ),
                  items: _opcoesDisciplinas.map((disciplina) {
                    return DropdownMenuItem<String>(
                      value: disciplina,
                      child: Text(disciplina),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _disciplinaSelecionada = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecione uma disciplina';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Assunto',
                    prefixIcon: Icon(Icons.topic),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o nome do assunto';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _salvar,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Salvar',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
