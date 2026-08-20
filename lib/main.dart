import 'package:flutter/material.dart';

void main() {
  runApp(const GabaritoPlus());
}

class GabaritoPlus extends StatelessWidget {
  const GabaritoPlus({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gabarito Plus', // Título na Página

      theme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: const Color.fromARGB(255, 195, 28, 75),
        ),
      ),
      home: const PaginaInicial(title: 'GabaritoPlus - WIP'), // Página
      //cadastroProva: const PaginaInicial(title: 'GabaritoPlus - WIP'),  // Página
    );
  }
}

class PaginaInicial extends StatefulWidget {
  const PaginaInicial({super.key, required this.title});

  final String title;

  @override
  State<PaginaInicial> createState() => _PaginaInicialState();
}

class _PaginaInicialState extends State<PaginaInicial> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
