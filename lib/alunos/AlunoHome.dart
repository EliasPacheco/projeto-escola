import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Alunos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AlunoHome(),
    );
  }
}

class AlunoHome extends StatefulWidget {
  @override
  _AlunoHomeState createState() => _AlunoHomeState();
}

class _AlunoHomeState extends State<AlunoHome> {
  List<String> alunos = [
    'João',
    'Maria',
    'Pedro',
    'Ana',
    'Carlos',
    'Bianca',
    'Rafael',
    'Julia',
  ];

  List<String> alunosFiltrados = [];

  @override
  void initState() {
    super.initState();
    alunosFiltrados.addAll(alunos);
  }

  void filtrarAlunos(String query) {
    setState(() {
      alunosFiltrados = alunos
          .where((aluno) => aluno.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Alunos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  onChanged: filtrarAlunos,
                  decoration: InputDecoration(
                    hintText: 'Pesquisar Alunos',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              elevation: 4.0,
              margin: EdgeInsets.zero,
              child: ListView.builder(
                itemCount: alunosFiltrados.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(alunosFiltrados[index]),
                    trailing: PopupMenuButton<String>(
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem<String>(
                            value: 'opcao1',
                            child: Text('Presença/Falta'),
                          ),
                          PopupMenuItem<String>(
                            value: 'opcao2',
                            child: Text('Boletim'),
                          ),
                        ];
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
