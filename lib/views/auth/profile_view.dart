import 'package:flutter/material.dart';
import '../../mocks/mock_professor.dart';
import 'login_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 24),
            _buildInfoRow('Nome', usuarioMock.nome),
            _buildInfoRow('E-mail', usuarioMock.email),
            _buildInfoRow('Departamento', usuarioMock.departamento),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginView()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sair da Conta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          const Divider(),
        ],
      ),
    );
  }
}
