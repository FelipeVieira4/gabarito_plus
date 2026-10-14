import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gabarito_plus/firebase_options.dart';
import 'features/auth/ui/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
