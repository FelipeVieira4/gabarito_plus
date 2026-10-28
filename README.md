# Gabarito Plus 📝

Aplicativo em **Flutter** para professores gerenciarem turmas, alunos, banco de questões e provas com correção automatizada por câmera — inspirado nas dores relatadas por professores que hoje usam soluções como GradePen e Prova Fácil.

## 💡 Motivação

Professores com carga horária alta enfrentam semanas com centenas de provas para corrigir manualmente, o que atrasa a devolutiva aos alunos. O **Gabarito Plus** propõe resolver isso permitindo:

- Cadastro de um banco de questões reutilizável, organizado por disciplina e assunto;
- Geração de provas com **embaralhamento** independente da ordem das questões e das alternativas, dificultando cola sem exigir provas totalmente diferentes;
- Geração de um **gabarito com QR Code** por versão da prova;
- **Correção via câmera** (fluxo de leitura do QR Code + folha de respostas), com conferência manual antes de salvar o resultado.

## ✨ Funcionalidades

### Autenticação
- Login de professor (`login_view.dart`)
- Cadastro de novo professor (`cadastro_professor_view.dart`)
- Perfil do usuário com logout (`profile_view.dart`)

### Dashboard
- Painel inicial com atalhos para todos os módulos (`dashboard_view.dart`)
- Submenu de Turmas & Alunos (`dashboard_alunos.dart`)

### Alunos
- Cadastro/edição de aluno, com status Ativo/Inativo (`cadastro_aluno.dart`)
- Consulta de alunos com busca por nome e filtro de ativos (`consulta_aluno.dart`)

### Turmas
- Cadastro/edição de turma, com vínculo de múltiplos alunos e status ativa/inativa (`cadastro_turma.dart`)
- Consulta de turmas com detalhamento expansível dos alunos vinculados (`consulta_turma.dart`)

### Disciplinas & Assuntos
- Consulta com busca por disciplina/assunto (`consulta_disciplinas.dart`)
- Cadastro rápido de disciplina e de assunto via modal (bottom sheet)

### Banco de Questões
- Cadastro/edição de questão com 4 alternativas e marcação da correta (`cadastro_questao.dart`)
- Consulta com filtros por disciplina/assunto e busca textual (`consulta_questoes.dart`)
- Tela de detalhes da questão, destacando a alternativa correta (`detalhes_questoes.dart`)

### Provas
- Configuração da prova: turma, disciplina, assunto, seleção de questões e opções de embaralhamento (`configuracao_prova.dart`)
- Visualização das versões embaralhadas geradas por aluno, com opção de regerar (`visualizacao_embaralhamento.dart`)
- Geração do gabarito em QR Code por versão da prova (`gabarito_qrcode.dart`); o QR contém só o código da versão, para que as respostas não fiquem expostas na folha do aluno
- Provas e versões salvas no Firestore pelo botão "Salvar provas" (`ProvaRepository`); depois de salvas, não é mais possível embaralhar de novo
- Código da versão no formato `K7Q2XM-03`: o id da prova (6 caracteres, sem `0 O 1 I L`) mais a posição do aluno na turma

### Correção
- Fluxo guiado em etapas — leitura do QR Code → leitura da folha de respostas → conferência das marcações → resultado (`camera_correcao.dart`)
- Modo simulado (`kModoSimulado`) para testar o fluxo sem câmera real
- "Digitar código da prova" busca o gabarito das provas salvas no Firestore; numa prova real a folha começa em branco e as respostas são marcadas na conferência. Os códigos de exemplo `ES2025A-001` a `-008` continuam funcionando no modo simulado
- Conferência editável das respostas lidas antes de salvar a correção
- Contador de provas corrigidas na sessão
- Correções salvas no Firestore (coleção `correcoes`); corrigir de novo a mesma versão substitui o resultado anterior
- Consulta das provas corrigidas com filtros por turma e prova, busca, ordenação e remoção (`consulta_provas_corrigidas.dart`)

## 🧱 Estrutura do projeto

```
lib/
├── models/         # Entidades de domínio (Aluno, Turma, Disciplina, Assunto, Questao, Prova, VersaoProva, Correcao, GabaritoLido...)
├── mocks/          # Dados simulados para desenvolvimento (alunos, turmas, disciplinas, leituras)
├── services/       # Regras de negócio (AlunoService, TurmaService, DisciplinasService, QuestoesService, CorrecaoService, CorrecaoRepository)
├── widgets/         # Componentes reutilizáveis (ex.: ResponsiveContainer)
└── views/
    ├── auth/         # Login, cadastro de professor, perfil
    ├── dashboard/    # Telas iniciais e menus
    ├── alunos/       # Cadastro e consulta de alunos
    ├── turmas/       # Cadastro e consulta de turmas
    ├── disciplinas/  # Consulta/cadastro de disciplinas e assuntos
    ├── questoes/     # Banco de questões
    ├── provas/       # Configuração, embaralhamento e gabarito
    └── correcao/     # Correção por câmera
```

