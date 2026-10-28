// Grava provas, versões e correções no Firestore de verdade e confere a leitura.
//
// As credenciais vêm por --dart-define e nunca devem ser escritas aqui:
//   fvm flutter test integration_test/firestore_gravacao_test.dart -d windows \
//     --dart-define=TEST_EMAIL=<email> --dart-define=TEST_PASSWORD=<senha>
//
// Para usar o emulador local no lugar do banco real, acrescente
//   --dart-define=USE_EMULATOR=true
//
// Os documentos gravados têm id começando com TESTE- e são apagados no fim.
// Se o teste for interrompido no meio, apague-os pelo Console.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabarito_plus/features/aluno/data/aluno.dart';
import 'package:gabarito_plus/features/auth/service/auth_service.dart';
import 'package:gabarito_plus/features/correcao_prova/services/correcao_repository.dart';
import 'package:gabarito_plus/features/disciplina/data/assunto.dart';
import 'package:gabarito_plus/features/geracao_prova/data/correcao.dart';
import 'package:gabarito_plus/features/geracao_prova/data/embaralhador.dart';
import 'package:gabarito_plus/features/geracao_prova/data/prova.dart';
import 'package:gabarito_plus/features/geracao_prova/data/versao_prova.dart';
import 'package:gabarito_plus/features/geracao_prova/service/prova_repository.dart';
import 'package:gabarito_plus/features/questoes/data/alternativa.dart';
import 'package:gabarito_plus/features/questoes/data/questao.dart';
import 'package:gabarito_plus/features/turma/data/turma.dart';
import 'package:gabarito_plus/firebase_options.dart';
import 'package:integration_test/integration_test.dart';

const _email = String.fromEnvironment('TEST_EMAIL');
const _senha = String.fromEnvironment('TEST_PASSWORD');
const _usarEmulador = bool.fromEnvironment('USE_EMULATOR');

