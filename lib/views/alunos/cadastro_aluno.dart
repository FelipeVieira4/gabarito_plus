import 'package:flutter/material.dart';
import 'package:gabarito_plus/mocks/mock_aluno.dart';
import 'package:gabarito_plus/models/aluno.dart';

class CadastroAluno extends StatefulWidget {
  const CadastroAluno({super.key, required this.title, this.aluno});

  final String title;
  final Aluno? aluno; // continua aceitando vir preenchido da consulta

  @override
  State<CadastroAluno> createState() => _CadastroAlunoState();
}

class _CadastroAlunoState extends State<CadastroAluno> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();

  Aluno? _alunoEncontrado; // null = ID em branco ou não encontrado ainda

  bool get _isEdicao => _alunoEncontrado != null;

  @override
  void initState() {
    super.initState();
    if (widget.aluno != null) {
      _idController.text = widget.aluno!.id;
      _carregarAluno(widget.aluno!.id);
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Busca o aluno pelo ID digitado e preenche o formulário
  void _carregarAluno(String id) {
    final encontrado = listaAlunos.where((a) => a.id == id).toList();

    setState(() {
      if (encontrado.isNotEmpty) {
        _alunoEncontrado = encontrado.first;
        _nomeController.text = _alunoEncontrado!.nome;
        _emailController.text = _alunoEncontrado!.email;
      } else {
        _alunoEncontrado = null;
        _nomeController.clear();
        _emailController.clear();
      }
    });
  }

  void _salvarAluno() {
    if (!_formKey.currentState!.validate()) return;

    final idDigitado = _idController.text.trim();

    if (_isEdicao) {
      // Edição: atualiza o aluno encontrado
      final index = listaAlunos.indexWhere((a) => a.id == _alunoEncontrado!.id);
      if (index != -1) {
        setState(() {
          listaAlunos[index] = Aluno(
            id: _alunoEncontrado!.id,
            nome: _nomeController.text.trim(),
            email: _emailController.text.trim(),
          );
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aluno atualizado com sucesso!')),
      );
    } else {
      // Cadastro novo: se o ID foi digitado e não existe, usa ele; senão gera um novo
      final novoId = idDigitado.isNotEmpty
          ? idDigitado
          : (listaAlunos.length + 1).toString();

      final novoAluno = Aluno(
        id: novoId,
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
      );

      setState(() {
        listaAlunos.add(novoAluno);
        _alunoEncontrado = novoAluno; // agora "virou" edição, útil pra corrigir na hora
        _idController.text = novoAluno.id;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aluno cadastrado com sucesso!')),
      );
    }
  }

  void _excluirAluno() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir ${_alunoEncontrado!.nome}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                listaAlunos.removeWhere((a) => a.id == _alunoEncontrado!.id);
              });
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_isEdicao ? 'Editar Aluno' : widget.title),
        actions: [
          if (_isEdicao)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Excluir aluno',
              onPressed: _excluirAluno,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: 'ID do Aluno',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.badge),
                  helperText: _idController.text.trim().isEmpty
                      ? 'Deixe em branco para novo cadastro'
                      : (_isEdicao ? 'Aluno encontrado' : 'ID não encontrado — será criado ao salvar'),
                  helperStyle: TextStyle(
                    color: _isEdicao ? Colors.green : Colors.grey[600],
                  ),
                ),
                onChanged: _carregarAluno, // busca a cada digitação
              ),
              const SizedBox(height: 16),
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
                label: Text(_isEdicao ? 'Salvar Alterações' : 'Cadastrar Aluno'),
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