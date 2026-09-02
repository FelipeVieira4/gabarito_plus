import 'package:gabarito_plus/mocks/mock_displina.dart';
import 'package:gabarito_plus/models/alternativa.dart';
import 'package:gabarito_plus/models/assunto.dart';
import 'package:gabarito_plus/models/disciplina.dart';
import 'package:gabarito_plus/models/questao.dart';

/// Centraliza o acesso à árvore Disciplina > Assunto > Questao,
/// para as telas não precisarem navegar/filtrar essa estrutura na mão.
class QuestoesService {
  /// Retorna todas as disciplinas cadastradas.
  List<Disciplina> obterDisciplinas() {
    return listaDisciplina;
  }

  /// Retorna os assuntos. Se [disciplinaId] for informado, retorna só os
  /// assuntos daquela disciplina; senão, retorna os assuntos de todas.
  List<Assunto> obterAssuntos({String? disciplinaId}) {
    final disciplinas = disciplinaId == null
        ? listaDisciplina
        : listaDisciplina.where((d) => d.id == disciplinaId);

    return disciplinas.expand((d) => d.assuntos).toList();
  }

  /// Retorna as questões filtradas por disciplina, assunto e/ou um texto
  /// de busca (procurado no enunciado, na disciplina e no assunto).
  List<Questao> obterQuestoes({
    String? disciplinaId,
    String? assuntoId,
    String? busca,
  }) {
    final termoBusca = busca?.trim().toLowerCase();

    final disciplinas = disciplinaId == null
        ? listaDisciplina
        : listaDisciplina.where((d) => d.id == disciplinaId);

    final resultado = <Questao>[];

    for (final disciplina in disciplinas) {
      for (final assunto in disciplina.assuntos) {
        if (assuntoId != null && assunto.id != assuntoId) continue;

        for (final questao in assunto.questoes) {
          final bateBusca = termoBusca == null ||
              termoBusca.isEmpty ||
              questao.enunciado.toLowerCase().contains(termoBusca) ||
              disciplina.descricao.toLowerCase().contains(termoBusca) ||
              assunto.nome.toLowerCase().contains(termoBusca);

          if (bateBusca) {
            resultado.add(questao);
          }
        }
      }
    }

    return resultado;
  }

  /// Acha o Assunto ao qual a [questao] pertence, percorrendo a árvore.
  Assunto? obterAssuntoDaQuestao(Questao questao) {
    for (final disciplina in listaDisciplina) {
      for (final assunto in disciplina.assuntos) {
        if (assunto.questoes.any((q) => q.id == questao.id)) {
          return assunto;
        }
      }
    }
    return null;
  }

  /// Acha a Disciplina à qual a [questao] pertence, percorrendo a árvore.
  Disciplina? obterDisciplinaDaQuestao(Questao questao) {
    for (final disciplina in listaDisciplina) {
      for (final assunto in disciplina.assuntos) {
        if (assunto.questoes.any((q) => q.id == questao.id)) {
          return disciplina;
        }
      }
    }
    return null;
  }

  /// Monta uma nova Questao a partir dos dados do formulário de cadastro.
  Questao criarQuestao({
    required String enunciado,
    required List<Alternativa> alternativas,
  }) {
    return Questao(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      enunciado: enunciado,
      alternativas: alternativas,
    );
  }

  /// Adiciona uma questão já existente ao Assunto indicado.
  void adicionarQuestao({
    required String disciplinaId,
    required String assuntoId,
    required Questao questao,
  }) {
    final disciplina = listaDisciplina.firstWhere(
      (d) => d.id == disciplinaId,
      orElse: () =>
          throw ArgumentError('Disciplina não encontrada: $disciplinaId'),
    );

    final assunto = disciplina.assuntos.firstWhere(
      (a) => a.id == assuntoId,
      orElse: () => throw ArgumentError('Assunto não encontrado: $assuntoId'),
    );

    assunto.questoes.add(questao);
  }
}