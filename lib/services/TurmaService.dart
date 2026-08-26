
import 'package:gabarito_plus/models/turma.dart';
import 'package:gabarito_plus/mocks/mock_turma.dart';

class TurmaService {
  List<Turma> obterListaTurmaAtivas(){
    List<Turma> listaTurmaAtiva = [];


    for (Turma turma in listaTurma){
      if (turma.ativa){
        listaTurmaAtiva.add(turma);
      }
    }
    return listaTurmaAtiva;
  }
}