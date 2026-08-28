import 'package:gabarito_plus/models/assunto.dart';
import 'package:gabarito_plus/models/questao.dart';

final List<Assunto> bancoAssuntosMock = <Assunto>[
  Assunto(
    id: 'a1',
    nome: 'Estruturas de Dados',
    questoes: <Questao>[
      Questao(
        id: 'ed1',
        enunciado: 'Qual estrutura de dados segue o princípio LIFO (Last In, First Out)?',
        alternativas: ['Fila', 'Pilha', 'Lista encadeada', 'Árvore binária'],
        respostaCorreta: 1,
      ),
      Questao(
        id: 'ed2',
        enunciado: 'Qual estrutura de dados segue o princípio FIFO (First In, First Out)?',
        alternativas: ['Pilha', 'Fila', 'Tabela hash', 'Grafo'],
        respostaCorreta: 1,
      ),
      Questao(
        id: 'ed3',
        enunciado: 'Qual complexidade de tempo o algoritmo de busca binária possui em um array ordenado?',
        alternativas: ['O(n)', 'O(n²)', 'O(1)', 'O(log n)'],
        respostaCorreta: 3,
      ),
      Questao(
        id: 'ed4',
        enunciado: 'Qual é a complexidade de tempo para acessar um elemento de um array pelo seu índice?',
        alternativas: ['O(1)', 'O(log n)', 'O(n)', 'O(n log n)'],
        respostaCorreta: 0,
      ),
      Questao(
        id: 'ed5',
        enunciado: 'Em uma lista simplesmente encadeada, o que cada nó armazena?',
        alternativas: [
          'Apenas o valor do elemento',
          'O valor do elemento e a referência para o próximo nó',
          'O valor do elemento e as referências para o anterior e o próximo nó',
          'Somente ponteiros, sem valores',
        ],
        respostaCorreta: 1,
      ),
      Questao(
        id: 'ed6',
        enunciado: 'Qual estrutura de dados é mais adequada para verificar se os parênteses de uma expressão estão balanceados?',
        alternativas: ['Fila', 'Pilha', 'Árvore B', 'Lista ordenada'],
        respostaCorreta: 1,
      ),
      Questao(
        id: 'ed7',
        enunciado: 'Em uma tabela hash, o que caracteriza uma colisão?',
        alternativas: [
          'Quando a tabela fica completamente cheia',
          'Quando duas chaves diferentes são mapeadas para o mesmo índice',
          'Quando uma chave não é encontrada',
          'Quando a função de hash retorna um valor negativo',
        ],
        respostaCorreta: 1,
      ),
      Questao(
        id: 'ed8',
        enunciado: 'Qual percurso em árvore binária de busca visita os nós em ordem crescente de valor?',
        alternativas: ['Pré-ordem', 'Pós-ordem', 'Em ordem (in-order)', 'Em largura'],
        respostaCorreta: 2,
      ),
      Questao(
        id: 'ed9',
        enunciado: 'Qual estrutura de dados representa relações entre elementos por meio de vértices e arestas?',
        alternativas: ['Pilha', 'Fila', 'Grafo', 'Vetor'],
        respostaCorreta: 2,
      ),
      Questao(
        id: 'ed10',
        enunciado: 'Em uma fila, como são chamadas as operações de inserção e de remoção, respectivamente?',
        alternativas: [
          'push e pop',
          'enqueue e dequeue',
          'insert e delete',
          'add e peek',
        ],
        respostaCorreta: 1,
      ),
    ],
  ),
  Assunto(
    id: 'a2',
    nome: 'Banco de Dados',
    questoes: <Questao>[
      Questao(
        id: 'bd1',
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
        id: 'bd2',
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
        id: 'bd3',
        enunciado: 'Qual comando SQL é utilizado para recuperar dados de uma tabela?',
        alternativas: ['INSERT', 'SELECT', 'UPDATE', 'CREATE'],
        respostaCorreta: 1,
      ),
      Questao(
        id: 'bd4',
        enunciado: 'Qual cláusula SQL é usada para filtrar as linhas retornadas por uma consulta?',
        alternativas: ['ORDER BY', 'GROUP BY', 'WHERE', 'HAVING'],
        respostaCorreta: 2,
      ),
      Questao(
        id: 'bd5',
        enunciado: 'Qual comando SQL remove uma tabela inteira, incluindo sua estrutura?',
        alternativas: ['DELETE FROM tabela', 'DROP TABLE tabela', 'TRUNCATE tabela', 'REMOVE TABLE tabela'],
        respostaCorreta: 1,
      ),
      Questao(
        id: 'bd6',
        enunciado: 'Na sigla ACID, qual propriedade garante que uma transação seja executada por completo ou não seja executada?',
        alternativas: ['Atomicidade', 'Consistência', 'Isolamento', 'Durabilidade'],
        respostaCorreta: 0,
      ),
      Questao(
        id: 'bd7',
        enunciado: 'Qual tipo de JOIN retorna apenas as linhas que possuem correspondência em ambas as tabelas?',
        alternativas: ['LEFT JOIN', 'RIGHT JOIN', 'FULL OUTER JOIN', 'INNER JOIN'],
        respostaCorreta: 3,
      ),
      Questao(
        id: 'bd8',
        enunciado: 'Qual restrição (constraint) impede que uma coluna tenha valores duplicados?',
        alternativas: ['NOT NULL', 'UNIQUE', 'DEFAULT', 'CHECK'],
        respostaCorreta: 1,
      ),
      Questao(
        id: 'bd9',
        enunciado: 'Qual a principal finalidade de um índice em um banco de dados?',
        alternativas: [
          'Garantir a integridade referencial',
          'Acelerar a busca de registros',
          'Criptografar os dados armazenados',
          'Reduzir o tamanho do banco em disco',
        ],
        respostaCorreta: 1,
      ),
      Questao(
        id: 'bd10',
        enunciado: 'Qual cláusula é usada junto de funções de agregação para agrupar os resultados de uma consulta?',
        alternativas: ['WHERE', 'GROUP BY', 'ORDER BY', 'DISTINCT'],
        respostaCorreta: 1,
      ),
    ],
  ),
  Assunto(
    id: 'a3',
    nome: 'Redes de Computadores',
    questoes: <Questao>[
      Questao(
        id: 'rd1',
        enunciado: 'Qual protocolo é responsável por traduzir nomes de domínio em endereços IP?',
        alternativas: ['HTTP', 'DNS', 'FTP', 'SMTP'],
        respostaCorreta: 1,
      ),
      Questao(
        id: 'rd2',
        enunciado: 'Qual protocolo da camada de transporte é orientado à conexão e garante a entrega dos dados?',
        alternativas: ['UDP', 'IP', 'TCP', 'ICMP'],
        respostaCorreta: 2,
      ),
      Questao(
        id: 'rd3',
        enunciado: 'Qual é a porta padrão utilizada pelo protocolo HTTP?',
        alternativas: ['21', '25', '80', '443'],
        respostaCorreta: 2,
      ),
      Questao(
        id: 'rd4',
        enunciado: 'Como é chamado o endereço físico associado à interface de rede de um dispositivo?',
        alternativas: ['Endereço IP', 'Endereço MAC', 'Endereço de broadcast', 'Endereço de gateway'],
        respostaCorreta: 1,
      ),
      Questao(
        id: 'rd5',
        enunciado: 'Quantos bits possui um endereço IPv4?',
        alternativas: ['16', '32', '64', '128'],
        respostaCorreta: 1,
      ),
      Questao(
        id: 'rd6',
        enunciado: 'Qual dispositivo é responsável por encaminhar pacotes entre redes distintas?',
        alternativas: ['Switch', 'Hub', 'Roteador', 'Repetidor'],
        respostaCorreta: 2,
      ),
      Questao(
        id: 'rd7',
        enunciado: 'Qual camada do modelo OSI é responsável pelo roteamento dos pacotes?',
        alternativas: ['Camada de Enlace', 'Camada de Rede', 'Camada de Transporte', 'Camada de Aplicação'],
        respostaCorreta: 1,
      ),
      Questao(
        id: 'rd8',
        enunciado: 'Qual protocolo é utilizado para o envio de e-mails entre servidores?',
        alternativas: ['POP3', 'IMAP', 'SMTP', 'SNMP'],
        respostaCorreta: 2,
      ),
      Questao(
        id: 'rd9',
        enunciado: 'Qual protocolo atribui automaticamente endereços IP aos hosts de uma rede?',
        alternativas: ['DHCP', 'DNS', 'ARP', 'NAT'],
        respostaCorreta: 0,
      ),
      Questao(
        id: 'rd10',
        enunciado: 'O HTTPS adiciona uma camada de segurança ao HTTP por meio de qual protocolo?',
        alternativas: ['SSH', 'TLS/SSL', 'IPSec', 'Kerberos'],
        respostaCorreta: 1,
      ),
    ],
  ),
  Assunto(
    id: 'a4',
    nome: 'Engenharia de Software',
    questoes: <Questao>[
      Questao(
        id: 'es1',
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
        id: 'es2',
        enunciado: 'No método ágil Scrum, o que é uma Sprint?',
        alternativas: [
          'Um documento de requisitos do projeto',
          'Um ciclo curto e fixo de desenvolvimento',
          'O cargo do responsável pelo backlog',
          'Uma reunião diária de alinhamento',
        ],
        respostaCorreta: 1,
      ),
      Questao(
        id: 'es3',
        enunciado: 'Qual das opções abaixo é um exemplo de linguagem fortemente tipada?',
        alternativas: ['JavaScript', 'Python', 'Dart', 'PHP'],
        respostaCorreta: 2,
      ),
      Questao(
        id: 'es4',
        enunciado: 'Em orientação a objetos, o que descreve o conceito de encapsulamento?',
        alternativas: [
          'Ocultar os detalhes internos de uma classe e expor apenas uma interface',
          'Permitir que uma classe herde de várias outras',
          'Executar métodos de forma assíncrona',
          'Converter um objeto em texto',
        ],
        respostaCorreta: 0,
      ),
      Questao(
        id: 'es5',
        enunciado: 'No Scrum, qual papel é responsável por priorizar os itens do Product Backlog?',
        alternativas: ['Scrum Master', 'Product Owner', 'Time de Desenvolvimento', 'Stakeholder'],
        respostaCorreta: 1,
      ),
      Questao(
        id: 'es6',
        enunciado: 'Qual tipo de teste verifica o comportamento de uma unidade isolada do código, como um método?',
        alternativas: ['Teste de integração', 'Teste unitário', 'Teste de aceitação', 'Teste de carga'],
        respostaCorreta: 1,
      ),
      Questao(
        id: 'es7',
        enunciado: 'No acrônimo SOLID, a letra "S" representa qual princípio?',
        alternativas: [
          'Princípio da Responsabilidade Única',
          'Princípio Aberto/Fechado',
          'Princípio da Substituição de Liskov',
          'Princípio da Inversão de Dependência',
        ],
        respostaCorreta: 0,
      ),
      Questao(
        id: 'es8',
        enunciado: 'Qual das ferramentas abaixo é um sistema de controle de versão distribuído?',
        alternativas: ['Git', 'Jenkins', 'Maven', 'Jira'],
        respostaCorreta: 0,
      ),
      Questao(
        id: 'es9',
        enunciado: 'O que o polimorfismo permite em orientação a objetos?',
        alternativas: [
          'Que atributos sejam acessados diretamente de fora da classe',
          'Que um mesmo método se comporte de formas diferentes conforme o objeto',
          'Que uma classe não possa ser instanciada',
          'Que o código seja executado em paralelo',
        ],
        respostaCorreta: 1,
      ),
      Questao(
        id: 'es10',
        enunciado: 'Qual abordagem de desenvolvimento valoriza entregas incrementais e a adaptação a mudanças?',
        alternativas: ['Cascata (Waterfall)', 'Ágil', 'Modelo em V', 'RUP'],
        respostaCorreta: 1,
      ),
    ],
  ),
];
