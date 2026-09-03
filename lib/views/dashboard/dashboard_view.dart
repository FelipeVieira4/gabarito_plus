import 'package:flutter/material.dart';
import 'package:gabarito_plus/views/dashboard/dashboard_alunos.dart';
import 'package:gabarito_plus/views/provas/configuracao_prova.dart';
import '../../mocks/mock_professor.dart';
import '../auth/profile_view.dart';
import '../questoes/consulta_questoes.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileView()),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final largura = constraints.maxWidth;

          // Breakpoints: mobile < 700, tablet 700–1100, desktop >= 1100
          final int crossAxisCount;
          final double aspectRatio;
          if (largura >= 1100) {
            crossAxisCount = 4;
            aspectRatio = 1.3;
          } else if (largura >= 700) {
            crossAxisCount = 3;
            aspectRatio = 1.2;
          } else {
            crossAxisCount = 2;
            aspectRatio = 1.0;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                // Evita que os cards fiquem gigantes/esticados em telas muito largas
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, ${usuarioMock.nome}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      usuarioMock.materias.join(' • '),
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 32),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: aspectRatio,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildMenuCard(
                          context,
                          'Turmas & Alunos',
                          Icons.people,
                          Colors.blue,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const DashboardAluno()),
                          ),
                        ),
                        _buildMenuCard(
                          context,
                          'Banco de Questões',
                          Icons.quiz,
                          Colors.orange,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ListaQuestoesView()),
                          ),
                        ),
                        _buildMenuCard(
                          context,
                          'Gerar Provas',
                          Icons.description,
                          Colors.green,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ConfiguracaoProva()),
                          ),
                        ),
                        _buildMenuCard(
                          context,
                          'Corrigir Provas',
                          Icons.camera_alt,
                          Colors.red,
                          () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}