# Gabarito Plus 📝

Aplicativo desenvolvido em **Flutter** para auxiliar professores no gerenciamento de turmas, alunos, disciplinas, banco de questões e provas, com correção assistida e armazenamento de dados no Firebase Firestore.

## 💡 Motivação

Professores com carga horária elevada enfrentam dificuldades para corrigir grandes quantidades de provas manualmente, o que pode atrasar a devolutiva aos alunos. O **Gabarito Plus** busca facilitar esse processo por meio de:

- Cadastro e organização de questões por disciplina e assunto;
- Geração de provas com embaralhamento independente das questões e alternativas;
- Geração de versões individuais das provas para os alunos;
- Criação de gabaritos com QR Code para identificar cada versão;
- Correção assistida, com consulta ao gabarito salvo e conferência manual das respostas;
- Armazenamento dos dados no Firebase Firestore.

## ✨ Funcionalidades

### Autenticação

- Login de professor;
- Cadastro de novos professores;
- Identificação do usuário autenticado;
- Perfil do usuário e opção de logout.

### Dashboard

- Painel inicial com acesso aos módulos do aplicativo;
- Atalhos para gerenciamento de turmas, alunos, disciplinas, questões, provas e correções;
- Exibição do nome do usuário autenticado.

### Alunos

- Cadastro e edição de alunos;
- Controle de status ativo/inativo;
- Consulta com busca por nome;
- Filtro de alunos ativos.

### Turmas

- Cadastro e edição de turmas;
- Vinculação de múltiplos alunos;
- Controle de status ativa/inativa;
- Consulta de turmas com detalhamento dos alunos vinculados.

### Disciplinas e assuntos

- Consulta de disciplinas e assuntos;
- Busca por nome;
- Cadastro de disciplinas e assuntos.

### Banco de questões

- Cadastro e edição de questões;
- Quatro alternativas por questão, com identificação da resposta correta;
- Consulta com filtros por disciplina e assunto;
- Busca textual;
- Visualização dos detalhes da questão e da alternativa correta.

### Provas

- Configuração da prova por turma, disciplina e assunto;
- Seleção das questões que farão parte da prova;
- Opções de embaralhamento das questões e alternativas;
- Geração e visualização de versões individuais para os alunos;
- Geração de QR Code para identificar cada versão;
- Salvamento das provas e versões no Firestore.

O QR Code identifica a versão da prova por meio de seu código, sem expor diretamente as respostas corretas.

Após o salvamento, as versões armazenadas são mantidas para preservar a correspondência entre a prova gerada e seu gabarito.

O código de cada versão segue o formato `K7Q2XM-03`, composto pelo identificador da prova e pela posição do aluno na turma.

### Correção de provas

- Digitação do código da versão para localizar o gabarito salvo no Firestore;
- Preenchimento manual das respostas do aluno;
- Conferência e edição das respostas antes de salvar;
- Cálculo de acertos, erros, questões em branco e nota;
- Contador de provas corrigidas durante a sessão;
- Salvamento das correções no Firestore;
- Substituição do resultado anterior quando a mesma versão é corrigida novamente;
- Consulta das provas corrigidas com filtros por turma e prova, busca, ordenação e remoção.

**Limitação atual:** a leitura automática do QR Code e da folha de respostas pela câmera ainda não está integrada. O fluxo atual utiliza a digitação do código da prova e o preenchimento manual das respostas.

### Testes

O projeto possui testes automatizados para validar regras de negócio, fluxos de correção e funcionalidades da interface. Os dados de teste são mantidos em fixtures dentro da pasta `test/helpers/`, separados do código de produção.

Também existe um teste de integração com o Firestore para verificar a gravação e a leitura de provas, versões e correções.

## 🧱 Estrutura do projeto

O código é organizado por funcionalidades, separando interface, dados, modelos e regras de negócio.

```text
lib/
└── features/
    ├── aluno/
    ├── turma/
    ├── disciplina/
    ├── professor/
    ├── dashboard/
    ├── geracao_prova/
    └── correcao_prova/

test/
├── helpers/
│   └── fixtures_correcao.dart
├── camera_correcao_test.dart
├── consulta_provas_corrigidas_test.dart
└── correcao_service_test.dart

integration_test/
└── firestore_gravacao_test.dart
```

Os diretórios de funcionalidades contêm os arquivos específicos de cada módulo, organizados conforme suas responsabilidades.

Os dados utilizados pela aplicação são persistidos no Firestore. Os dados de apoio aos testes ficam separados em `test/helpers/`, evitando dependências de mocks de produção.

## 🔥 Estrutura do Firestore

As coleções ficam na raiz do banco, e os identificadores dos registros são os IDs dos documentos. Os relacionamentos entre coleções são armazenados por meio de campos como `alunoId`, `turmaId` e `disciplinaId`.

