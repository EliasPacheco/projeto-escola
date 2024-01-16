import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escola/alunos/MatriculaScreen.dart';
import 'package:flutter/material.dart';

class Aluno {
  final String documentId;
  final String nome;
  final String serie;

  Aluno({
    required this.documentId,
    required this.nome,
    required this.serie,
  });
}

class AlunoHome extends StatefulWidget {
  final String userType;

  // Adicione este construtor
  const AlunoHome({Key? key, required this.userType}) : super(key: key);

  @override
  _AlunoHomeState createState() => _AlunoHomeState();
}

class _AlunoHomeState extends State<AlunoHome> {
  late List<Aluno> alunos;
  List<String> anos = [
    'Maternal',
    'Infantil I',
    'Infantil II',
    '1º Ano',
    '2º Ano',
    '3º Ano',
    '4º Ano',
    '5º Ano',
    '6º Ano'
  ];
  String selectedAno = 'Maternal';
  List<Aluno> alunosFiltrados = [];

  @override
  void initState() {
    super.initState();
    // Chama a função para buscar os alunos ao inicializar o widget
    buscarAlunos();
  }

  // Função para buscar os dados da coleção "alunos" no Firestore
  Future<void> buscarAlunos() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('alunos') // Use a coleção principal 'alunos'
        .doc(selectedAno)
        .collection('alunos')
        .get();

    setState(() {
      alunos = querySnapshot.docs.map((DocumentSnapshot document) {
        return Aluno(
          documentId: document.id,
          nome: (document['nome'] ?? '').toString(),
          serie: (document['serie'] ?? '').toString(),
        );
      }).toList();

      alunosFiltrados = List.from(alunos);
    });
  }

  void filtrarAlunos(String query) {
    setState(() {
      alunosFiltrados = alunos
          .where((aluno) =>
              aluno.nome.toLowerCase().contains(query.toLowerCase()) &&
              aluno.serie == selectedAno)
          .toList();
    });
  }

  void resetFiltro() {
    setState(() {
      alunosFiltrados =
          alunos.where((aluno) => aluno.serie == selectedAno).toList();
    });
  }

  void filtrarPorAno(String selectedAno) async {
    // Atualiza o estado com o novo ano selecionado
    setState(() {
      this.selectedAno = selectedAno;
    });

    // Chama a função para buscar os alunos novamente com o novo ano
    await buscarAlunos();

    // Filtra os alunos com base no novo ano
    setState(() {
      alunosFiltrados =
          alunos.where((aluno) => aluno.serie == selectedAno).toList();
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
    String formattedDate =
        "${dataAtual.day.toString().padLeft(2, '0')}/${dataAtual.month.toString().padLeft(2, '0')}";
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
                });

                // Chama a função para filtrar os alunos com base no novo ano selecionado
                filtrarPorAno(selectedAno);
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
                  onChanged: (query) {
                    if (query.isEmpty) {
                      resetFiltro();
                    } else {
                      filtrarAlunos(query);
                    }
                  },
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
                    title: Text('${alunosFiltrados[index].nome}'),
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
                          exibirModalPresencaFalta(alunosFiltrados[index].nome);
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
      floatingActionButton: widget.userType == 'Coordenacao'
          ? FloatingActionButton(
              onPressed: () {
                // Adicione a lógica para adicionar novos avisos aqui
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MatriculaScreen(),
                  ),
                );
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}
