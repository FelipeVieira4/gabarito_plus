import 'package:flutter/material.dart';
import 'package:gabarito_plus/services/aluno_service.dart';

import 'package:gabarito_plus/views/alunos/cadastro_aluno.dart';

class ConsultaAluno extends StatefulWidget {
  const ConsultaAluno({super.key});

  @override
  State<ConsultaAluno> createState() => _ConsultaAlunoState();
}

class _ConsultaAlunoState extends State<ConsultaAluno> {
  final _alunoService = AlunoService();
  final _buscaController = TextEditingController();

  bool _apenasAtivos = true;

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alunos = _alunoService.obterListaAlunosFiltrado(
      nomeAluno: _buscaController.text,
      apenasAtivos: _apenasAtivos,
    );

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
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Campo de busca e Chip de filtro
            TextField(
              controller: _buscaController,
              decoration: InputDecoration(
                labelText: 'Buscar por nome',
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
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                FilterChip(
                  label: const Text('Apenas Ativos'),
                  selected: _apenasAtivos,
                  onSelected: (bool selected) {
                    setState(() {
                      _apenasAtivos = selected;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Lista de Alunos
            Expanded(
              child: alunos.isEmpty
                  ? const Center(
                      child: Text('Nenhum aluno encontrado.'),
                    )
                  : ListView.separated(
                      itemCount: alunos.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
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
                              backgroundColor:
                                  aluno.isAtivo ? Colors.blue : Colors.grey,
                              child: Text(
                                aluno.nome.isNotEmpty ? aluno.nome[0] : '?',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    aluno.nome,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (!aluno.isAtivo)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red[100],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Inativo',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                              ],
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
          ],
        ),
      ),
    );
  }
}