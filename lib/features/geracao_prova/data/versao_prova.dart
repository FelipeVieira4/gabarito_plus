import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gabarito_plus/features/aluno/data/aluno.dart';
import 'package:gabarito_plus/features/questoes/data/alternativa.dart';
import 'package:gabarito_plus/features/questoes/data/questao.dart';

class QuestaoEmbaralhada {
  final Questao questao;
  final List<String> alternativas;
  final int respostaCorreta;

  QuestaoEmbaralhada({
    required this.questao,
    required this.alternativas,
    required this.respostaCorreta,
  });

  factory QuestaoEmbaralhada.fromMap(Map<String, dynamic> map) {
    final alternativas = List<String>.from(map['alternativas'] ?? []);
    final respostaCorreta = map['respostaCorreta'] ?? 0;

    return QuestaoEmbaralhada(
      questao: Questao(
        id: map['questaoId'] ?? '',
        enunciado: map['enunciado'] ?? '',
        alternativas: [
          for (var i = 0; i < alternativas.length; i++)
            Alternativa(texto: alternativas[i], isCorreta: i == respostaCorreta),
        ],
      ),
      alternativas: alternativas,
      respostaCorreta: respostaCorreta,
    );
  }

  /// Cópia congelada da questão: se ela for editada depois, a prova já
  /// impressa continua igual.
  Map<String, dynamic> toMap() => {
        'questaoId': questao.id,
        'enunciado': questao.enunciado,
        'alternativas': alternativas,
        'respostaCorreta': respostaCorreta,
      };
}

class VersaoProva {
  final String codigo;
  final Aluno aluno;
  final List<QuestaoEmbaralhada> questoes;

  VersaoProva({
    required this.codigo,
    required this.aluno,
    required this.questoes,
  });

  factory VersaoProva.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return VersaoProva.fromMap(doc.id, doc.data() ?? {});
  }

  /// O id do documento é o código da versão. Do aluno só são guardados id e
  /// nome; o restante fica na coleção de alunos.
  factory VersaoProva.fromMap(String codigo, Map<String, dynamic> data) {
    return VersaoProva(
      codigo: codigo,
      aluno: Aluno(
        id: data['alunoId'] ?? '',
        nome: data['nomeAluno'] ?? '',
        email: '',
        isAtivo: true,
      ),
      questoes: (data['questoes'] as List<dynamic>? ?? [])
          .map((q) => QuestaoEmbaralhada.fromMap(Map<String, dynamic>.from(q as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'alunoId': aluno.id,
        'nomeAluno': aluno.nome,
        'questoes': questoes.map((q) => q.toMap()).toList(),
      };
}
