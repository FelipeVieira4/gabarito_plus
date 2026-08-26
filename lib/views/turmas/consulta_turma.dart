import 'package:flutter/material.dart';
import 'package:gabarito_plus/mocks/mock_turma.dart';
import 'package:gabarito_plus/models/turma.dart';
import 'package:gabarito_plus/services/TurmaService.dart'; // ajuste o caminho
import 'package:gabarito_plus/views/turmas/cadastro_turma.dart'; // ajuste o caminho

// TODO: paginação quando os dados vierem da API
// adicionar filtro por nome/período

class ConsultaTurma extends StatefulWidget {
  const ConsultaTurma({super.key});

  @override
  State<ConsultaTurma> createState() => _ConsultaTurmaState();
}

class _ConsultaTurmaState extends State<ConsultaTurma> {
  final _turmaService = TurmaService();
  bool _apenasAtivas = false;

  // Decide qual lista exibir com base no filtro marcado
  List<Turma> get _turmasExibidas {
    return _apenasAtivas
        ? _turmaService.obterListaTurmaAtivas()
        : listaTurma;
  }

  @override
  Widget build(BuildContext context) {
    final turmas = _turmasExibidas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta de Turmas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business),
            tooltip: 'Cadastrar Turma',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const CadastroTurma(title: 'Cadastro de Turma'),
                ),
              );
              setState(() {});
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Filtro: mostra só as turmas ativas
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: CheckboxListTile(
                value: _apenasAtivas,
                title: const Text('Mostrar apenas turmas ativas'),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (checked) {
                  setState(() {
                    _apenasAtivas = checked ?? false;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            // Lista de turmas (vazia = nenhuma turma bate com o filtro atual)
            Expanded(
              child: turmas.isEmpty
                  ? const Center(
                      child: Text('Nenhuma turma encontrada.'),
                    )
                  : ListView.separated(
                      itemCount: turmas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final turma = turmas[index];

                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              child: Text(turma.listaAlunos.length.toString()),
                            ),
                            title: Text(
                              turma.nomeTurma,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${turma.listaAlunos.length} aluno(s)'
                              '${turma.ativa ? '' : ' • Inativa'}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Editar Turma',
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CadastroTurma(
                                      title: 'Editar Turma',
                                      turma: turma,
                                    ),
                                  ),
                                );
                                setState(() {});
                              },
                            ),
                            children: turma.listaAlunos.isEmpty
                                ? [
                                    const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Text('Nenhum aluno vinculado.'),
                                    ),
                                  ]
                                : turma.listaAlunos.map((aluno) {
                                    return ListTile(
                                      dense: true,
                                      leading: CircleAvatar(
                                        radius: 14,
                                        child: Text(aluno.nome[0]),
                                      ),
                                      title: Text(aluno.nome),
                                      subtitle: Text(aluno.email),
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
    );
  }
}