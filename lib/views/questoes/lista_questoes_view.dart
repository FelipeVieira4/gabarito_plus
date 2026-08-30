import 'package:flutter/material.dart';
import 'package:gabarito_plus/views/questoes/detalhes_questoes_view.dart';
import '../../mocks/mock_assunto.dart';
import '../../models/questao.dart';
import 'cadastro_questao_view.dart';

class ListaQuestoesView extends StatefulWidget {
  const ListaQuestoesView({super.key});

  @override
  State<ListaQuestoesView> createState() => _ListaQuestoesViewState();
}

class _ListaQuestoesViewState extends State<ListaQuestoesView> {
  // 1. Variável original e a nova lista que sofrerá o filtro
  List<Questao> questoes = bancoAssuntosMock[0].questoes;
  List<Questao> questoesFiltradas = [];

  // 2. Inicia a tela preenchendo a lista filtrada com todas as questões
  @override
  void initState() {
    super.initState();
    questoesFiltradas = questoes;
  }

  // 3. Função que atualiza a lista conforme o usuário digita
  void _filtrarQuestoes(String textoBusca) {
    setState(() {
      if (textoBusca.isEmpty) {
        questoesFiltradas = questoes;
      } else {
        questoesFiltradas = questoes.where((questao) {
          final disciplina = questao.disciplina.toLowerCase();
          final assunto = questao.assunto.toLowerCase();
          final busca = textoBusca.toLowerCase();
          
          return disciplina.contains(busca) || assunto.contains(busca);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banco de Questões'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),

      // 4. Body vira uma Column para colocar o TextField em cima do ListView
      body: Column(
        children: [
          // BARRA DE PESQUISA
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filtrarQuestoes,
              decoration: InputDecoration(
                labelText: 'Filtrar por disciplina ou assunto...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          // O SEU LISTVIEW ORIGINAL (agora lendo 'questoesFiltradas')
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),        
              itemCount: questoesFiltradas.length,
              itemBuilder: (context, index) {
                final questao = questoesFiltradas[index];

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
          ),
        ],
      ),

      // 5. BOTÃO FLUTUANTE DE CADASTRO
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CadastroQuestaoView()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}