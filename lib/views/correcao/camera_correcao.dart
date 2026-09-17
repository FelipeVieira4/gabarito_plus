import 'package:flutter/material.dart';
import 'package:gabarito_plus/mocks/mock_leitura.dart';
import 'package:gabarito_plus/models/correcao.dart';
import 'package:gabarito_plus/models/gabarito_lido.dart';
import 'package:gabarito_plus/services/correcao_repository.dart';
import 'package:gabarito_plus/services/correcao_service.dart';

const bool kModoSimulado = true;

enum _Etapa { lendoQr, lendoFolha, conferindo, resultado }

class CameraCorrecao extends StatefulWidget {
  const CameraCorrecao({super.key});

  @override
  State<CameraCorrecao> createState() => _CameraCorrecaoState();
}

class _CameraCorrecaoState extends State<CameraCorrecao> {
  final _service = CorrecaoService();
  final _repository = CorrecaoRepository.instancia;

  _Etapa _etapa = _Etapa.lendoQr;
  GabaritoLido? _gabarito;
  Correcao? _correcao;
  int _corrigidasNaSessao = 0;


  void _lerQrSimulado() {
    _aplicarGabarito(proximoGabaritoSimulado());
  }

  Future<void> _digitarCodigoManualmente() async {
    final codigo = await showDialog<String>(
      context: context,
      builder: (_) => const _DialogoCodigoManual(),
    );

    if (codigo == null || !mounted) return;

    final gabarito = gabaritoMockPorCodigo(codigo);
    if (gabarito == null) {
      _avisar('Nenhuma prova encontrada com o código "$codigo"');
      return;
    }

    _aplicarGabarito(gabarito);
  }

  void _aplicarGabarito(GabaritoLido gabarito) {
    setState(() {
      _gabarito = gabarito;
      _correcao = null;
      _etapa = _Etapa.lendoFolha;
    });
  }


  void _lerFolhaSimulada() {
    final gabarito = _gabarito!;
    final folha = folhaMockPorCodigo(gabarito.codigoVersao);

    if (folha == null) {
      _avisar('Não foi possível ler a folha desta prova');
      return;
    }

    _corrigir(gabarito, folha);
  }

  void _lerFolhaTrocadaSimulada() {
    final gabarito = _gabarito!;
    final outra = folhasLidasMock.firstWhere(
      (folha) => folha.codigoVersao != gabarito.codigoVersao,
    );

    _corrigir(gabarito, outra);
  }

  void _corrigir(GabaritoLido gabarito, FolhaLida folha) {
    try {
      final correcao = _service.corrigir(gabarito: gabarito, folha: folha);
      setState(() {
        _correcao = correcao;
        _etapa = _Etapa.conferindo;
      });
    } on ArgumentError catch (erro) {
      _avisar(
        erro.message?.toString() ?? 'Não foi possível corrigir esta prova',
      );
    }
  }


  void _alterarResposta(int numeroQuestao, int? novoIndice) {
    setState(() {
      _correcao = _correcao!.comRespostaAlterada(numeroQuestao, novoIndice);
    });
  }

  void _confirmarConferencia() {
    setState(() => _etapa = _Etapa.resultado);
  }


  void _salvarESeguir() {
    final correcao = _correcao!;
    _repository.salvar(correcao);

    setState(() {
      _corrigidasNaSessao++;
      _gabarito = null;
      _correcao = null;
      _etapa = _Etapa.lendoQr;
    });

    _avisar('Prova de ${correcao.nomeAluno} salva · nota ${_nota(correcao)}');
  }