const _semCredenciais = _email == '' || _senha == '';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FirebaseFirestore db;
  final codigo = 'TESTE-${DateTime.now().millisecondsSinceEpoch}';
  final gravados = <DocumentReference>[];

  setUpAll(() async {
    if (_semCredenciais) return;

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (_usarEmulador) {
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    }

    // Login direto (sem o AuthService) para não perder a mensagem original do
    // Firebase: no Windows quase todo erro de login chega como unknown-error.
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email,
        password: _senha,
      );
    } on FirebaseAuthException catch (e) {
      fail('Login falhou para "$_email" '
          '(senha com ${_senha.length} caracteres): ${e.code} - ${e.message}');
    }
    db = FirebaseFirestore.instance;
  });

  tearDownAll(() async {
    if (_semCredenciais) return;

    for (final ref in gravados) {
      await ref.delete();
    }
    await AuthService().logout();
  });

  final aluno = Aluno(
    id: '$codigo-ALUNO',
    nome: 'Aluno de Teste',
    email: '',
    isAtivo: true,
  );

  final questao = Questao(
    id: '$codigo-QUESTAO',
    enunciado: 'Quanto é 2 + 2?',
    alternativas: [
      Alternativa(texto: '3', isCorreta: false),
      Alternativa(texto: '4', isCorreta: true),
    ],
  );

  testWidgets(
    'grava e lê uma prova com a versão do aluno',
    skip: _semCredenciais,
    (tester) async {
      final prova = Prova(
        id: codigo,
        titulo: 'Prova de Teste',
        turma: Turma(
          id: '$codigo-TURMA',
          nomeTurma: 'Turma de Teste',
          listaAlunos: [aluno],
          ativa: true,
        ),
        assunto: Assunto(id: '$codigo-ASSUNTO', nome: 'Soma', questoes: [questao]),
        questoes: [questao],
        embaralharQuestoes: false,
        embaralharAlternativas: true,
      );

      final versao = VersaoProva(
        codigo: '$codigo-V1',
        aluno: aluno,
        questoes: [
          QuestaoEmbaralhada(
            questao: questao,
            alternativas: ['4', '3'],
            respostaCorreta: 0,
          ),
        ],
      );

      final provaRef = db.collection('provas').doc(prova.id);
      final versaoRef = provaRef.collection('versoes').doc(versao.codigo);
      // a versão vem antes na lista para ser apagada antes da prova
      gravados.addAll([versaoRef, provaRef]);

      await provaRef.set(prova.toMap());
      await versaoRef.set(versao.toMap());

      final provaLida = (await provaRef.get()).data()!;
      expect(provaLida['titulo'], 'Prova de Teste');
      expect(provaLida['nomeTurma'], 'Turma de Teste');
      expect(provaLida['questoesIds'], [questao.id]);
      expect(provaLida['criadaEm'], isA<Timestamp>());

      final versaoLida = VersaoProva.fromFirestore(await versaoRef.get());
      expect(versaoLida.codigo, versao.codigo);
      expect(versaoLida.aluno.nome, 'Aluno de Teste');
      expect(versaoLida.questoes.single.alternativas, ['4', '3']);
      expect(versaoLida.questoes.single.respostaCorreta, 0);
    },
  );

  testWidgets(
    'grava e lê uma correção',
    skip: _semCredenciais,
    (tester) async {
      final correcao = Correcao(
        codigoVersao: '$codigo-V1',
        provaId: codigo,
        turmaId: '$codigo-TURMA',
        alunoId: aluno.id,
        tituloProva: 'Prova de Teste',
        nomeTurma: 'Turma de Teste',
        nomeAluno: aluno.nome,
        respostas: [
          RespostaMarcada(numeroQuestao: 1, indiceMarcado: 0, indiceCorreto: 0),
          RespostaMarcada(numeroQuestao: 2, indiceMarcado: null, indiceCorreto: 1),
        ],
        quantidadeAlternativas: 4,
        dataHora: DateTime(2026, 10, 25, 10, 0),
      );

      final ref = db.collection('correcoes').doc(correcao.codigoVersao);
      gravados.add(ref);

      await ref.set(correcao.toMap());

      final lida = Correcao.fromFirestore(await ref.get());
      expect(lida.codigoVersao, correcao.codigoVersao);
      expect(lida.provaId, codigo);
      expect(lida.nomeAluno, 'Aluno de Teste');
      expect(lida.acertos, 1);
      expect(lida.emBranco, 1);
      expect(lida.nota, 5.0);
      expect(lida.dataHora, DateTime(2026, 10, 25, 10, 0));
    },
  );

  testWidgets(
    'repositório salva, encontra, sobrescreve e remove uma correção',
    skip: _semCredenciais,
    (tester) async {
      final repositorio = CorrecaoRepositoryFirestore();
      final codigoRepo = '$codigo-REPO';

      Correcao correcaoCom(int? marcada) => Correcao(
            codigoVersao: codigoRepo,
            tituloProva: 'Prova de Teste',
            nomeTurma: 'Turma de Teste',
            nomeAluno: aluno.nome,
            respostas: [
              RespostaMarcada(
                numeroQuestao: 1,
                indiceMarcado: marcada,
                indiceCorreto: 0,
              ),
            ],
            quantidadeAlternativas: 4,
            dataHora: DateTime(2026, 10, 26, 9, 0),
          );

      // registrado para o tearDownAll apagar mesmo se algo falhar no meio
      gravados.add(db.collection('correcoes').doc(codigoRepo));

      expect(await repositorio.jaCorrigida(codigoRepo), isFalse);

      await repositorio.salvar(correcaoCom(1));
      expect(await repositorio.jaCorrigida(codigoRepo), isTrue);
      expect((await repositorio.obterPorCodigo(codigoRepo))!.nota, 0.0);

      final todas = await repositorio.obterTodas();
      expect(todas.where((c) => c.codigoVersao == codigoRepo), hasLength(1));

      // corrigir de novo substitui a correção, sem criar outra
      await repositorio.salvar(correcaoCom(0));
      expect((await repositorio.obterPorCodigo(codigoRepo))!.nota, 10.0);
      final depois = await repositorio.obterTodas();
      expect(depois.where((c) => c.codigoVersao == codigoRepo), hasLength(1));

      await repositorio.remover(codigoRepo);
      expect(await repositorio.jaCorrigida(codigoRepo), isFalse);
    },
  );

  testWidgets(
    'repositório salva a prova com as versões e encontra o gabarito',
    skip: _semCredenciais,
    (tester) async {
      final repositorio = ProvaRepositoryFirestore();
      // o código da versão é "<id da prova>-NN", então o id não pode ter hífen
      final provaId = 'TESTE${gerarIdProva()}';

      final prova = Prova(
        id: provaId,
        titulo: 'Prova de Teste',
        turma: Turma(
          id: '$codigo-TURMA',
          nomeTurma: 'Turma de Teste',
          listaAlunos: [
            aluno,
            Aluno(id: '$codigo-ALUNO2', nome: 'Outro Aluno', email: '', isAtivo: true),
          ],
          ativa: true,
        ),
        assunto: Assunto(id: '$codigo-ASSUNTO', nome: 'Soma', questoes: [questao]),
        questoes: [questao],
        embaralharQuestoes: false,
        embaralharAlternativas: false,
      );
      final versoes = Embaralhador.gerarVersoes(prova);

      final provaRef = db.collection('provas').doc(provaId);
      gravados.addAll([
        for (final v in versoes) provaRef.collection('versoes').doc(v.codigo),
        provaRef,
      ]);

      await repositorio.salvar(prova, versoes);

      final gabarito = await repositorio.buscarGabarito('$provaId-02');
      expect(gabarito, isNotNull);
      expect(gabarito!.provaId, provaId);
      expect(gabarito.turmaId, '$codigo-TURMA');
      expect(gabarito.alunoId, '$codigo-ALUNO2');
      expect(gabarito.nomeAluno, 'Outro Aluno');
      // a correta de "Quanto é 2 + 2?" é a segunda alternativa ("4")
      expect(gabarito.respostasCorretas, [1]);

      expect(await repositorio.buscarGabarito('$provaId-99'), isNull);
      await expectLater(
        repositorio.salvar(prova, versoes),
        throwsStateError,
      );
    },
  );
}
