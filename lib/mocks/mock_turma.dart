import 'package:gabarito_plus/models/aluno.dart';
import 'package:gabarito_plus/models/turma.dart';

final Turma turmaMock = Turma(
  id: '1',
  nomeTurma: 'Engenharia de Software 06/2025',
  listaAlunos: [
    Aluno(id: '1',
      nome: 'José Perreira',
      email: 'joselito@email.com'
    ),
    Aluno(
      id: '2',
      nome: 'Ana Maria',
      email: 'Ana63653@email.com'
    )
  ]
);


final List<Turma> listaTurma = <Turma>[
  Turma(
    id: '2',
    nomeTurma: 'Adiministração 01/2026',
    listaAlunos: [
      Aluno(id: '1',
        nome: 'José Perreira',
        email: 'joselito@email.com'
      ),
      Aluno(
        id: '2',
        nome: 'Ana Maria',
        email: 'Ana63653@email.com'
      )
    ]
  ),
  Turma(
    id: '3',
    nomeTurma: 'Direito 06/2026',
    listaAlunos: [
      Aluno(
        id: '3',
        nome: 'Eduardo Gonçalves',
        email: 'dudu459476@email.com'
      ),
      Aluno(
        id: '4',
        nome: 'Matheus Oliveira',
        email: 'matheusOliv23445@email.com'
      ),
    ]
  ),
  Turma(
    id: '1',
    nomeTurma: 'Engenharia de Software 06/2025',
    listaAlunos: [
      Aluno(
        id: '5',
        nome: 'Ricardo Diaz',
        email: 'racardoTESTE123@email.com'
      ),
      Aluno(
        id: '6',
        nome: 'Miguel de Souza',
        email: 'miguelSouza546@yahoo.com'
      )
    ]
  )
];