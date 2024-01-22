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
  final bool pagou;

  Aluno({
    required this.documentId,
    required this.nome,
    required this.serie,
    required this.pagou,
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
    mesAno = _getDataAtual();
    buscarAlunos();
  }

  late String mesAno;

  Future<void> buscarAlunos() async {
    mesAno = _getDataAtual();

    FirebaseFirestore.instance
        .collection('alunos')
        .doc(selectedAno)
        .collection('alunos')
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      setState(() {
        alunos = querySnapshot.docs.map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;

          if (data.containsKey('financeiro')) {
            List<Map<String, dynamic>> financeiroData =
                List<Map<String, dynamic>>.from(data['financeiro']);

            bool pagouAluno = financeiroData.any((element) {
              String mesAnoAluno = element['mesAno'] ?? '';
              return mesAnoAluno == mesAno && (element['pagou'] ?? false);
            });

            return Aluno(
              documentId: document.id,
              nome: (data['nome'] ?? '').toString(),
              serie: (data['serie'] ?? '').toString(),
              pagou: pagouAluno,
            );
          } else {
            return Aluno(
              documentId: document.id,
              nome: (data['nome'] ?? '').toString(),
              serie: (data['serie'] ?? '').toString(),
              pagou: false,
            );
          }
        }).toList();

        alunosFiltrados = List.from(alunos);
      });
    });
  }

  String _getDataAtual() {
    DateTime dataAtual = DateTime.now();
    String formattedDate =
        "${dataAtual.month.toString().padLeft(2, '0')}/${dataAtual.year.toString()}";
    return formattedDate;
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
    setState(() {
      this.selectedAno = selectedAno;
    });

    await buscarAlunos();

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
              },
              child: Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    alunosFiltrados.sort((a, b) => a.nome.compareTo(b.nome));
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

                  filtrarPorAno(selectedAno);
                },
                items: (widget.userType == 'Professor')
                    ? widget.professorData!['series']
                        .map<DropdownMenuItem<String>>((serie) {
                        return DropdownMenuItem<String>(
                          value: serie as String,
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
                          backgroundColor: (alunosFiltrados[index].pagou)
                              ? Colors.green
                              : Colors.red,
                          child: Icon(
                            (alunosFiltrados[index].pagou)
                                ? Icons.check_circle
                                : Icons.error,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
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
