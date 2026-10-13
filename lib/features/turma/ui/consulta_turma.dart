import 'package:flutter/material.dart';
import 'package:gabarito_plus/features/turma/data/turma.dart';
import 'package:gabarito_plus/features/turma/service/turma_service.dart';
import 'package:gabarito_plus/features/turma/ui/cadastro_turma.dart';

class ConsultaTurma extends StatefulWidget {
  const ConsultaTurma({super.key});

  @override
  State<ConsultaTurma> createState() => _ConsultaTurmaState();
}

class _ConsultaTurmaState extends State<ConsultaTurma> {
  final _turmaService = TurmaService();
  bool _apenasAtivas = false;
  late Future<List<Turma>> _futureTurmas;

  @override
  void initState() {
    super.initState();
    _futureTurmas = _turmaService.listarTurmas();
  }

  void _recarregar() {
    setState(() {
      _futureTurmas = _turmaService.listarTurmas(apenasAtivas: _apenasAtivas);
    });
  }

  Future<void> _abrirCadastro({Turma? turma}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroTurma(
          title: turma == null ? 'Cadastro de Turma' : 'Editar Turma',
          turma: turma,
        ),
      ),
    );
    if (mounted) _recarregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consulta de Turmas')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
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
                  _apenasAtivas = checked ?? false;
                  _recarregar();
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Turma>>(
                future: _futureTurmas,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Erro ao carregar: ${snapshot.error}'),
                    );
                  }

                  final turmas = snapshot.data ?? [];
                  if (turmas.isEmpty) {
                    return const Center(
                        child: Text('Nenhuma turma encontrada.'));
                  }

                  return ListView.separated(
                    itemCount: turmas.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
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
                            style:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${turma.listaAlunos.length} aluno(s)'
                            '${turma.ativa ? '' : ' • Inativa'}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: 'Editar Turma',
                            onPressed: () => _abrirCadastro(turma: turma),
                          ),
                          children: turma.listaAlunos.isEmpty
                              ? const [
                                  Padding(
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirCadastro(),
        child: const Icon(Icons.add),
      ),
    );
  }
}