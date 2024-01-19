import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escola/cards/Financeirocard.dart';
import 'package:escola/financeiro/FinanceiroScreen.dart';
import 'package:flutter/material.dart';
import 'package:escola/alunos/AlunoHome.dart';
import 'package:escola/alunos/AlunoHome.dart' as AlunoHomePackage;

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

class FinanceiroHome extends StatefulWidget {
  final String userType;
  final Map<String, dynamic>? professorData;

  const FinanceiroHome({
    Key? key,
    required this.userType,
    this.professorData,
  }) : super(key: key);

  @override
  _FinanceiroHomeState createState() => _FinanceiroHomeState();
}

class _FinanceiroHomeState extends State<FinanceiroHome> {
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
        return AlertDialog(
          title: Text('Enviar mensagem'),
          content: Text(
              'Deseja enviar uma mensagem para o $aluno para notificar de atraso na mensalidade?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Adicione lógica para tratar a presença do aluno aqui
              },
              child: Text('Enviar'),
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
    print(
        'Professor Data: ${widget.professorData ?? "Nenhum dado de professor"}');
    print('Tipo de usuário: ${widget.userType ?? "Nenhum tipo de usuário"}');

    return Scaffold(
      appBar: AppBar(
        title: Text('Financeiro'),
        actions: [
          if (widget.userType == 'Coordenacao' ||
              widget.userType == 'Professor')
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
                items: (widget.userType == 'Professor')
                    ? widget.professorData!['series']
                        .map<DropdownMenuItem<String>>((serie) {
                        return DropdownMenuItem<String>(
                          value: serie
                              as String, // Converter explicitamente para String
                          child: Text(serie),
                        );
                      }).toList()
                    : (widget.userType == 'Coordenacao')
                        ? anos.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList()
                        : [],
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
                    title: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(
                            Icons.attach_money,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                            width:
                                10.0), // Espaçamento entre o avatar e o texto
                        Text('${alunosFiltrados[index].nome}'),
                      ],
                    ),
                    trailing: widget.userType == 'Coordenacao'
                        ? PopupMenuButton<String>(
                            itemBuilder: (context) {
                              return [
                                PopupMenuItem<String>(
                                  value: 'opcao1',
                                  child: Text('Enviar mensagem'),
                                ),
                                PopupMenuItem<String>(
                                  value: 'opcao2',
                                  child: Text('Financeiro'),
                                ),
                              ];
                            },
                            onSelected: (String value) {
                              if (value == 'opcao1') {
                                exibirModalPresencaFalta(
                                    alunosFiltrados[index].nome);
                              } else if (value == 'opcao2') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FinanceiroScreen(
                                      userType: widget.userType,
                                      aluno: AlunoHomePackage.Aluno(
                                        nome: alunosFiltrados[index].nome,
                                        serie: alunosFiltrados[index].serie,
                                        documentId:
                                            alunosFiltrados[index].documentId,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          )
                        : null,
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
