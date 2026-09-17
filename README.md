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
- Geração do gabarito em QR Code por versão da prova (`gabarito_qrcode.dart`)

### Correção
- Fluxo guiado em etapas — leitura do QR Code → leitura da folha de respostas → conferência das marcações → resultado (`camera_correcao.dart`)
- Modo simulado (`kModoSimulado`) para testar o fluxo sem câmera real
- Conferência editável das respostas lidas antes de salvar a correção
- Contador de provas corrigidas na sessão

## 🧱 Estrutura do projeto

```
lib/
├── models/         # Entidades de domínio (Aluno, Turma, Disciplina, Assunto, Questao, Prova, VersaoProva, Correcao, GabaritoLido...)
├── mocks/          # Dados simulados para desenvolvimento (alunos, turmas, disciplinas, leituras)
├── services/       # Regras de negócio (AlunoService, TurmaService, QuestoesService, CorrecaoService, CorrecaoRepository)
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

> Observação: as telas atuais utilizam **mocks** e serviços em memória (sem backend/persistência real ainda), o que é adequado para prototipagem e testes de fluxo.

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