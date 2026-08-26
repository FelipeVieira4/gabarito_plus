import 'package:gabarito_plus/models/questao.dart';

final List<Questao> bancoQuestoesMock = <Questao>[
  Questao(
    id: 'q1',
    enunciado: 'Qual estrutura de dados segue o princípio LIFO (Last In, First Out)?',
    alternativas: ['Fila', 'Pilha', 'Lista encadeada', 'Árvore binária'],
    respostaCorreta: 1,
  ),
  Questao(
    id: 'q2',
    enunciado: 'Em um banco de dados relacional, o que é uma chave estrangeira?',
    alternativas: [
      'Um campo que aceita apenas valores nulos',
      'Um índice usado para acelerar buscas',
      'Um campo que referencia a chave primária de outra tabela',
      'Um tipo de dado exclusivo do PostgreSQL',
    ],
    respostaCorreta: 2,
  ),
  Questao(
    id: 'q3',
    enunciado: 'Qual complexidade de tempo o algoritmo de busca binária possui em um array ordenado?',
    alternativas: ['O(n)', 'O(n²)', 'O(1)', 'O(log n)'],
    respostaCorreta: 3,
  ),
  Questao(
    id: 'q4',
    enunciado: 'No paradigma de orientação a objetos, o que caracteriza o conceito de herança?',
    alternativas: [
      'Ocultar os detalhes internos de uma classe',
      'Permitir que uma classe reutilize atributos e métodos de outra',
      'Definir múltiplas assinaturas para o mesmo método',
      'Restringir o acesso direto aos atributos de um objeto',
    ],
    respostaCorreta: 1,
  ),
  Questao(
    id: 'q5',
    enunciado: 'Qual protocolo é responsável por traduzir nomes de domínio em endereços IP?',
    alternativas: ['HTTP', 'DNS', 'FTP', 'SMTP'],
    respostaCorreta: 1,
  ),
  Questao(
    id: 'q6',
    enunciado: 'O que é normalização de dados em um banco de dados relacional?',
    alternativas: [
      'Processo de compactar arquivos de backup',
      'Técnica de criptografia de senhas',
      'Processo de organizar dados para reduzir redundância',
      'Conversão de dados para formato JSON',
    ],
    respostaCorreta: 2,
  ),
  Questao(
    id: 'q7',
    enunciado: 'Qual das opções abaixo é um exemplo de linguagem fortemente tipada?',
    alternativas: ['JavaScript', 'Python', 'Dart', 'PHP'],
    respostaCorreta: 2,
  ),
  Questao(
    id: 'q8',
    enunciado: 'No método ágil Scrum, o que é uma Sprint?',
    alternativas: [
      'Um documento de requisitos do projeto',
      'Um ciclo curto e fixo de desenvolvimento',
      'O cargo do responsável pelo backlog',
      'Uma reunião diária de alinhamento',
    ],
    respostaCorreta: 1,
  ),
];
