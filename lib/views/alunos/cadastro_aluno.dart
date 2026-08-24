import 'package:flutter/material.dart';

class CadastroAluno extends StatefulWidget {
  const CadastroAluno({super.key, required this.title});

  final String title;

  @override
  State<CadastroAluno> createState() => _CadastroAlunoState();
}

class _CadastroAlunoState extends State<CadastroAluno> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('Tela de Cadastro de Aluno (Mock)')],
        ),
      ),
    );
  }
}