> Observação: alunos, turmas, disciplinas, questões, provas e correções são salvos no Firestore. A leitura por câmera (QR e folha) ainda é simulada, e os exemplos do modo simulado vêm de **mocks** (`mock_leitura.dart`).

## 🔥 Estrutura do Firestore

Todas as coleções ficam na raiz do banco; o id de cada registro é o id do documento (não vai dentro dos campos). Referências entre coleções são guardadas como `xxxId`.

```
alunos/{alunoId}             nome, email, isAtivo, nomeBusca
turmas/{turmaId}             nomeTurma, ativa, alunosIds[]
disciplinas/{disciplinaId}   descricao, descricaoBusca
assuntos/{assuntoId}         nome, disciplinaId
questoes/{questaoId}         enunciado, alternativas[{texto, isCorreta}], disciplinaId, assuntoId

provas/{provaId}             titulo, turmaId, nomeTurma, assuntoId, nomeAssunto, questoesIds[],
                             embaralharQuestoes, embaralharAlternativas, criadaEm
└── versoes/{codigoVersao}   alunoId, nomeAluno,
                             questoes[{questaoId, enunciado, alternativas[], respostaCorreta}]

correcoes/{codigoVersao}     provaId, turmaId, alunoId, tituloProva, nomeTurma, nomeAluno,
                             respostasMarcadas[], respostasCorretas[], quantidadeAlternativas,
                             acertos, erros, emBranco, nota, dataHora
```

- **Versões guardam uma cópia da questão**, e não só o id: se a questão for editada depois, a prova já impressa (e o gabarito do QR Code) continua igual.
- **Uma versão por aluno** fica na subcoleção `versoes` da prova, em vez de um array no documento da prova, para não estourar o limite de 1 MB por documento em turmas grandes.
- **A correção usa o código da versão (lido no QR Code) como id**, então dá para verificar se a prova já foi corrigida com uma única leitura.
- **A correção copia nomes, nota e totais** para que a consulta de provas corrigidas monte a lista sem buscar em outras coleções. Questão em branco é gravada como `null` em `respostasMarcadas`.
- A conversão de/para o Firestore fica nos próprios models (`toMap()`, `fromMap()`, `fromFirestore()`), no mesmo padrão de `Aluno` e `Questao`.

### Teste de gravação no Firestore

`integration_test/firestore_gravacao_test.dart` grava uma prova, uma versão e uma correção no banco real, lê de volta e apaga tudo no fim (ids começando com `TESTE-`). Ele precisa de um **usuário do app** (criado pela tela de Cadastro de Professor ou em Authentication no Console), não da conta Google usada no Console. Use uma conta só para testes.

No PowerShell, coloque cada argumento entre aspas simples para que caracteres como `$` na senha não sejam alterados:

```powershell
flutter test integration_test/firestore_gravacao_test.dart -d windows '--dart-define=TEST_EMAIL=<email>' '--dart-define=TEST_PASSWORD=<senha>'
```

Ou crie um arquivo `.env.test.json` (já ignorado pelo git) com `{"TEST_EMAIL": "...", "TEST_PASSWORD": "..."}` e rode com `--dart-define-from-file=.env.test.json`. Sem credenciais, os testes são pulados. No Windows, o build com Firebase exige Visual Studio 2022 17.14 ou mais novo.

## 🎨 Design

Interface pensada para ser **responsiva** (mobile e desktop, com `LayoutBuilder` e breakpoints) e **minimalista**, priorizando poucos elementos por tela e fluxo lógico — conforme preferência relatada pelo cliente entrevistado.

## 🚀 Como executar

Pré-requisitos: [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado.

```bash
flutter pub get
flutter run
```

Dependências externas identificadas no código:
- `qr_flutter` — geração dos QR Codes do gabarito

## 🗺️ Roadmap (com base nos requisitos levantados)

**Essencial**
- [x] Geração e correção de provas de forma automatizada
- [ ] Leitura real de câmera (OCR/visão computacional) — hoje simulada via `kModoSimulado`

**Importante**
- [ ] Estatística de respostas por questão (qual alternativa foi mais marcada), para apoiar análise pedagógica

**Desejável / futuro**
- [ ] Importação de lista de alunos (ex.: planilha)
- [ ] Identificação individual do aluno na folha de resposta, mesmo com prova padronizada
- [ ] Exportação de relatório de notas em Excel
- [ ] Edição de layout da prova gerada (evitar questões cortadas entre páginas), exportando em `.doc`
- [ ] Persistência real (banco de dados) substituindo os mocks atuais

## 📌 Status

Protótipo funcional em Flutter com fluxo completo de UI e regras de negócio simuladas (mocks), cobrindo o ciclo: cadastro de conteúdo → montagem da prova → geração de gabarito → correção assistida por câmera.