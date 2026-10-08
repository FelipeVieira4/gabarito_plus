import 'package:flutter/material.dart';
import 'package:gabarito_plus/features/aluno/data/aluno.dart';
import 'package:gabarito_plus/features/aluno/service/aluno_service.dart';

class CadastroAluno extends StatefulWidget {
  const CadastroAluno({super.key, required this.title, this.aluno});

  final String title;
  final Aluno? aluno;

  @override
  State<CadastroAluno> createState() => _CadastroAlunoState();
}

class _CadastroAlunoState extends State<CadastroAluno> {
  final _service = AlunoService();
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isAtivo = true;
  bool _salvando = false;
  Aluno? _alunoEncontrado;

  bool get _isEdicao => _alunoEncontrado != null;

  @override
  void initState() {
    super.initState();
    if (widget.aluno != null) {
      _idController.text = widget.aluno!.id;
      _preencher(widget.aluno);
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _preencher(Aluno? aluno) {
    setState(() {
      _alunoEncontrado = aluno;
      if (aluno != null) {
        _nomeController.text = aluno.nome;
        _emailController.text = aluno.email;
        _isAtivo = aluno.isAtivo;
      } else {
        _nomeController.clear();
        _emailController.clear();
        _isAtivo = true;
      }
    });
  }

  Future<void> _carregarAluno(String id) async {
    final aluno = await _service.buscarPorId(id.trim());
    if (!mounted) return;
    _preencher(aluno);
  }

  Future<void> _salvarAluno() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    final eraEdicao = _isEdicao;

    try {
      final idSalvo = await _service.salvar(
        id: _idController.text.trim(),
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        isAtivo: _isAtivo,
      );

      if (!mounted) return;
      setState(() {
        _idController.text = idSalvo;
      });
      await _carregarAluno(idSalvo);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            eraEdicao
                ? 'Aluno atualizado com sucesso!'
                : 'Aluno cadastrado com sucesso!',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
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
            onPressed: () async {
              final id = _alunoEncontrado!.id;
              Navigator.pop(ctx);
              try {
                await _service.excluir(id);
                if (!mounted) return;
                Navigator.pop(context);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao excluir: $e')),
                );
              }
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
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
                              : (_isEdicao
                                  ? 'Aluno encontrado'
                                  : 'ID não encontrado — será criado ao salvar'),
                          helperStyle: TextStyle(
                            color: _isEdicao ? Colors.green : Colors.grey[600],
                          ),
                        ),
                        onChanged: _carregarAluno,
                      ),
                      const SizedBox(height: 16),
                      isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _campoNome()),
                                const SizedBox(width: 16),
                                Expanded(child: _campoEmail()),
                              ],
                            )
                          : Column(
                              children: [
                                _campoNome(),
                                const SizedBox(height: 16),
                                _campoEmail(),
                              ],
                            ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Aluno Ativo'),
                        subtitle: Text(
                          _isAtivo
                              ? 'Disponível para atribuição em turmas e provas'
                              : 'Inativo (não aparecerá em novas turmas)',
                        ),
                        value: _isAtivo,
                        onChanged: (v) => setState(() => _isAtivo = v),
                        secondary: Icon(
                          _isAtivo ? Icons.check_circle : Icons.cancel,
                          color: _isAtivo ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _salvando ? null : _salvarAluno,
                        icon: _salvando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          _isEdicao ? 'Salvar Alterações' : 'Cadastrar Aluno',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _campoNome() {
    return TextFormField(
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
    );
  }

  Widget _campoEmail() {
    return TextFormField(
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
    );
  }
}