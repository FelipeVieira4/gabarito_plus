import 'package:flutter/material.dart';
import 'package:gabarito_plus/features/correcao_prova/services/correcao_repository.dart';
import 'package:gabarito_plus/features/correcao_prova/services/correcao_service.dart';
import 'package:gabarito_plus/features/correcao_prova/views/correcao/camera_correcao.dart';
import 'package:gabarito_plus/features/geracao_prova/data/correcao.dart';
import 'package:gabarito_plus/features/geracao_prova/data/estatistica_prova.dart';

enum OrdenacaoCorrecao {
  maiorNota('Maior nota'),
  menorNota('Menor nota'),
  nomeAluno('Aluno (A–Z)'),
  maisRecentes('Mais recentes');

  const OrdenacaoCorrecao(this.rotulo);
  final String rotulo;
}

class ConsultaProvasCorrigidasView extends StatefulWidget {
  const ConsultaProvasCorrigidasView({
    super.key,
    this.onSelecionarCorrecao,
    this.notaCorte = 6.0,
  });

  final void Function(Correcao correcao)? onSelecionarCorrecao;
  final double notaCorte;

  @override
  State<ConsultaProvasCorrigidasView> createState() =>
      _ConsultaProvasCorrigidasViewState();
}

class _ConsultaProvasCorrigidasViewState
    extends State<ConsultaProvasCorrigidasView> {
  final _repository = CorrecaoRepository.instancia;
  final _service = CorrecaoService();
  final _buscaController = TextEditingController();

  String? _turmaFiltro;
  String? _provaFiltro;
  OrdenacaoCorrecao _ordenacao = OrdenacaoCorrecao.maiorNota;

  List<Correcao> _correcoes = [];
  bool _carregando = true;
  bool _erroAoCarregar = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erroAoCarregar = false;
    });

    try {
      final correcoes = await _repository.obterTodas();
      if (!mounted) return;
      setState(() {
        _correcoes = correcoes;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
        _erroAoCarregar = true;
      });
    }
  }

  List<String> _obterTurmasDisponiveis(List<Correcao> todas) {
    final turmas = todas.map((c) => c.nomeTurma).toSet().toList()..sort();
    return turmas;
  }

  List<String> _obterProvasDisponiveis(
    List<Correcao> todas, {
    String? turmaSelecionada,
  }) {
    final base = turmaSelecionada == null
        ? todas
        : todas.where((c) => c.nomeTurma == turmaSelecionada);
    final provas = base.map((c) => c.tituloProva).toSet().toList()..sort();
    return provas;
  }

  List<Correcao> _filtrarEOrdenar(
    List<Correcao> todas, {
    required String? turmaAtiva,
    required String? provaAtiva,
  }) {
    final termo = _buscaController.text.trim().toLowerCase();

    final filtradas = todas.where((correcao) {
      if (turmaAtiva != null && correcao.nomeTurma != turmaAtiva) {
        return false;
      }
      if (provaAtiva != null && correcao.tituloProva != provaAtiva) {
        return false;
      }
      if (termo.isNotEmpty) {
        final bateNome = correcao.nomeAluno.toLowerCase().contains(termo);
        final bateCodigo = correcao.codigoVersao.toLowerCase().contains(termo);
        final bateProva = correcao.tituloProva.toLowerCase().contains(termo);
        return bateNome || bateCodigo || bateProva;
      }
      return true;
    }).toList();

    switch (_ordenacao) {
      case OrdenacaoCorrecao.maiorNota:
        return _service.ordenadasPorNota(filtradas);
      case OrdenacaoCorrecao.menorNota:
        filtradas.sort((a, b) {
          final comp = a.nota.compareTo(b.nota);
          return comp != 0 ? comp : a.nomeAluno.compareTo(b.nomeAluno);
        });
        return filtradas;
      case OrdenacaoCorrecao.nomeAluno:
        filtradas.sort((a, b) => a.nomeAluno.compareTo(b.nomeAluno));
        return filtradas;
      case OrdenacaoCorrecao.maisRecentes:
        filtradas.sort((a, b) => b.dataHora.compareTo(a.dataHora));
        return filtradas;
    }
  }

  void _limparFiltros() {
    _buscaController.clear();
    setState(() {
      _turmaFiltro = null;
      _provaFiltro = null;
      _ordenacao = OrdenacaoCorrecao.maiorNota;
    });
  }

  Future<void> _abrirCameraCorrecao() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraCorrecao()),
    );
    if (!mounted) return;
    await _carregar();
  }

  Future<void> _confirmarExclusao(Correcao correcao) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover correção'),
        content: Text(
          'Deseja remover a correção de ${correcao.nomeAluno} '
          '(${correcao.codigoVersao})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      await _repository.remover(correcao.codigoVersao);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Não foi possível remover a correção. '
                'Verifique a conexão e tente de novo.'),
          ),
        );
      return;
    }

    if (!mounted) return;
    setState(() {
      _correcoes = _correcoes
          .where((item) => item.codigoVersao != correcao.codigoVersao)
          .toList();
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Correção de ${correcao.nomeAluno} removida.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final todas = _correcoes;
    final turmas = _obterTurmasDisponiveis(todas);
    final turmaAtiva = turmas.contains(_turmaFiltro) ? _turmaFiltro : null;

    final provas = _obterProvasDisponiveis(todas, turmaSelecionada: turmaAtiva);
    final provaAtiva = provas.contains(_provaFiltro) ? _provaFiltro : null;

    final correcoesFiltradas = _filtrarEOrdenar(
      todas,
      turmaAtiva: turmaAtiva,
      provaAtiva: provaAtiva,
    );

    final resumo = _service.resumoDaTurma(
      correcoesFiltradas,
      notaCorte: widget.notaCorte,
    );

    final possuiFiltroAtivo = _buscaController.text.trim().isNotEmpty ||
        turmaAtiva != null ||
        provaAtiva != null ||
        _ordenacao != OrdenacaoCorrecao.maiorNota;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Provas Corrigidas'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _buscaController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Buscar por aluno, código ou prova...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _buscaController.text.isNotEmpty
                        ? IconButton(
                            tooltip: 'Limpar busca',
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _buscaController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 650;
                    final dropdownTurma = DropdownButtonFormField<String?>(
                      key: ValueKey('turma-$turmaAtiva'),
                      initialValue: turmaAtiva,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Turma',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Todas as turmas'),
                        ),
                        ...turmas.map(
                          (turma) => DropdownMenuItem<String?>(
                            value: turma,
                            child: Text(
                              turma,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (valor) {
                        setState(() {
                          _turmaFiltro = valor;
                          _provaFiltro = null;
                        });
                      },
                    );

                    final dropdownProva = DropdownButtonFormField<String?>(
                      key: ValueKey('prova-$turmaAtiva-$provaAtiva'),
                      initialValue: provaAtiva,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Prova',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Todas as provas'),
                        ),
                        ...provas.map(
                          (prova) => DropdownMenuItem<String?>(
                            value: prova,
                            child: Text(
                              prova,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (valor) {
                        setState(() => _provaFiltro = valor);
                      },
                    );

                    final dropdownOrdenacao =
                        DropdownButtonFormField<OrdenacaoCorrecao>(
                      key: ValueKey('ord-${_ordenacao.name}'),
                      initialValue: _ordenacao,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Ordenar por',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: OrdenacaoCorrecao.values
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item.rotulo),
                            ),
                          )
                          .toList(),
                      onChanged: (valor) {
                        if (valor == null) return;
                        setState(() => _ordenacao = valor);
                      },
                    );

                    final botaoLimpar = possuiFiltroAtivo
                        ? IconButton(
                            tooltip: 'Limpar filtros',
                            icon: const Icon(Icons.filter_alt_off),
                            onPressed: _limparFiltros,
                          )
                        : null;

                    if (isWide) {
                      return Row(
                        children: [
                          Expanded(flex: 3, child: dropdownTurma),
                          const SizedBox(width: 12),
                          Expanded(flex: 3, child: dropdownProva),
                          const SizedBox(width: 12),
                          Expanded(flex: 2, child: dropdownOrdenacao),
                          if (botaoLimpar != null) ...[
                            const SizedBox(width: 4),
                            botaoLimpar,
                          ],
                        ],
                      );
                    }

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: dropdownTurma),
                            const SizedBox(width: 8),
                            Expanded(child: dropdownProva),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: dropdownOrdenacao),
                            if (botaoLimpar != null) ...[
                              const SizedBox(width: 4),
                              botaoLimpar,
                            ],
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              if (!_carregando && correcoesFiltradas.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: _PainelResumoTurma(resumo: resumo),
                ),
              Expanded(
                child: _carregando
                    ? const Center(child: CircularProgressIndicator())
                    : _erroAoCarregar
                    ? _ErroAoCarregar(onTentarNovamente: _carregar)
                    : correcoesFiltradas.isEmpty
                    ? _EstadoVazio(
                        possuiFiltroAtivo: possuiFiltroAtivo,
                        onLimparFiltros: _limparFiltros,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                        itemCount: correcoesFiltradas.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final correcao = correcoesFiltradas[index];
                          return _CardCorrecao(
                            correcao: correcao,
                            notaCorte: widget.notaCorte,
                            onTap: widget.onSelecionarCorrecao != null
                                ? () => widget.onSelecionarCorrecao!(correcao)
                                : null,
                            onRemover: () => _confirmarExclusao(correcao),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCameraCorrecao,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Corrigir prova'),
      ),
    );
  }
}

