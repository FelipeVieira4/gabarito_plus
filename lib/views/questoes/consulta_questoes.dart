import 'package:flutter/material.dart';
import 'package:gabarito_plus/models/assunto.dart';
import 'package:gabarito_plus/models/disciplina.dart';
import 'package:gabarito_plus/models/questao.dart';
import 'package:gabarito_plus/services/questoes_service.dart';
import 'package:gabarito_plus/views/questoes/cadastro_questao.dart';
import 'package:gabarito_plus/views/questoes/detalhes_questoes.dart';

class ListaQuestoesView extends StatefulWidget {
  const ListaQuestoesView({super.key});

  @override
  State<ListaQuestoesView> createState() => _ListaQuestoesViewState();
}

class _ListaQuestoesViewState extends State<ListaQuestoesView> {
  final _service = QuestoesService();
  final _buscaController = TextEditingController();

  late final List<Disciplina> _disciplinas;
  Disciplina? _disciplinaFiltro;
  Assunto? _assuntoFiltro;

  List<Questao> _questoesFiltradas = [];

  @override
  void initState() {
    super.initState();
    _disciplinas = _service.obterDisciplinas();
    _aplicarFiltros();
  }

  void _aplicarFiltros() {
    setState(() {
      _questoesFiltradas = _service.obterQuestoes(
        disciplinaId: _disciplinaFiltro?.id,
        assuntoId: _assuntoFiltro?.id,
        busca: _buscaController.text,
      );
    });
  }

  void _selecionarDisciplinaFiltro(Disciplina? disciplina) {
    setState(() {
      _disciplinaFiltro = disciplina;
      _assuntoFiltro = null;
    });
    _aplicarFiltros();
  }

  void _selecionarAssuntoFiltro(Assunto? assunto) {
    setState(() {
      _assuntoFiltro = assunto;
    });
    _aplicarFiltros();
  }

  void _limparFiltros() {
    _buscaController.clear();
    setState(() {
      _disciplinaFiltro = null;
      _assuntoFiltro = null;
    });
    _aplicarFiltros();
  }

  Future<void> _abrirEdicaoQuestao(
    Questao questao,
    Disciplina? disciplina,
    Assunto? assunto,
  ) async {
    final editouComSucesso = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroQuestaoView(
          questaoParaEditar: questao,
          disciplinaInicial: disciplina,
          assuntoInicial: assunto,
        ),
      ),
    );

    if (editouComSucesso == true) {
      _aplicarFiltros();
    }
  }

  @override
  Widget build(BuildContext context) {
    final assuntosDoFiltro = _disciplinaFiltro == null
        ? const <Assunto>[]
        : _service.obterAssuntos(disciplinaId: _disciplinaFiltro!.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Banco de Questões'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;

          return Center(
            child: ConstrainedBox(
              // Trava a largura no desktop pra não esticar filtros e cards
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: TextField(
                      controller: _buscaController,
                      onChanged: (_) => _aplicarFiltros(),
                      decoration: InputDecoration(
                        labelText: 'Buscar no enunciado...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<Disciplina>(
                            value: _disciplinaFiltro,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Disciplina',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            hint: const Text('Todas'),
                            items: _disciplinas
                                .map((disciplina) => DropdownMenuItem(
                                      value: disciplina,
                                      child: Text(disciplina.descricao),
                                    ))
                                .toList(),
                            onChanged: _selecionarDisciplinaFiltro,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<Assunto>(
                            value: _assuntoFiltro,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Assunto',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            hint: const Text('Todos'),
                            items: assuntosDoFiltro
                                .map((assunto) => DropdownMenuItem(
                                      value: assunto,
                                      child: Text(assunto.nome),
                                    ))
                                .toList(),
                            onChanged: _disciplinaFiltro == null
                                ? null
                                : _selecionarAssuntoFiltro,
                          ),
                        ),
                        if (_disciplinaFiltro != null || _assuntoFiltro != null)
                          IconButton(
                            tooltip: 'Limpar filtros',
                            icon: const Icon(Icons.filter_alt_off),
                            onPressed: _limparFiltros,
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _questoesFiltradas.isEmpty
                        ? const Center(child: Text('Nenhuma questão encontrada.'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: _questoesFiltradas.length,
                            itemBuilder: (context, index) {
                              final questao = _questoesFiltradas[index];
                              final disciplina =
                                  _service.obterDisciplinaDaQuestao(questao);
                              final assunto =
                                  _service.obterAssuntoDaQuestao(questao);

                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 12.0),
                                child: ListTile(
                                  // Um pouco mais de respiro nas laterais em telas largas
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: isWide ? 20 : 16,
                                    vertical: 8,
                                  ),
                                  title: Text(
                                    questao.enunciado,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    '${disciplina?.descricao ?? '-'} - ${assunto?.nome ?? '-'}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        tooltip: 'Editar questão',
                                        onPressed: () {
                                          _abrirEdicaoQuestao(
                                              questao, disciplina, assunto);
                                        },
                                      ),
                                      const Icon(Icons.arrow_forward_ios,
                                          size: 16.0),
                                    ],
                                  ),
                                  onTap: () {
                                    if (disciplina == null || assunto == null) {
                                      return;
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetalhesQuestaoView(
                                          questao: questao,
                                          disciplina: disciplina,
                                          assunto: assunto,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final cadastrouComSucesso = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const CadastroQuestaoView(),
            ),
          );

          if (cadastrouComSucesso == true) {
            _aplicarFiltros();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }
}