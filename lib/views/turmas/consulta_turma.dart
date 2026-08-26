import 'package:flutter/material.dart';
import 'package:gabarito_plus/mocks/mock_turma.dart';
import 'package:gabarito_plus/views/turmas/cadastro_turma.dart'; // ajuste o caminho

// TODO: paginação quando os dados vierem da API
// adicionar filtro por nome/período

class ConsultaTurma extends StatefulWidget {
  const ConsultaTurma({super.key});

  @override
  State<ConsultaTurma> createState() => _ConsultaTurmaState();
}

class _ConsultaTurmaState extends State<ConsultaTurma> {
  @override
  Widget build(BuildContext context) {
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
        child: ListView.separated(
          itemCount: listaTurma.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final turma = listaTurma[index];

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
                subtitle: Text('${turma.listaAlunos.length} aluno(s)'),
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
    );
  }
}