class _PainelResumoTurma extends StatelessWidget {
  const _PainelResumoTurma({required this.resumo});

  final ResumoTurma resumo;

  String _formatarNota(double valor) =>
      valor.toStringAsFixed(1).replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final percentualAprovados = resumo.percentualAprovacao.round();

    return Card(
      elevation: 0,
      color: cores.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itens = [
              _ItemResumo(
                rotulo: 'Corrigidas',
                valor: '${resumo.totalCorrigidas}',
                icone: Icons.assignment_turned_in_outlined,
                cor: cores.primary,
              ),
              _ItemResumo(
                rotulo: 'Média',
                valor: _formatarNota(resumo.media),
                icone: Icons.analytics_outlined,
                cor: resumo.media >= resumo.notaCorte
                    ? Colors.green.shade700
                    : Colors.orange.shade800,
              ),
              _ItemResumo(
                rotulo: 'Maior / Menor',
                valor:
                    '${_formatarNota(resumo.maiorNota)} / ${_formatarNota(resumo.menorNota)}',
                icone: Icons.swap_vert,
                cor: Colors.blueGrey.shade700,
              ),
              _ItemResumo(
                rotulo: 'Aprovados',
                valor:
                    '${resumo.aprovados}/${resumo.totalCorrigidas} ($percentualAprovados%)',
                icone: Icons.verified_outlined,
                cor: Colors.green.shade700,
              ),
            ];

            if (constraints.maxWidth >= 560) {
              return Row(
                children: itens
                    .map((item) => Expanded(child: item))
                    .toList(growable: false),
              );
            }

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: itens
                  .map(
                    (item) => SizedBox(
                      width: (constraints.maxWidth - 12) / 2,
                      child: item,
                    ),
                  )
                  .toList(growable: false),
            );
          },
        ),
      ),
    );
  }
}

