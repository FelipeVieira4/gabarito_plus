import 'package:flutter/material.dart';
import 'views/auth/login_view.dart';

void main() {
  runApp(const GabaritoPlus());
}

class GabaritoPlus extends StatelessWidget {
  const GabaritoPlus({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gabarito Plus',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginView(),
    );
  }
}
