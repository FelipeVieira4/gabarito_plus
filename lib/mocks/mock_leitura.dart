import 'package:gabarito_plus/models/gabarito_lido.dart';

const String tituloProvaMock = 'Prova 1 — Engenharia de Software';
const String turmaProvaMock = 'Engenharia de Software 06/2025';
const int quantidadeAlternativasMock = 4;

const List<String> enunciadosMock = [
  'No paradigma de orientação a objetos, o que caracteriza o conceito de herança?',
  'Em orientação a objetos, o que descreve o conceito de encapsulamento?',
  'O que o polimorfismo permite em orientação a objetos?',
  'No método ágil Scrum, o que é uma Sprint?',
  'No Scrum, qual papel é responsável por priorizar os itens do Product Backlog?',
  'Qual das opções abaixo é um exemplo de linguagem fortemente tipada?',
  'Qual tipo de teste verifica o comportamento de uma unidade isolada do código, como um método?',
  'No acrônimo SOLID, a letra "S" representa qual princípio?',
  'Qual das ferramentas abaixo é um sistema de controle de versão distribuído?',
  'Qual abordagem de desenvolvimento valoriza entregas incrementais e a adaptação a mudanças?',
];

const List<List<String>> alternativasMock = [
  [
    'Ocultar os detalhes internos de uma classe',
    'Permitir que uma classe reutilize atributos e métodos de outra',
    'Definir múltiplas assinaturas para o mesmo método',
    'Restringir o acesso direto aos atributos de um objeto',
  ],
  [
    'Ocultar os detalhes internos de uma classe e expor apenas uma interface',
    'Permitir que uma classe herde de várias outras',
    'Executar métodos de forma assíncrona',
    'Converter um objeto em texto',
  ],
  [
    'Que atributos sejam acessados diretamente de fora da classe',
    'Que um mesmo método se comporte de formas diferentes conforme o objeto',
    'Que uma classe não possa ser instanciada',
    'Que o código seja executado em paralelo',
  ],
  [
    'Um documento de requisitos do projeto',
    'Um ciclo curto e fixo de desenvolvimento',
    'O cargo do responsável pelo backlog',
    'Uma reunião diária de alinhamento',
  ],
  [
    'Scrum Master',
    'Product Owner',
    'Time de Desenvolvimento',
    'Stakeholder',
  ],
  [
    'JavaScript',
    'Python',
    'Dart',
    'PHP',
  ],
  [
    'Teste de integração',
    'Teste unitário',
    'Teste de aceitação',
    'Teste de carga',
  ],
  [
    'Princípio da Responsabilidade Única',
    'Princípio Aberto/Fechado',
    'Princípio da Substituição de Liskov',
    'Princípio da Inversão de Dependência',
  ],
  [
    'Git',
    'Jenkins',
    'Maven',
    'Jira',
  ],
  [
    'Cascata (Waterfall)',
    'Ágil',
    'Modelo em V',
    'RUP',
  ],
];

const List<int> respostasCorretasMock = [1, 0, 1, 1, 1, 2, 1, 0, 0, 1];

const List<String> _alunosMock = [
  'José Perreira',
  'Ana Maria',
  'Eduardo Gonçalves',
  'Matheus Oliveira',
  'Ricardo Diaz',
  'Miguel de Souza',
  'Beatriz Ramos',
  'Lucas Andrade',
];

const List<List<int?>> _marcacoesMock = [
  [1, 0, 0, 1, 1, 1, 1, 0, 0, 1],
  [1, 0, 1, 1, 1, 2, 1, 0, 0, 1],
  [1, 0, 0, 1, 1, 1, 1, 2, 0, null],
  [1, 3, 0, 1, 0, 1, 1, 0, 0, 3],
  [1, 0, 1, 1, 1, 1, 1, 0, 0, 1],
  [1, 1, null, 1, 1, 3, 1, 0, 0, 1],
  [0, 0, 0, 1, 2, 1, 3, 0, 1, 1],
  [1, 2, 0, 0, 1, 1, 1, 2, 1, 0],
];

String _codigoVersao(int indice) =>
    'ES2025A-${(indice + 1).toString().padLeft(3, '0')}';

final List<GabaritoLido> gabaritosLidosMock = List.generate(
  _alunosMock.length,
  (indice) => GabaritoLido(
    codigoVersao: _codigoVersao(indice),
    tituloProva: tituloProvaMock,
    nomeTurma: turmaProvaMock,
    nomeAluno: _alunosMock[indice],
    respostasCorretas: respostasCorretasMock,
    quantidadeAlternativas: quantidadeAlternativasMock,
  ),
);

final List<FolhaLida> folhasLidasMock = List.generate(
  _alunosMock.length,
  (indice) => FolhaLida(
    codigoVersao: _codigoVersao(indice),
    respostasMarcadas: _marcacoesMock[indice],
  ),
);


GabaritoLido? gabaritoMockPorCodigo(String codigoVersao) {
  final codigo = codigoVersao.trim().toUpperCase();

  for (final gabarito in gabaritosLidosMock) {
    if (gabarito.codigoVersao == codigo) return gabarito;
  }
  return null;
}

FolhaLida? folhaMockPorCodigo(String codigoVersao) {
  final codigo = codigoVersao.trim().toUpperCase();

  for (final folha in folhasLidasMock) {
    if (folha.codigoVersao == codigo) return folha;
  }
  return null;
}

int _proximoIndiceSimulado = 0;


GabaritoLido proximoGabaritoSimulado() {
  final gabarito = gabaritosLidosMock[_proximoIndiceSimulado];
  _proximoIndiceSimulado =
      (_proximoIndiceSimulado + 1) % gabaritosLidosMock.length;
  return gabarito;
}

void reiniciarSimulacaoDeLeitura() {
  _proximoIndiceSimulado = 0;
}