class _ItemResumo extends StatelessWidget {
  const _ItemResumo({
    required this.rotulo,
    required this.valor,
    required this.icone,
    required this.cor,
  });

  final String rotulo;
  final String valor;
  final IconData icone;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: cor.withValues(alpha: 0.12),
          child: Icon(icone, size: 18, color: cor),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rotulo,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                valor,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CardCorrecao extends StatelessWidget {
  const _CardCorrecao({
    required this.correcao,
    required this.notaCorte,
    required this.onRemover,
    this.onTap,
  });

  final Correcao correcao;
  final double notaCorte;
  final VoidCallback onRemover;
  final VoidCallback? onTap;

  String _formatarNota(double valor) =>
      valor.toStringAsFixed(1).replaceAll('.', ',');

  String _formatarDataHora(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year;
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$ano às $hora:$minuto';
  }

  @override
  Widget build(BuildContext context) {
    final aprovado = correcao.nota >= notaCorte;
    final corNota = aprovado ? Colors.green.shade700 : Colors.red.shade700;

    return Card(
      key: ValueKey('card-correcao-${correcao.codigoVersao}'),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                decoration: BoxDecoration(
                  color: corNota.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: corNota.withValues(alpha: 0.3)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatarNota(correcao.nota),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: corNota,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'nota',
                      style: TextStyle(
                        fontSize: 11,
                        color: corNota,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            correcao.nomeAluno,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: corNota.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            aprovado ? 'Aprovado' : 'Abaixo da média',
                            style: TextStyle(
                              color: corNota,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${correcao.tituloProva} • ${correcao.nomeTurma}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            correcao.codigoVersao,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        _BadgeContagem(
                          texto: '${correcao.acertos} acertos',
                          cor: Colors.green.shade700,
                        ),
                        _BadgeContagem(
                          texto: '${correcao.erros} erros',
                          cor: Colors.red.shade700,
                        ),
                        if (correcao.emBranco > 0)
                          _BadgeContagem(
                            texto: '${correcao.emBranco} em branco',
                            cor: Colors.grey.shade700,
                          ),
                        Text(
                          _formatarDataHora(correcao.dataHora),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Remover correção',
                icon: const Icon(Icons.delete_outline),
                color: Colors.grey.shade600,
                onPressed: onRemover,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeContagem extends StatelessWidget {
  const _BadgeContagem({required this.texto, required this.cor});

  final String texto;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: cor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio({
    required this.possuiFiltroAtivo,
    required this.onLimparFiltros,
  });

  final bool possuiFiltroAtivo;
  final VoidCallback onLimparFiltros;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_late_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              possuiFiltroAtivo
                  ? 'Nenhuma prova corrigida encontrada para os filtros aplicados.'
                  : 'Nenhuma prova corrigida registrada até o momento.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
            ),
            if (possuiFiltroAtivo) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onLimparFiltros,
                icon: const Icon(Icons.filter_alt_off),
                label: const Text('Limpar filtros'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErroAoCarregar extends StatelessWidget {
  const _ErroAoCarregar({required this.onTentarNovamente});

  final VoidCallback onTentarNovamente;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'Não foi possível carregar as provas corrigidas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onTentarNovamente,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
