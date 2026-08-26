import 'package:flutter/material.dart';
import 'package:gabarito_plus/views/alunos/cadastro_aluno.dart';
import 'package:gabarito_plus/views/alunos/consulta_aluno.dart';
import 'package:gabarito_plus/views/turmas/cadastro_turma.dart';
import 'package:gabarito_plus/views/turmas/consulta_turma.dart';
import '../auth/profile_view.dart';

class DashboardAluno extends StatelessWidget {
  const DashboardAluno({super.key});

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Alunos', Icons.person),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMenuCard(
                  context,
                  'Consulta Aluno',
                  Icons.search,
                  Colors.blue,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ConsultaAluno()),
                  ),
                ),
                _buildMenuCard(
                  context,
                  'Cadastro de Aluno',
                  Icons.create,
                  Colors.orange,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CadastroAluno(title: "Cadastro de Aluno")),
                  ),
                )
              ],
            ),

            const SizedBox(height: 28),
            _DashedDivider(),
            const SizedBox(height: 28),

            _buildSectionTitle(context, 'Turmas', Icons.class_),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMenuCard(
                  context,
                  'Consulta de Turma',
                  Icons.search,
                  Colors.blue,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ConsultaTurma()),
                  ),
                ),
                _buildMenuCard(
                  context,
                  'Cadastro de Turma',
                  Icons.create,
                  Colors.orange,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CadastroTurma(title: "Cadastro de Turma")),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Título de cada seção, com ícone + texto
  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
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

// Widget simples de linha tracejada, já que o Flutter não tem isso nativo
class _DashedDivider extends StatelessWidget {
  const _DashedDivider({this.height = 1, this.color});

  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final larguraTotal = constraints.constrainWidth();
        const larguraTraco = 6.0;
        const espacamento = 4.0;
        final quantidadeTracos = (larguraTotal / (larguraTraco + espacamento)).floor();

        return Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(quantidadeTracos, (_) {
            return SizedBox(
              width: larguraTraco,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color ?? Colors.grey.shade400,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}