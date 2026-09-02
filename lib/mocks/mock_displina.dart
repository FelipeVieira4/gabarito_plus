import 'package:gabarito_plus/models/disciplina.dart';
import 'package:gabarito_plus/models/assunto.dart';
import 'package:gabarito_plus/models/questao.dart';
import 'package:gabarito_plus/models/alternativa.dart';
 
final List<Disciplina> listaDisciplina = <Disciplina>[
  Disciplina(
    id: '1',
    descricao: 'Estruturas de Dados',
    assuntos: <Assunto>[
      Assunto(
        id: 'estruturas-de-dados-conceitos-basicos',
        nome: 'Conceitos Básicos',
        questoes: <Questao>[
          Questao(
            id: 'ed1',
            enunciado: 'Qual estrutura de dados segue o princípio LIFO (Last In, First Out)?',
            alternativas: [
              Alternativa(texto: 'Fila', isCorreta: false),
              Alternativa(texto: 'Pilha', isCorreta: true),
              Alternativa(texto: 'Lista encadeada', isCorreta: false),
              Alternativa(texto: 'Árvore binária', isCorreta: false),
            ],
          ),
          Questao(
            id: 'ed2',
            enunciado: 'Qual estrutura de dados segue o princípio FIFO (First In, First Out)?',
            alternativas: [
              Alternativa(texto: 'Pilha', isCorreta: false),
              Alternativa(texto: 'Fila', isCorreta: true),
              Alternativa(texto: 'Tabela hash', isCorreta: false),
              Alternativa(texto: 'Grafo', isCorreta: false),
            ],
          ),
        ],
      ),
      Assunto(
        id: 'estruturas-de-dados-algoritmos',
        nome: 'Algoritmos',
        questoes: <Questao>[
          Questao(
            id: 'ed3',
            enunciado: 'Qual complexidade de tempo o algoritmo de busca binária possui em um array ordenado?',
            alternativas: [
              Alternativa(texto: 'O(n)', isCorreta: false),
              Alternativa(texto: 'O(n²)', isCorreta: false),
              Alternativa(texto: 'O(1)', isCorreta: false),
              Alternativa(texto: 'O(log n)', isCorreta: true),
            ],
          ),
        ],
      ),
      Assunto(
        id: 'estruturas-de-dados-arrays',
        nome: 'Arrays',
        questoes: <Questao>[
          Questao(
            id: 'ed4',
            enunciado: 'Qual é a complexidade de tempo para acessar um elemento de um array pelo seu índice?',
            alternativas: [
              Alternativa(texto: 'O(1)', isCorreta: true),
              Alternativa(texto: 'O(log n)', isCorreta: false),
              Alternativa(texto: 'O(n)', isCorreta: false),
              Alternativa(texto: 'O(n log n)', isCorreta: false),
            ],
          ),
        ],
      ),
      Assunto(
        id: 'estruturas-de-dados-listas',
        nome: 'Listas',
        questoes: <Questao>[
          Questao(
            id: 'ed5',
            enunciado: 'Em uma lista simplesmente encadeada, o que cada nó armazena?',
            alternativas: [
              Alternativa(texto: 'Apenas o valor do elemento', isCorreta: false),
              Alternativa(texto: 'O valor do elemento e a referência para o próximo nó', isCorreta: true),
              Alternativa(texto: 'O valor do elemento e as referências para o anterior e o próximo nó', isCorreta: false),
              Alternativa(texto: 'Somente ponteiros, sem valores', isCorreta: false),
            ],
          ),
        ],
      ),
      Assunto(
        id: 'estruturas-de-dados-pilhas',
        nome: 'Pilhas',
        questoes: <Questao>[
          Questao(
            id: 'ed6',
            enunciado: 'Qual estrutura de dados é mais adequada para verificar se os parênteses de uma expressão estão balanceados?',
            alternativas: [
              Alternativa(texto: 'Fila', isCorreta: false),
              Alternativa(texto: 'Pilha', isCorreta: true),
              Alternativa(texto: 'Árvore B', isCorreta: false),
              Alternativa(texto: 'Lista ordenada', isCorreta: false),
            ],
          ),
        ],
      ),
      Assunto(
        id: 'estruturas-de-dados-hash',
        nome: 'Hash',
        questoes: <Questao>[
          Questao(
            id: 'ed7',
            enunciado: 'Em uma tabela hash, o que caracteriza uma colisão?',
            alternativas: [
              Alternativa(texto: 'Quando a tabela fica completamente cheia', isCorreta: false),
              Alternativa(texto: 'Quando duas chaves diferentes são mapeadas para o mesmo índice', isCorreta: true),
              Alternativa(texto: 'Quando uma chave não é encontrada', isCorreta: false),
              Alternativa(texto: 'Quando a função de hash retorna um valor negativo', isCorreta: false),
            ],
          ),
        ],
      ),
      Assunto(
        id: 'estruturas-de-dados-arvores',
        nome: 'Árvores',
        questoes: <Questao>[
          Questao(
            id: 'ed8',
            enunciado: 'Qual percurso em árvore binária de busca visita os nós em ordem crescente de valor?',
            alternativas: [
              Alternativa(texto: 'Pré-ordem', isCorreta: false),
              Alternativa(texto: 'Pós-ordem', isCorreta: false),
              Alternativa(texto: 'Em ordem (in-order)', isCorreta: true),
              Alternativa(texto: 'Em largura', isCorreta: false),
            ],
          ),
        ],
      ),
      Assunto(
        id: 'estruturas-de-dados-grafos',
        nome: 'Grafos',
        questoes: <Questao>[
          Questao(
            id: 'ed9',
            enunciado: 'Qual estrutura de dados representa relações entre elementos por meio de vértices e arestas?',
            alternativas: [
              Alternativa(texto: 'Pilha', isCorreta: false),
              Alternativa(texto: 'Fila', isCorreta: false),
              Alternativa(texto: 'Grafo', isCorreta: true),
              Alternativa(texto: 'Vetor', isCorreta: false),
            ],
          ),
        ],
      ),
      Assunto(
        id: 'estruturas-de-dados-filas',
        nome: 'Filas',
        questoes: <Questao>[
          Questao(
            id: 'ed10',
            enunciado: 'Em uma fila, como são chamadas as operações de inserção e de remoção, respectivamente?',
            alternativas: [
              Alternativa(texto: 'push e pop', isCorreta: false),
              Alternativa(texto: 'enqueue e dequeue', isCorreta: true),
              Alternativa(texto: 'insert e delete', isCorreta: false),
              Alternativa(texto: 'add e peek', isCorreta: false),
            ],
          ),
        ],
      ),
    ],
  ),
  Disciplina(
    id: '2',
    descricao: 'Banco de Dados',
    assuntos: <Assunto>[
      Assunto(
        id: 'banco-de-dados-modelagem',
        nome: 'Modelagem',
        questoes: <Questao>[
          Questao(
            id: 'bd1',
            enunciado: 'Em um banco de dados relacional, o que é uma chave estrangeira?',
            alternativas: [
              Alternativa(texto: 'Um campo que aceita apenas valores nulos', isCorreta: false),
              Alternativa(texto: 'Um índice usado para acelerar buscas', isCorreta: false),
              Alternativa(texto: 'Um campo que referencia a chave primária de outra tabela', isCorreta: true),
              Alternativa(texto: 'Um tipo de dado exclusivo do PostgreSQL', isCorreta: false),
            ],
          ),
          Questao(
            id: 'bd2',
            enunciado: 'O que é normalização de dados em um banco de dados relacional?',
            alternativas: [
              Alternativa(texto: 'Processo de compactar arquivos de backup', isCorreta: false),
              Alternativa(texto: 'Técnica de criptografia de senhas', isCorreta: false),
              Alternativa(texto: 'Processo de organizar dados para reduzir redundância', isCorreta: true),
              Alternativa(texto: 'Conversão de dados para formato JSON', isCorreta: false),
            ],
          ),
        ],
      ),
      Assunto(
        id: 'banco-de-dados-sql',
        nome: 'SQL',
        questoes: <Questao>[
          Questao(
            id: 'bd3',
            enunciado: 'Qual comando SQL é utilizado para recuperar dados de uma tabela?',
            alternativas: [
              Alternativa(texto: 'INSERT', isCorreta: false),
              Alternativa(texto: 'SELECT', isCorreta: true),
              Alternativa(texto: 'UPDATE', isCorreta: false),
              Alternativa(texto: 'CREATE', isCorreta: false),
            ],
          ),
          Questao(
            id: 'bd4',
            enunciado: 'Qual cláusula SQL é usada para filtrar as linhas retornadas por uma consulta?',
            alternativas: [
              Alternativa(texto: 'ORDER BY', isCorreta: false),
              Alternativa(texto: 'GROUP BY', isCorreta: false),
              Alternativa(texto: 'WHERE', isCorreta: true),
              Alternativa(texto: 'HAVING', isCorreta: false),
            ],
          ),
          Questao(
            id: 'bd5',
            enunciado: 'Qual comando SQL remove uma tabela inteira, incluindo sua estrutura?',
            alternativas: [
              Alternativa(texto: 'DELETE FROM tabela', isCorreta: false),
              Alternativa(texto: 'DROP TABLE tabela', isCorreta: true),
              Alternativa(texto: 'TRUNCATE tabela', isCorreta: false),
              Alternativa(texto: 'REMOVE TABLE tabela', isCorreta: false),
            ],
          ),
          Questao(
            id: 'bd7',
            enunciado: 'Qual tipo de JOIN retorna apenas as linhas que possuem correspondência em ambas as tabelas?',
            alternativas: [
              Alternativa(texto: 'LEFT JOIN', isCorreta: false),
              Alternativa(texto: 'RIGHT JOIN', isCorreta: false),
              Alternativa(texto: 'FULL OUTER JOIN', isCorreta: false),
              Alternativa(texto: 'INNER JOIN', isCorreta: true),
            ],
          ),
          Questao(
            id: 'bd8',
            enunciado: 'Qual restrição (constraint) impede que uma coluna tenha valores duplicados?',
            alternativas: [
              Alternativa(texto: 'NOT NULL', isCorreta: false),
              Alternativa(texto: 'UNIQUE', isCorreta: true),
              Alternativa(texto: 'DEFAULT', isCorreta: false),
              Alternativa(texto: 'CHECK', isCorreta: false),
            ],
          ),
          Questao(
            id: 'bd10',
            enunciado: 'Qual cláusula é usada junto de funções de agregação para agrupar os resultados de uma consulta?',
            alternativas: [
              Alternativa(texto: 'WHERE', isCorreta: false),
              Alternativa(texto: 'GROUP BY', isCorreta: true),
              Alternativa(texto: 'ORDER BY', isCorreta: false),
              Alternativa(texto: 'DISTINCT', isCorreta: false),
            ],
          ),
        ],
      ),
      Assunto(
        id: 'banco-de-dados-transacoes',
        nome: 'Transações',
        questoes: <Questao>[
          Questao(
            id: 'bd6',
            enunciado: 'Na sigla ACID, qual propriedade garante que uma transação seja executada por completo ou não seja executada?',
            alternativas: [
              Alternativa(texto: 'Atomicidade', isCorreta: true),
              Alternativa(texto: 'Consistência', isCorreta: false),
              Alternativa(texto: 'Isolamento', isCorreta: false),
              Alternativa(texto: 'Durabilidade', isCorreta: false),
            ],
          ),
        ],
      ),
      Assunto(
        id: 'banco-de-dados-performance',
        nome: 'Performance',
        questoes: <Questao>[
          Questao(
            id: 'bd9',
            enunciado: 'Qual a principal finalidade de um índice em um banco de dados?',
            alternativas: [
              Alternativa(texto: 'Garantir a integridade referencial', isCorreta: false),
              Alternativa(texto: 'Acelerar a busca de registros', isCorreta: true),
              Alternativa(texto: 'Criptografar os dados armazenados', isCorreta: false),
              Alternativa(texto: 'Reduzir o tamanho do banco em disco', isCorreta: false),
            ],
          ),
        ],
      ),
    ],
  ),
  Disciplina(
    id: '3',
    descricao: 'Redes de Computadores',
    assuntos: <Assunto>[
      Assunto(
        id: 'redes-de-computadores-protocolos',
        nome: 'Protocolos',
        questoes: <Questao>[
          Questao(
            id: 'rd1',
            enunciado: 'Qual protocolo é responsável por traduzir nomes de domínio em endereços IP?',
            alternativas: [
              Alternativa(texto: 'HTTP', isCorreta: false),
              Alternativa(texto: 'DNS', isCorreta: true),
              Alternativa(texto: 'FTP', isCorreta: false),
              Alternativa(texto: 'SMTP', isCorreta: false),
            ],
          ),
          Questao(
            id: 'rd2',
            enunciado: 'Qual protocolo da camada de transporte é orientado à conexão e garante a entrega dos dados?',
            alternativas: [
              Alternativa(texto: 'UDP', isCorreta: false),
              Alternativa(texto: 'IP', isCorreta: false),
              Alternativa(texto: 'TCP', isCorreta: true),
              Alternativa(texto: 'ICMP', isCorreta: false),
            ],
          ),
          Questao(
            id: 'rd3',
            enunciado: 'Qual é a porta padrão utilizada pelo protocolo HTTP?',
            alternativas: [
              Alternativa(texto: '21', isCorreta: false),
              Alternativa(texto: '25', isCorreta: false),
              Alternativa(texto: '80', isCorreta: true),
              Alternativa(texto: '443', isCorreta: false),
            ],
          ),
          Questao(
            id: 'rd8',
            enunciado: 'Qual protocolo é utilizado para o envio de e-mails entre servidores?',
            alternativas: [
              Alternativa(texto: 'POP3', isCorreta: false),
              Alternativa(texto: 'IMAP', isCorreta: false),
              Alternativa(texto: 'SMTP', isCorreta: true),
              Alternativa(texto: 'SNMP', isCorreta: false),
            ],
          ),
          Questao(
            id: 'rd9',
            enunciado: 'Qual protocolo atribui automaticamente endereços IP aos hosts de uma rede?',
            alternativas: [
              Alternativa(texto: 'DHCP', isCorreta: true),
              Alternativa(texto: 'DNS', isCorreta: false),
              Alternativa(texto: 'ARP', isCorreta: false),
              Alternativa(texto: 'NAT', isCorreta: false),
            ],
          ),
        ],
      ),
      Assunto(
        id: 'redes-de-computadores-hardware',
        nome: 'Hardware',
        questoes: <Questao>[
          Questao(
            id: 'rd4',
            enunciado: 'Como é chamado o endereço físico associado à interface de rede de um dispositivo?',
            alternativas: [
              Alternativa(texto: 'Endereço IP', isCorreta: false),
              Alternativa(texto: 'Endereço MAC', isCorreta: true),
              Alternativa(texto: 'Endereço de broadcast', isCorreta: false),
              Alternativa(texto: 'Endereço de gateway', isCorreta: false),
            ],
          ),
          Questao(
            id: 'rd6',
            enunciado: 'Qual dispositivo é responsável por encaminhar pacotes entre redes distintas?',
            alternativas: [
              Alternativa(texto: 'Switch', isCorreta: false),
              Alternativa(texto: 'Hub', isCorreta: false),
              Alternativa(texto: 'Roteador', isCorreta: true),
              Alternativa(texto: 'Repetidor', isCorreta: false),
            ],
          ),
        ],
      ),
      Assunto(
        id: 'redes-de-computadores-ip',
        nome: 'IP',
        questoes: <Questao>[
          Questao(
            id: 'rd5',
            enunciado: 'Quantos bits possui um endereço IPv4?',
            alternativas: [
              Alternativa(texto: '16', isCorreta: false),
              Alternativa(texto: '32', isCorreta: true),
              Alternativa(texto: '64', isCorreta: false),
              Alternativa(texto: '128', isCorreta: false),
            ],
          ),
        ],
      ),
      Assunto(
        id: 'redes-de-computadores-modelo-osi',
        nome: 'Modelo OSI',
        questoes: <Questao>[
          Questao(
            id: 'rd7',
            enunciado: 'Qual camada do modelo OSI é responsável pelo roteamento dos pacotes?',
            alternativas: [
              Alternativa(texto: 'Camada de Enlace', isCorreta: false),
              Alternativa(texto: 'Camada de Rede', isCorreta: true),
              Alternativa(texto: 'Camada de Transporte', isCorreta: false),
              Alternativa(texto: 'Camada de Aplicação', isCorreta: false),
            ],
          ),
        ],
      ),
      Assunto(
        id: 'redes-de-computadores-seguranca',
        nome: 'Segurança',
        questoes: <Questao>[
          Questao(
            id: 'rd10',
            enunciado: 'O HTTPS adiciona uma camada de segurança ao HTTP por meio de qual protocolo?',
            alternativas: [
              Alternativa(texto: 'SSH', isCorreta: false),
              Alternativa(texto: 'TLS/SSL', isCorreta: true),
              Alternativa(texto: 'IPSec', isCorreta: false),
              Alternativa(texto: 'Kerberos', isCorreta: false),
            ],
          ),
        ],
      ),
    ],
  ),
  Disciplina(
    id: '4',
    descricao: 'Engenharia de Software',
    assuntos: <Assunto>[
      Assunto(
        id: 'engenharia-de-software-poo',
        nome: 'POO',
        questoes: <Questao>[
          Questao(
            id: 'es1',
            enunciado: 'No paradigma de orientação a objetos, o que caracteriza o conceito de herança?',
            alternativas: [
              Alternativa(texto: 'Ocultar os detalhes internos de uma classe', isCorreta: false),
              Alternativa(texto: 'Permitir que uma classe reutilize atributos e métodos de outra', isCorreta: true),
              Alternativa(texto: 'Definir múltiplas assinaturas para o mesmo método', isCorreta: false),
              Alternativa(texto: 'Restringir o acesso direto aos atributos de um objeto', isCorreta: false),
            ],
          ),
          Questao(
            id: 'es4',
            enunciado: 'Em orientação a objetos, o que descreve o conceito de encapsulamento?',
            alternativas: [
              Alternativa(texto: 'Ocultar os detalhes internos de uma classe e expor apenas uma interface', isCorreta: true),
              Alternativa(texto: 'Permitir que uma classe herde de várias outras', isCorreta: false),
              Alternativa(texto: 'Executar métodos de forma assíncrona', isCorreta: false),
              Alternativa(texto: 'Converter um objeto em texto', isCorreta: false),
            ],
          ),
          Questao(
            id: 'es9',
            enunciado: 'O que o polimorfismo permite em orientação a objetos?',
            alternativas: [
              Alternativa(texto: 'Que atributos sejam acessados diretamente de fora da classe', isCorreta: false),
              Alternativa(texto: 'Que um mesmo método se comporte de formas diferentes conforme o objeto', isCorreta: true),
              Alternativa(texto: 'Que uma classe não possa ser instanciada', isCorreta: false),
              Alternativa(texto: 'Que o código seja executado em paralelo', isCorreta: false),
            ],
          ),
        ],
      ),
      Assunto(
        id: 'engenharia-de-software-scrum',
        nome: 'Scrum',
        questoes: <Questao>[
          Questao(
            id: 'es2',
            enunciado: 'No método ágil Scrum, o que é uma Sprint?',
            alternativas: [
              Alternativa(texto: 'Um documento de requisitos do projeto', isCorreta: false),
              Alternativa(texto: 'Um ciclo curto e fixo de desenvolvimento', isCorreta: true),
              Alternativa(texto: 'O cargo do responsável pelo backlog', isCorreta: false),
              Alternativa(texto: 'Uma reunião diária de alinhamento', isCorreta: false),
            ],
          ),
          Questao(
            id: 'es5',
            enunciado: 'No Scrum, qual papel é responsável por priorizar os itens do Product Backlog?',
            alternativas: [
              Alternativa(texto: 'Scrum Master', isCorreta: false),
              Alternativa(texto: 'Product Owner', isCorreta: true),
              Alternativa(texto: 'Time de Desenvolvimento', isCorreta: false),
              Alternativa(texto: 'Stakeholder', isCorreta: false),
            ],
          ),
        ],
      ),
      Assunto(
        id: 'engenharia-de-software-linguagens-de-programacao',
        nome: 'Linguagens de Programação',
        questoes: <Questao>[
          Questao(
            id: 'es3',
            enunciado: 'Qual das opções abaixo é um exemplo de linguagem fortemente tipada?',
            alternativas: [
              Alternativa(texto: 'JavaScript', isCorreta: false),
              Alternativa(texto: 'Python', isCorreta: false),
              Alternativa(texto: 'Dart', isCorreta: true),
              Alternativa(texto: 'PHP', isCorreta: false),
            ],
          ),
        ],
      ),
      Assunto(
        id: 'engenharia-de-software-testes-de-software',
        nome: 'Testes de Software',
        questoes: <Questao>[
          Questao(
            id: 'es6',
            enunciado: 'Qual tipo de teste verifica o comportamento de uma unidade isolada do código, como um método?',
            alternativas: [
              Alternativa(texto: 'Teste de integração', isCorreta: false),
              Alternativa(texto: 'Teste unitário', isCorreta: true),
              Alternativa(texto: 'Teste de aceitação', isCorreta: false),
              Alternativa(texto: 'Teste de carga', isCorreta: false),
            ],
          ),
        ],
      ),
      Assunto(
        id: 'engenharia-de-software-solid',
        nome: 'SOLID',
        questoes: <Questao>[
          Questao(
            id: 'es7',
            enunciado: 'No acrônimo SOLID, a letra "S" representa qual princípio?',
            alternativas: [
              Alternativa(texto: 'Princípio da Responsabilidade Única', isCorreta: true),
              Alternativa(texto: 'Princípio Aberto/Fechado', isCorreta: false),
              Alternativa(texto: 'Princípio da Substituição de Liskov', isCorreta: false),
              Alternativa(texto: 'Princípio da Inversão de Dependência', isCorreta: false),
            ],
          ),
        ],
      ),
      Assunto(
        id: 'engenharia-de-software-ferramentas',
        nome: 'Ferramentas',
        questoes: <Questao>[
          Questao(
            id: 'es8',
            enunciado: 'Qual das ferramentas abaixo é um sistema de controle de versão distribuído?',
            alternativas: [
              Alternativa(texto: 'Git', isCorreta: true),
              Alternativa(texto: 'Jenkins', isCorreta: false),
              Alternativa(texto: 'Maven', isCorreta: false),
              Alternativa(texto: 'Jira', isCorreta: false),
            ],
          ),
        ],
      ),
      Assunto(
        id: 'engenharia-de-software-metodologias-ageis',
        nome: 'Metodologias Ágeis',
        questoes: <Questao>[
          Questao(
            id: 'es10',
            enunciado: 'Qual abordagem de desenvolvimento valoriza entregas incrementais e a adaptação a mudanças?',
            alternativas: [
              Alternativa(texto: 'Cascata (Waterfall)', isCorreta: false),
              Alternativa(texto: 'Ágil', isCorreta: true),
              Alternativa(texto: 'Modelo em V', isCorreta: false),
              Alternativa(texto: 'RUP', isCorreta: false),
            ],
          ),
        ],
      ),
    ],
  ),
];
 
