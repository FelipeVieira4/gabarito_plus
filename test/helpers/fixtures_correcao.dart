import 'package:gabarito_plus/features/aluno/data/aluno.dart';
import 'package:gabarito_plus/features/correcao_prova/services/correcao_service.dart';
import 'package:gabarito_plus/features/disciplina/data/assunto.dart';
import 'package:gabarito_plus/features/geracao_prova/data/correcao.dart';
import 'package:gabarito_plus/features/geracao_prova/data/gabarito_lido.dart';
import 'package:gabarito_plus/features/geracao_prova/data/prova.dart';
import 'package:gabarito_plus/features/questoes/data/alternativa.dart';
import 'package:gabarito_plus/features/questoes/data/questao.dart';
import 'package:gabarito_plus/features/turma/data/turma.dart';

const tituloProvaTeste = 'Prova 1 — Engenharia de Software';
const turmaProvaTeste = 'Engenharia de Software 06/2025';
const quantidadeAlternativasTeste = 4;

const respostasCorretasTeste = [1, 0, 1, 1, 1, 2, 1, 0, 0, 1];

final enunciadosTeste = List.generate(10, (i) => 'Enunciado ${i + 1}');

const _alunosTeste = [
  'José Perreira',
  'Ana Maria',
  'Eduardo Gonçalves',
  'Matheus Oliveira',
  'Ricardo Diaz',
  'Miguel de Souza',
  'Beatriz Ramos',
  'Lucas Andrade',
];

const _marcacoesTeste = <List<int?>>[
  [1, 0, 0, 1, 1, 1, 1, 0, 0, 1],
  [1, 0, 1, 1, 1, 2, 1, 0, 0, 1],
  [1, 0, 0, 1, 1, 1, 1, 2, 0, null],
  [1, 3, 0, 1, 0, 1, 1, 0, 0, 3],
  [1, 0, 1, 1, 1, 1, 1, 0, 0, 1],
  [1, 1, null, 1, 1, 3, 1, 0, 0, 1],
  [0, 0, 0, 1, 2, 1, 3, 0, 1, 1],
  [1, 2, 0, 0, 1, 1, 1, 2, 1, 0],
];

String codigoVersaoTeste(int indice) =>
    'ES2025A-${(indice + 1).toString().padLeft(3, '0')}';

final DateTime dataAplicacaoTeste = DateTime(2026, 9, 10, 14, 30);

/// 8 correções. Notas: 8, 10, 6, 5, 9, 7, 4, 3 (média 6,5; 5 aprovados).
List<Correcao> gerarCorrecoesDeTeste() {
  final service = CorrecaoService();

  return List.generate(_alunosTeste.length, (i) {
    final codigo = codigoVersaoTeste(i);
    return service.corrigir(
      gabarito: GabaritoLido(
        codigoVersao: codigo,
        tituloProva: tituloProvaTeste,
        nomeTurma: turmaProvaTeste,
        nomeAluno: _alunosTeste[i],
        respostasCorretas: respostasCorretasTeste,
        quantidadeAlternativas: quantidadeAlternativasTeste,
      ),
      folha: FolhaLida(
        codigoVersao: codigo,
        respostasMarcadas: _marcacoesTeste[i],
      ),
      dataHora: dataAplicacaoTeste.add(Duration(minutes: i)),
    );
  });
}

/// Prova com 10 questões para José (versão 01) e Ana (versão 02).
/// Sem embaralhar, o gabarito é [respostasCorretasTeste].
Prova provaDeTeste({String id = 'ABC234'}) {
  final questoes = [
    for (var i = 0; i < respostasCorretasTeste.length; i++)
      Questao(
        id: 'q${i + 1}',
        enunciado: 'Questão ${i + 1}',
        alternativas: [
          for (var a = 0; a < 4; a++)
            Alternativa(
              texto: 'Alt $a',
              isCorreta: a == respostasCorretasTeste[i],
            ),
        ],
      ),
  ];

  return Prova(
    id: id,
    titulo: tituloProvaTeste,
    turma: Turma(
      id: 'turma-1',
      nomeTurma: turmaProvaTeste,
      listaAlunos: [
        Aluno(id: 'aluno-1', nome: 'José Perreira', email: '', isAtivo: true),
        Aluno(id: 'aluno-2', nome: 'Ana Maria', email: '', isAtivo: true),
      ],
      ativa: true,
    ),
    assunto: Assunto(id: 'assunto-1', nome: 'POO', questoes: questoes),
    questoes: questoes,
    embaralharQuestoes: false,
    embaralharAlternativas: false,
  );
}