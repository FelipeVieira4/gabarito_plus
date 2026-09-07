import 'package:gabarito_plus/mocks/mock_aluno.dart';
import 'package:gabarito_plus/models/aluno.dart';

class AlunoService {
  List<Aluno> obterListaAlunosFiltrado({
    String? nomeAluno,
    bool apenasAtivos = false,
  }) {
    List<Aluno> resultado = listaAlunos;

    if (apenasAtivos) {
      resultado = obterListaAlunosAtivo(resultado);
    }

    if (nomeAluno != null && nomeAluno.isNotEmpty) {
      resultado = obterListaAlunosPeloNome(nomeAluno, resultado);
    }

    return resultado;
  }

  List<Aluno> obterListaAlunosAtivo([List<Aluno>? fonte]) {
    final base = fonte ?? listaAlunos;
    return base.where((aluno) => aluno.isAtivo).toList();
  }

  List<Aluno> obterListaAlunosPeloNome(String name, [List<Aluno>? fonte]) {
    final base = fonte ?? listaAlunos;
    return base
        .where((aluno) => aluno.nome.toLowerCase().contains(name.toLowerCase()))
        .toList();
  }
}