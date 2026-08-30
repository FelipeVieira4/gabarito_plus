import 'package:flutter/material.dart';
import 'package:gabarito_plus/views/questoes/detalhes_questoes_view.dart';
import '../../mocks/mock_assunto.dart';
import '../../models/questao.dart';

class ListaQuestoesView extends StatefulWidget {
  const ListaQuestoesView({super.key});

  @override
  State<ListaQuestoesView> createState() => _ListaQuestoesViewState();
}

class _ListaQuestoesViewState extends State<ListaQuestoesView> {
  List<Questao> questoes = bancoAssuntosMock[0].questoes;

@override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banco de Questões'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),

      body: ListView.builder(
        padding:const EdgeInsets.all(16.0),        
        itemCount: questoes.length,
        itemBuilder: (context, index) {
          final questao = questoes[index];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ListTile(
              title: Text(
                questao.enunciado,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            subtitle: Text('${questao.disciplina} - ${questao.assunto}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetalhesQuestaoView(questao: questao),
                ),
              );
            },
            ),
          );
        },
      ),
    );
  }
}