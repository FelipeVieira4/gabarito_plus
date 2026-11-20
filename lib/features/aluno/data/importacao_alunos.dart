import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

class AlunoImportado {
  final int linha;
  final String nome;
  final String email;
  final bool isAtivo;

  const AlunoImportado({
    required this.linha,
    required this.nome,
    required this.email,
    required this.isAtivo,
  });
}

class ErroImportacao {
  final int linha;
  final String motivo;

  const ErroImportacao(this.linha, this.motivo);

  @override
  String toString() => 'Linha $linha: $motivo';
}

class ResultadoImportacao {
  final List<AlunoImportado> validos;
  final List<ErroImportacao> erros;

  const ResultadoImportacao({required this.validos, required this.erros});
}

class ArquivoInvalidoException implements Exception {
  final String mensagem;
  const ArquivoInvalidoException(this.mensagem);

  @override
  String toString() => mensagem;
}

class ImportacaoAlunosParser {
  static const extensoesSuportadas = ['csv', 'xlsx'];

  static final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static ResultadoImportacao parse(Uint8List bytes, String extensao) {
    final linhas = lerLinhas(bytes, extensao);
    return converterLinhas(linhas);
  }

  static List<List<String>> lerLinhas(Uint8List bytes, String extensao) {
    switch (extensao.toLowerCase().replaceFirst('.', '')) {
      case 'csv':
        return _lerCsv(bytes);
      case 'xlsx':
        return _lerXlsx(bytes);
      default:
        throw ArquivoInvalidoException(
          'Formato ".$extensao" não suportado. Use CSV ou XLSX.',
        );
    }
  }

  static List<List<String>> _lerCsv(Uint8List bytes) {
    String texto;
    try {
      texto = utf8.decode(bytes);
    } on FormatException {
      texto = latin1.decode(bytes);
    }
    if (texto.startsWith('﻿')) texto = texto.substring(1);
    if (texto.trim().isEmpty) return [];

    final primeiraLinha = texto.split(RegExp(r'\r?\n')).first;
    final separador =
        ';'.allMatches(primeiraLinha).length >
            ','.allMatches(primeiraLinha).length
        ? ';'
        : ',';

    final dados = CsvDecoder(
      fieldDelimiter: separador,
      skipEmptyLines: false,
    ).convert(texto);
    return dados
        .map((linha) => linha.map((c) => c?.toString() ?? '').toList())
        .toList();
  }

  static List<List<String>> _lerXlsx(Uint8List bytes) {
    final Excel excel;
    try {
      excel = Excel.decodeBytes(bytes);
    } catch (_) {
      throw const ArquivoInvalidoException(
        'Não foi possível ler o arquivo XLSX. Verifique se ele não está '
        'corrompido ou protegido por senha.',
      );
    }
    if (excel.tables.isEmpty) return [];

    final sheet = excel.tables.values.first;
    return sheet.rows.map((linha) => linha.map(_textoCelula).toList()).toList();
  }

  static String _textoCelula(Data? celula) {
    return celula?.value?.toString() ?? '';
  }

  static ResultadoImportacao converterLinhas(List<List<String>> linhas) {
    final validos = <AlunoImportado>[];
    final erros = <ErroImportacao>[];

    if (linhas.isEmpty) {
      return ResultadoImportacao(validos: validos, erros: erros);
    }

    var colNome = 0, colEmail = 1;
    int? colAtivo;
    var inicio = 0;

    final cabecalho = linhas.first.map(_normalizar).toList();
    final idxNome = cabecalho.indexWhere(
      (c) =>
          const ['nome', 'nome completo', 'aluno', 'nome do aluno'].contains(c),
    );
    final idxEmail = cabecalho.indexWhere(
      (c) => const ['email', 'e-mail', 'e mail'].contains(c),
    );
    if (idxNome >= 0 || idxEmail >= 0) {
      if (idxNome < 0 || idxEmail < 0) {
        throw ArquivoInvalidoException(
          'Cabeçalho incompleto: é preciso ter as colunas '
          '"nome" e "email" (faltando "${idxNome < 0 ? 'nome' : 'email'}").',
        );
      }
      colNome = idxNome;
      colEmail = idxEmail;
      final idxAtivo = cabecalho.indexWhere(
        (c) => const ['ativo', 'isativo', 'status', 'situacao'].contains(c),
      );
      colAtivo = idxAtivo >= 0 ? idxAtivo : null;
      inicio = 1;
    }

    final emailsVistos = <String, int>{};

    for (var i = inicio; i < linhas.length; i++) {
      final numLinha = i + 1;
      final linha = linhas[i];
      String celula(int col) => col < linha.length ? linha[col].trim() : '';

      if (linha.every((c) => c.trim().isEmpty)) continue;

      final nome = celula(colNome).replaceAll(RegExp(r'\s+'), ' ');
      final email = celula(colEmail).toLowerCase();

      if (nome.isEmpty) {
        erros.add(ErroImportacao(numLinha, 'nome vazio'));
        continue;
      }
      if (email.isEmpty) {
        erros.add(ErroImportacao(numLinha, 'e-mail vazio'));
        continue;
      }
      if (!_emailRegex.hasMatch(email)) {
        erros.add(ErroImportacao(numLinha, 'e-mail inválido ("$email")'));
        continue;
      }
      final repetida = emailsVistos[email];
      if (repetida != null) {
        erros.add(
          ErroImportacao(
            numLinha,
            'e-mail "$email" repetido (já aparece na linha $repetida)',
          ),
        );
        continue;
      }

      bool isAtivo = true;
      if (colAtivo != null) {
        final ativo = _interpretarAtivo(celula(colAtivo));
        if (ativo == null) {
          erros.add(
            ErroImportacao(
              numLinha,
              'valor de "ativo" não reconhecido ("${celula(colAtivo)}")',
            ),
          );
          continue;
        }
        isAtivo = ativo;
      }

      emailsVistos[email] = numLinha;
      validos.add(
        AlunoImportado(
          linha: numLinha,
          nome: nome,
          email: email,
          isAtivo: isAtivo,
        ),
      );
    }

    return ResultadoImportacao(validos: validos, erros: erros);
  }

  static bool? _interpretarAtivo(String valor) {
    final v = _normalizar(valor);
    if (v.isEmpty) return true;
    if (const [
      'sim',
      's',
      'true',
      'verdadeiro',
      '1',
      'ativo',
      'x',
      'yes',
    ].contains(v)) {
      return true;
    }
    if (const [
      'nao',
      'n',
      'false',
      'falso',
      '0',
      'inativo',
      'no',
    ].contains(v)) {
      return false;
    }
    return null;
  }

  static String _normalizar(String s) {
    const de = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const para = 'aaaaaeeeeiiiiooooouuuuc';
    final buffer = StringBuffer();
    for (final ch in s.trim().toLowerCase().split('')) {
      final idx = de.indexOf(ch);
      buffer.write(idx >= 0 ? para[idx] : ch);
    }
    return buffer.toString();
  }
}
