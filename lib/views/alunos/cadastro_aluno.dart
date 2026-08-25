import 'package:flutter/material.dart';
import 'package:gabarito_plus/mocks/mock_aluno.dart';
import 'package:gabarito_plus/models/aluno.dart';

class CadastroAluno extends StatefulWidget {
  const CadastroAluno({super.key, required this.title});

  final String title;

  @override
  State<CadastroAluno> createState() => _CadastroAlunoState();
}

class _CadastroAlunoState extends State<CadastroAluno> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _salvarAluno() {
    if (_formKey.currentState!.validate()) {
      // Cria a nova instância do aluno com um ID baseado no tamanho da lista
      final novoAluno = Aluno(
        id: (listaAlunos.length + 1).toString(),
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
      );

      // Adiciona na lista do mock
      setState(() {
        listaAlunos.add(novoAluno);
      });

      // Limpa os campos após salvar
      _nomeController.clear();
      _emailController.clear();

      // Exibe mensagem de confirmação
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aluno cadastrado com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Aluno',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome do aluno';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o e-mail';
                  }
                  if (!value.contains('@')) {
                    return 'Informe um e-mail válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _salvarAluno,
                icon: const Icon(Icons.save),
                label: const Text('Cadastrar Aluno'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}