  void _voltarEtapa() {
    if (_etapa == _Etapa.lendoQr) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      switch (_etapa) {
        case _Etapa.lendoFolha:
          _gabarito = null;
          _etapa = _Etapa.lendoQr;
        case _Etapa.conferindo:
          _correcao = null;
          _etapa = _Etapa.lendoFolha;
        case _Etapa.resultado:
          _etapa = _Etapa.conferindo;
        case _Etapa.lendoQr:
          break;
      }
    });
  }

  void _avisar(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  String _nota(Correcao correcao) =>
      correcao.nota.toStringAsFixed(1).replaceAll('.', ',');

  String get _tituloAppBar {
    switch (_etapa) {
      case _Etapa.lendoQr:
        return 'Ler gabarito';
      case _Etapa.lendoFolha:
        return 'Ler folha de respostas';
      case _Etapa.conferindo:
        return 'Conferir marcações';
      case _Etapa.resultado:
        return 'Resultado';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _etapa == _Etapa.lendoQr,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _voltarEtapa();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_tituloAppBar),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _voltarEtapa,
          ),
          actions: [
            if (_corrigidasNaSessao > 0)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    '$_corrigidasNaSessao corrigidas',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ),
          ],
        ),
        body: SafeArea(child: _buildEtapa()),
      ),
    );
  }

  Widget _buildEtapa() {
    switch (_etapa) {
      case _Etapa.lendoQr:
        return _buildLeituraQr();
      case _Etapa.lendoFolha:
        return _buildLeituraFolha();
      case _Etapa.conferindo:
        return _buildConferencia();
      case _Etapa.resultado:
        return _buildResultado();
    }
  }


  Widget _buildLeituraQr() {
    return Column(
      children: [
        const Expanded(
          child: _AreaCamera(
            icone: Icons.qr_code_scanner,
            instrucao: 'Aponte para o QR Code do gabarito',
            proporcaoMoldura: 1,
          ),
        ),
        _PainelAcoes(
          children: [
            if (kModoSimulado)
              FilledButton.icon(
                onPressed: _lerQrSimulado,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Simular leitura do QR'),
              ),
            TextButton.icon(
              onPressed: _digitarCodigoManualmente,
              icon: const Icon(Icons.keyboard),
              label: const Text('Digitar código da prova'),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildLeituraFolha() {
    final gabarito = _gabarito!;
    final jaCorrigida = _repository.jaCorrigida(gabarito.codigoVersao);

    return Column(
      children: [
        _FaixaIdentificacao(gabarito: gabarito),
        if (jaCorrigida)
          const _Aviso(
            texto: 'Esta prova já foi corrigida antes. Salvar de novo '
                'substitui o resultado anterior.',
          ),
        Expanded(
          child: _AreaCamera(
            icone: Icons.document_scanner,
            instrucao: 'Enquadre a folha de respostas de '
                '${gabarito.nomeAluno.split(' ').first}',
            proporcaoMoldura: 3 / 4,
          ),
        ),
        _PainelAcoes(
          children: [
            if (kModoSimulado) ...[
              FilledButton.icon(
                onPressed: _lerFolhaSimulada,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Simular leitura da folha'),
              ),
              TextButton(
                onPressed: _lerFolhaTrocadaSimulada,
                child: const Text('Simular folha trocada'),
              ),
            ],
          ],
        ),
      ],
    );
  }


  Widget _buildConferencia() {
    final correcao = _correcao!;

    return Column(
      children: [
        const _Aviso(
          texto: 'Confira o que foi lido da folha. Toque em uma alternativa '
              'para corrigir; toque na marcada para deixar em branco.',
          icone: Icons.edit_note,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              _CabecalhoAluno(correcao: correcao),
              const SizedBox(height: 16),
              _GradeRespostas(
                correcao: correcao,
                editavel: true,
                mostrarGabarito: false,
                onAlterar: _alterarResposta,
              ),
            ],
          ),
        ),
        _PainelAcoes(
          children: [
            FilledButton.icon(
              onPressed: _confirmarConferencia,
              icon: const Icon(Icons.check),
              label: const Text('Confirmar e ver nota'),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildResultado() {
    final correcao = _correcao!;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: [
              _CartaoNota(correcao: correcao, notaFormatada: _nota(correcao)),
              const SizedBox(height: 20),
              Text(
                'Respostas',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _GradeRespostas(
                correcao: correcao,
                editavel: false,
                mostrarGabarito: true,
                onAlterar: _alterarResposta,
              ),
            ],
          ),
        ),
        _PainelAcoes(
          children: [
            FilledButton.icon(
              onPressed: _salvarESeguir,
              icon: const Icon(Icons.save),
              label: const Text('Salvar e corrigir a próxima'),
            ),
            TextButton(
              onPressed: () => setState(() => _etapa = _Etapa.conferindo),
              child: const Text('Ajustar marcações'),
            ),
          ],
        ),
      ],
    );
  }
}


/// Espaço reservado para o preview da câmera.
///
/// Hoje desenha só a moldura de enquadramento. O preview real do
/// `mobile_scanner` (QR) e da foto da folha entram aqui, sem mexer no resto da
/// tela.
class _AreaCamera extends StatelessWidget {
  const _AreaCamera({
    required this.icone,
    required this.instrucao,
    required this.proporcaoMoldura,
  });

  final IconData icone;
  final String instrucao;
  final double proporcaoMoldura;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black87,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: AspectRatio(
              aspectRatio: proporcaoMoldura,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white70, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(icone, size: 56, color: Colors.white30),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            instrucao,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
          if (kModoSimulado) ...[
            const SizedBox(height: 8),
            const Text(
              'Câmera ainda não conectada',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _PainelAcoes extends StatelessWidget {
  const _PainelAcoes({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _FaixaIdentificacao extends StatelessWidget {
  const _FaixaIdentificacao({required this.gabarito});

  final GabaritoLido gabarito;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      color: cores.primaryContainer,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            gabarito.nomeAluno,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 2),
          Text(
            '${gabarito.tituloProva} · ${gabarito.totalQuestoes} questões',
            style: TextStyle(fontSize: 13, color: cores.onPrimaryContainer),
          ),
          Text(
            gabarito.codigoVersao,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso({required this.texto, this.icone = Icons.info_outline});

  final String texto;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.amber.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 18, color: Colors.amber.shade900),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
            ),
          ),
        ],
      ),
    );
  }
}

class _CabecalhoAluno extends StatelessWidget {
  const _CabecalhoAluno({required this.correcao});

  final Correcao correcao;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(child: Text(correcao.nomeAluno[0])),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                correcao.nomeAluno,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                correcao.codigoVersao,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CartaoNota extends StatelessWidget {
  const _CartaoNota({required this.correcao, required this.notaFormatada});

  final Correcao correcao;
  final String notaFormatada;

  @override
  Widget build(BuildContext context) {
    final aprovado = correcao.nota >= 6;
    final cor = aprovado ? Colors.green.shade700 : Colors.red.shade700;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              correcao.nomeAluno,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              notaFormatada,
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.bold,
                color: cor,
                height: 1,
              ),
            ),
            Text(
              '${correcao.acertos} de ${correcao.totalQuestoes} questões',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _Contador(
                  rotulo: 'acertos',
                  valor: correcao.acertos,
                  cor: Colors.green.shade700,
                ),
                _Contador(
                  rotulo: 'erros',
                  valor: correcao.erros,
                  cor: Colors.red.shade700,
                ),
                _Contador(
                  rotulo: 'em branco',
                  valor: correcao.emBranco,
                  cor: Colors.grey.shade600,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Contador extends StatelessWidget {
  const _Contador({
    required this.rotulo,
    required this.valor,
    required this.cor,
  });

  final String rotulo;
  final int valor;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$valor $rotulo',
        style: TextStyle(color: cor, fontWeight: FontWeight.w500, fontSize: 13),
      ),
    );
  }
}

class _GradeRespostas extends StatelessWidget {
  const _GradeRespostas({
    required this.correcao,
    required this.editavel,
    required this.mostrarGabarito,
    required this.onAlterar,
  });

  final Correcao correcao;
  final bool editavel;

  final bool mostrarGabarito;

  final void Function(int numeroQuestao, int? novoIndice) onAlterar;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Column(
        children: correcao.respostas.map((resposta) {
          final ultima = resposta.numeroQuestao == correcao.totalQuestoes;

          return Column(
            children: [
              _LinhaResposta(
                resposta: resposta,
                quantidadeAlternativas: correcao.quantidadeAlternativas,
                editavel: editavel,
                mostrarGabarito: mostrarGabarito,
                onAlterar: onAlterar,
              ),
              if (!ultima) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _LinhaResposta extends StatelessWidget {
  const _LinhaResposta({
    required this.resposta,
    required this.quantidadeAlternativas,
    required this.editavel,
    required this.mostrarGabarito,
    required this.onAlterar,
  });

  final RespostaMarcada resposta;
  final int quantidadeAlternativas;
  final bool editavel;
  final bool mostrarGabarito;
  final void Function(int numeroQuestao, int? novoIndice) onAlterar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              '${resposta.numeroQuestao}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          ...List.generate(quantidadeAlternativas, (indice) {
            return Expanded(
              child: _Bolha(
                key: ValueKey('q${resposta.numeroQuestao}-alt$indice'),
                indice: indice,
                marcada: resposta.indiceMarcado == indice,
                correta: mostrarGabarito && resposta.indiceCorreto == indice,
                mostrarGabarito: mostrarGabarito,
                editavel: editavel,
                onTap: () => onAlterar(
                  resposta.numeroQuestao,
                  // Tocar na alternativa já marcada deixa a questão em branco.
                  resposta.indiceMarcado == indice ? null : indice,
                ),
              ),
            );
          }),
          SizedBox(width: 36, child: _buildSituacao()),
        ],
      ),
    );
  }

  Widget _buildSituacao() {
    if (!mostrarGabarito) {
      return resposta.emBranco
          ? Center(
              child: Text(
                '—',
                style: TextStyle(color: Colors.grey[500], fontSize: 16),
              ),
            )
          : const SizedBox.shrink();
    }

    if (resposta.acertou) {
      return Icon(Icons.check_circle, color: Colors.green.shade700, size: 20);
    }
    if (resposta.emBranco) {
      return Icon(Icons.remove_circle_outline,
          color: Colors.grey.shade500, size: 20);
    }
    return Icon(Icons.cancel, color: Colors.red.shade700, size: 20);
  }
}

/// Uma alternativa da folha de respostas.
class _Bolha extends StatelessWidget {
  const _Bolha({
    super.key,
    required this.indice,
    required this.marcada,
    required this.correta,
    required this.mostrarGabarito,
    required this.editavel,
    required this.onTap,
  });

  final int indice;
  final bool marcada;
  final bool correta;
  final bool mostrarGabarito;
  final bool editavel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primaria = Theme.of(context).colorScheme.primary;

    var fundo = Colors.transparent;
    var borda = Colors.grey.shade400;
    var texto = Colors.grey.shade700;

    if (marcada && correta) {
      fundo = Colors.green.shade600;
      borda = Colors.green.shade600;
      texto = Colors.white;
    } else if (marcada && mostrarGabarito) {
      fundo = Colors.red.shade600;
      borda = Colors.red.shade600;
      texto = Colors.white;
    } else if (marcada) {
      fundo = primaria;
      borda = primaria;
      texto = Colors.white;
    } else if (correta) {
      borda = Colors.green.shade600;
      texto = Colors.green.shade700;
    }

    return Semantics(
      button: editavel,
      selected: marcada,
      label: 'Alternativa ${letraAlternativa(indice)}',
      child: InkWell(
        onTap: editavel ? onTap : null,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Center(
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: fundo,
                shape: BoxShape.circle,
                border: Border.all(
                  color: borda,
                  width: correta && !marcada ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  letraAlternativa(indice),
                  style: TextStyle(
                    color: texto,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _DialogoCodigoManual extends StatefulWidget {
  const _DialogoCodigoManual();

  @override
  State<_DialogoCodigoManual> createState() => _DialogoCodigoManualState();
}

class _DialogoCodigoManualState extends State<_DialogoCodigoManual> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirmar() {
    final codigo = _controller.text.trim();
    if (codigo.isEmpty) return;
    Navigator.pop(context, codigo);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Código da prova'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              hintText: 'ES2025A-001',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _confirmar(),
          ),
          const SizedBox(height: 8),
          Text(
            'O código vem impresso logo abaixo do QR Code.',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _confirmar, child: const Text('Buscar')),
      ],
    );
  }
}
