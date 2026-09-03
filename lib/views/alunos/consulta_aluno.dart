import 'package:flutter/material.dart';
import 'package:gabarito_plus/mocks/mock_aluno.dart';
import 'package:gabarito_plus/views/alunos/cadastro_aluno.dart'; // ajuste o caminho

class ConsultaAluno extends StatefulWidget {
  const ConsultaAluno({super.key});

  @override
  State<ConsultaAluno> createState() => _ConsultaAlunoState();
}

class _ConsultaAlunoState extends State<ConsultaAluno> {
  @override
  Widget build(BuildContext context) {
    final alunos = listaAlunos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta de Alunos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Cadastrar Aluno',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const CadastroAluno(title: 'Cadastro de Aluno'),
                ),
              );
              setState(() {});
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: alunos.isEmpty
            ? const Center(
                child: Text('Nenhum aluno encontrado.'),
              )
            : ListView.separated(
                itemCount: alunos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final aluno = alunos[index];

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        radius: 18,
                        child: Text(aluno.nome[0]),
                      ),
                      title: Text(
                        aluno.nome,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        aluno.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Editar Aluno',
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CadastroAluno(
                                title: 'Editar Aluno',
                                aluno: aluno,
                              ),
                            ),
                          );
                          setState(() {});
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}