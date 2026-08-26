import 'package:flutter/material.dart';
import 'package:gabarito_plus/mocks/mock_aluno.dart';
import 'package:gabarito_plus/views/alunos/cadastro_aluno.dart'; // Ajuste o caminho da sua tela de cadastro

// TODO: páginação quando dados vier pela API
// rodapé com opções de exportação de dados(colocar em um uilitario)
// adicionar opções de filtros como semestro, ativos etc...

class ConsultaAluno extends StatefulWidget {
  const ConsultaAluno({super.key});

  @override
  State<ConsultaAluno> createState() => _ConsultaAlunoState();
}

class _ConsultaAlunoState extends State<ConsultaAluno> {
  @override
  Widget build(BuildContext context) {
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
                  builder: (context) => const CadastroAluno(title: 'Cadastro de Aluno'),
                ),
              );
              setState(() {});
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: listaAlunos.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 4.5,
          ),
          itemBuilder: (context, index) {
            final aluno = listaAlunos[index]; // <-- aluno é criado aqui

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      child: Text(aluno.nome[0]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            aluno.nome,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            aluno.email,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
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
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}