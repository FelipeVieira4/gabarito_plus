import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gabarito_plus/features/disciplina/data/assunto.dart';
import 'package:gabarito_plus/features/disciplina/data/disciplina.dart';
import 'package:gabarito_plus/features/disciplina/service/disciplinas_service.dart';
import 'package:gabarito_plus/features/questoes/data/questao.dart';

class QuestoesService {
  final _questoes = FirebaseFirestore.instance.collection('questoes');
  final _disciplinasService = DisciplinasService();

  Future<List<Disciplina>> obterDisciplinas() {
    return _disciplinasService.listarDisciplinas();
  }

  List<Assunto> obterAssuntos(
    List<Disciplina> disciplinas, {
    String? disciplinaId,
  }) {
    final filtradas = disciplinaId == null
        ? disciplinas
        : disciplinas.where((d) => d.id == disciplinaId);

    return filtradas.expand((d) => d.assuntos).toList();
  }

  List<Questao> obterQuestoes(
    List<Disciplina> disciplinas, {
    String? disciplinaId,
    String? assuntoId,
    String? busca,
  }) {
    final termoBusca = busca?.trim().toLowerCase();

    final filtradas = disciplinaId == null
        ? disciplinas
        : disciplinas.where((d) => d.id == disciplinaId);

    final resultado = <Questao>[];

    for (final disciplina in filtradas) {
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

  Assunto? obterAssuntoDaQuestao(
    List<Disciplina> disciplinas,
    Questao questao,
  ) {
    for (final disciplina in disciplinas) {
      for (final assunto in disciplina.assuntos) {
        if (assunto.questoes.any((q) => q.id == questao.id)) {
          return assunto;
        }
      }
    }
    return null;
  }

  Disciplina? obterDisciplinaDaQuestao(
    List<Disciplina> disciplinas,
    Questao questao,
  ) {
    for (final disciplina in disciplinas) {
      for (final assunto in disciplina.assuntos) {
        if (assunto.questoes.any((q) => q.id == questao.id)) {
          return disciplina;
        }
      }
    }
    return null;
  }

  Future<String> salvarQuestao({
    required String disciplinaId,
    required String assuntoId,
    required Questao questao,
  }) async {
    final doc = questao.id.isEmpty ? _questoes.doc() : _questoes.doc(questao.id);
    await doc.set(
      questao.toMap(disciplinaId: disciplinaId, assuntoId: assuntoId),
    );
    return doc.id;
  }
}
