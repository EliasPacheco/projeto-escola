import 'package:escola/alunos/MatriculaScreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alunos',
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

  List<String> anos = ['Maternal', 'Infantil I', 'Infantil II', '1º Ano', '2º Ano', '3º Ano', '4º Ano', '5º Ano', '6º Ano'];
  String selectedAno = 'Maternal';

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

  void filtrarPorAno(String selectedAno) {
    setState(() {
      // Lógica para filtrar os alunos pelo ano selecionado
      // Aqui você pode adicionar a lógica específica conforme necessário
    });
  }

  void exibirModalPresencaFalta(String aluno) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String dataAtual = _getDataAtual();
        return AlertDialog(
          title: Text('Presença/Falta $dataAtual'),
          content: Text('$aluno está presente na aula?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Falta'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Adicione lógica para tratar a presença do aluno aqui
              },
              child: Text('Presente'),
            ),
          ],
        );
      },
    );
  }

  String _getDataAtual() {
    DateTime dataAtual = DateTime.now();
    String formattedDate = "${dataAtual.day.toString().padLeft(2, '0')}/${dataAtual.month.toString().padLeft(2, '0')}";
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Alunos'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedAno,
              onChanged: (String? newValue) {
                setState(() {
                  selectedAno = newValue!;
                  filtrarPorAno(selectedAno);
                });
              },
              items: anos.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
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
                      onSelected: (String value) {
                        if (value == 'opcao1') {
                          exibirModalPresencaFalta(alunosFiltrados[index]);
                        } else if (value == 'opcao2') {
                          // Adicione lógica para a opção Boletim
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Adicione a lógica para adicionar novos avisos aqui
          Navigator.push(context, MaterialPageRoute(builder: (context) => MatriculaScreen()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
