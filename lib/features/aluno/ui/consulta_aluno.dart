import 'package:flutter/material.dart';
import 'package:gabarito_plus/features/aluno/data/aluno.dart';
import 'package:gabarito_plus/features/aluno/service/aluno_service.dart';
import 'package:gabarito_plus/features/aluno/ui/cadastro_aluno.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Consulta de Alunos')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
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
            CheckboxListTile(
              value: _apenasAtivos,
              title: const Text('Apenas Ativos'),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (checked) {
                setState(() => _apenasAtivos = checked ?? false);
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<Aluno>>(
                stream: _alunoService.streamAlunosFiltrado(
                  nomeAluno: _buscaController.text,
                  apenasAtivos: _apenasAtivos,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Erro ao carregar: ${snapshot.error}'),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final alunos = snapshot.data ?? [];
                  if (alunos.isEmpty) {
                    return const Center(
                      child: Text('Nenhum aluno encontrado.'),
                    );
                  }

                  return ListView.separated(
                    itemCount: alunos.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) =>
                        _cardAluno(context, alunos[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const CadastroAluno(title: 'Cadastro de Alunos'),
            ),
          );
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _cardAluno(BuildContext context, Aluno aluno) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: aluno.isAtivo ? Colors.blue : Colors.grey,
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
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!aluno.isAtivo)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Inativo',
                  style: TextStyle(color: Colors.red, fontSize: 10),
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CadastroAluno(
                  title: 'Editar Aluno',
                  aluno: aluno,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}