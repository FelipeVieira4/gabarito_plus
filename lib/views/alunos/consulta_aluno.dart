import 'package:flutter/material.dart';

class ConsultaAluno extends StatelessWidget {
  const ConsultaAluno({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta de Alunos'),
      ),
      body: const Center(
        child: Text('Lista de Alunos (Mock)'),
      ),
    );
  }
}