```text
alunos/{alunoId}
  nome, email, isAtivo, nomeBusca

turmas/{turmaId}
  nomeTurma, ativa, alunosIds[]

disciplinas/{disciplinaId}
  descricao, descricaoBusca

assuntos/{assuntoId}
  nome, disciplinaId

questoes/{questaoId}
  enunciado, alternativas[{texto, isCorreta}],
  disciplinaId, assuntoId

provas/{provaId}
  titulo, turmaId, nomeTurma, assuntoId,
  nomeAssunto, questoesIds[],
  embaralharQuestoes, embaralharAlternativas,
  criadaEm

  versoes/{codigoVersao}
    alunoId, nomeAluno,
    questoes[{questaoId, enunciado,
    alternativas[], respostaCorreta}]

correcoes/{codigoVersao}
  provaId, turmaId, alunoId, tituloProva,
  nomeTurma, nomeAluno, respostasMarcadas[],
  respostasCorretas[], quantidadeAlternativas,
  acertos, erros, emBranco, nota, dataHora
```

### Decisões de implementação

- **Cópia das questões nas versões:** cada versão armazena os dados das questões utilizadas. Assim, alterações posteriores no banco de questões não modificam o conteúdo já gerado para aquela prova.
- **Subcoleção de versões:** as versões ficam na subcoleção `versoes` de cada prova, evitando concentrar todas elas em um único documento.
- **Identificação da correção:** o código da versão é utilizado como identificador do documento de correção, facilitando a consulta do resultado daquela versão.
- **Dados da correção:** nomes, nota, totais e respostas são armazenados no documento para facilitar a consulta dos resultados.
- **Questões em branco:** são representadas por `null` no campo `respostasMarcadas`.
- **Conversão dos dados:** os modelos implementam a conversão entre objetos Dart e dados do Firestore.

## 🧪 Teste de gravação no Firestore

O arquivo `integration_test/firestore_gravacao_test.dart` verifica a gravação e a leitura de uma prova, uma versão e uma correção no banco real, removendo os registros de teste ao final.

Para executá-lo, é necessário ter um usuário do aplicativo criado pela tela de Cadastro de Professor ou pelo Firebase Authentication. A conta utilizada para acessar o Console do Firebase não substitui automaticamente uma conta autenticada no aplicativo.

Recomenda-se utilizar uma conta exclusiva para testes.

No PowerShell do Windows, execute:

```powershell
flutter test integration_test/firestore_gravacao_test.dart -d windows '--dart-define=TEST_EMAIL=<email>' '--dart-define=TEST_PASSWORD=<senha>'
```

Substitua `<email>` e `<senha>` pelas credenciais da conta de teste.

Como alternativa, crie um arquivo `.env.test.json`, ignorado pelo Git, com o seguinte conteúdo:

```json
{
  "TEST_EMAIL": "seu-email",
  "TEST_PASSWORD": "sua-senha"
}
```

Depois, execute:

```powershell
flutter test integration_test/firestore_gravacao_test.dart -d windows --dart-define-from-file=.env.test.json
```

Sem as credenciais necessárias, os testes de integração são ignorados.

**Observação:** no Windows, a compilação do aplicativo com Firebase pode exigir o Visual Studio 2022, versão 17.14 ou superior.

## 🎨 Design

A interface prioriza uma experiência simples, organizada e responsiva, com adaptação para diferentes tamanhos de tela por meio de recursos como `LayoutBuilder` e breakpoints.

O objetivo é facilitar a navegação entre os módulos e reduzir a complexidade das tarefas realizadas pelo professor.

## 🚀 Como executar

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install);
- Dart SDK, disponibilizado com o Flutter;
- Configuração do Firebase para o projeto;
- Dependências do projeto instaladas.

### Instalação

Clone o repositório e acesse a pasta do projeto:

```bash
git clone <URL_DO_REPOSITORIO>
cd gabarito_plus
```

Instale as dependências:

```bash
flutter pub get
```

Execute o aplicativo:

```bash
flutter run
```

Para verificar problemas de análise estática:

```bash
flutter analyze
```

Para executar os testes automatizados:

```bash
flutter test
```

A configuração do Firebase deve estar disponível no ambiente antes de executar as funcionalidades que dependem de autenticação e persistência.

## 🗺️ Roadmap

### Essencial

- [x] Cadastro e gerenciamento de alunos, turmas e disciplinas;
- [x] Cadastro e consulta do banco de questões;
- [x] Geração de provas e versões individuais;
- [x] Geração de gabaritos com QR Code;
- [x] Persistência de provas, versões e correções no Firestore;
- [x] Correção assistida com digitação do código e marcação manual das respostas;
- [ ] Integração da câmera para leitura automática do QR Code e da folha de respostas.

### Importante

- [ ] Estatísticas de respostas por questão, identificando as alternativas mais selecionadas;
- [ ] Aprimoramento dos relatórios de desempenho dos alunos.

### Desejável / futuro

- [ ] Importação de listas de alunos por planilha;
- [ ] Identificação individual do aluno na folha de respostas;
- [ ] Exportação de relatórios de notas para Excel;
- [ ] Personalização do layout das provas geradas;
- [ ] Melhorias na distribuição das questões entre páginas durante a geração dos documentos.

## 📌 Status do projeto

Protótipo funcional desenvolvido em Flutter, com autenticação, gerenciamento de conteúdo, geração de provas, versões individuais e persistência de dados no Firebase Firestore.

O fluxo de correção permite consultar o gabarito de uma versão salva, preencher manualmente as respostas e registrar o resultado. A leitura automática por câmera ainda está pendente de integração.
