import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escola/alunos/AlunoHome.dart';
import 'package:escola/cards/Agendacards.dart';
import 'package:escola/cards/Formacard.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AgendaScreen extends StatefulWidget {
  final String matriculaCpf;
  final Map<String, dynamic>? alunoData;
  final String userType;
  final Map<String, dynamic>? professorData;

  AgendaScreen({
    Key? key,
    required this.matriculaCpf,
    this.alunoData,
    required this.userType,
    this.professorData,
  }) : super(key: key);

  @override
  _AgendaScreenState createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  String? serieAluno;
  late String selectedAno;
  bool _temConexaoInternet = true;
  Connectivity _connectivity = Connectivity();

  late Stream<List<Aluno>> alunosStream;

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

  @override
  void initState() {
    serieAluno = widget.alunoData?['serie'];
    super.initState();
    _verificarConexaoInternet();
    _monitorarConexao();
    // Verificar o tipo de usuário e, se for aluno, obter a série
    if (widget.userType == 'Aluno') {
      serieAluno = widget.alunoData?['serie'];
    }
    if (widget.userType == 'Professor' && widget.professorData != null) {
      // Verifica se 'series' não é nulo e não está vazio
      if (widget.professorData!['series'] != null &&
          (widget.professorData!['series'] as List).isNotEmpty) {
        selectedAno = widget.professorData!['series'][0];
      } else {
        // Defina um valor padrão caso não haja turmas disponíveis
        selectedAno = anos[0];
      }
    } else if (widget.userType == 'Coordenacao') {
      // Se for um usuário de Coordenação, inicialize selectedAno com o primeiro ano
      selectedAno = anos[0];
    }
  }

  void _monitorarConexao() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _temConexaoInternet = result != ConnectivityResult.none;
        if (_temConexaoInternet) {
          // Atualiza o stream com base no novo ano selecionado
          alunosStream = buscarAlunosStream(selectedAno);
        }
      });
    });
  }

  Future<void> _verificarConexaoInternet() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    setState(() {
      _temConexaoInternet = connectivityResult != ConnectivityResult.none;
    });
  }

  Stream<List<Aluno>> buscarAlunosStream(String selectedAno) {
    return FirebaseFirestore.instance
        .collection('alunos')
        .doc(selectedAno)
        .collection('alunos')
        .snapshots()
        .map((QuerySnapshot querySnapshot) {
      return querySnapshot.docs.map((DocumentSnapshot document) {
        return Aluno(
          documentId: document.id,
          nome: (document['nome'] ?? '').toString(),
          serie: (document['serie'] ?? '').toString(),
        );
      }).toList();
    });
  }

  void filtrarPorAno(String selectedAno) {
    setState(() {
      this.selectedAno = selectedAno;
      // Atualiza o stream com o novo ano selecionado
      alunosStream = buscarAlunosStream(selectedAno);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agenda escolar'),
        actions: [
          if (widget.userType == 'Coordenacao' ||
              widget.userType == 'Professor')
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: selectedAno,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedAno = newValue;
                    });

                    // Chama a função para filtrar os alunos com base no novo ano selecionado
                    filtrarPorAno(selectedAno);
                  }
                },
                items: (widget.userType == 'Professor')
                    ? [
                        ...widget.professorData!['series']
                            .map<DropdownMenuItem<String>>((serie) {
                          return DropdownMenuItem<String>(
                            value: serie as String,
                            child: Text(serie),
                          );
                        }),
                      ]
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
      body: _temConexaoInternet
          ? StreamBuilder<QuerySnapshot>(
              stream: (widget.userType == 'Aluno')
                  ? FirebaseFirestore.instance
                      .collection('agenda')
                      .doc(widget.alunoData?['turma'])
                      .collection('agenda')
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection('agenda')
                      .doc(selectedAno)
                      .collection('agenda')
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                List<DocumentSnapshot> documentos =
                    (snapshot.data as QuerySnapshot?)?.docs ?? [];
                if (documentos.isEmpty) {
                  return Center(
                    child: Text('Sem agenda'),
                  );
                }

                // Ordena os documentos por data
                documentos.sort((a, b) {
                  var dataA = a['data'] as String?;
                  var dataB = b['data'] as String?;
                  if (dataA != null && dataB != null) {
                    return dataA.compareTo(dataB);
                  } else {
                    return 0;
                  }
                });

                return ListView.builder(
                  itemCount: documentos.length,
                  itemBuilder: (context, index) {
                    if (index >= documentos.length) {
                      return Container();
                    }

                    var aviso = documentos[index];

                    return Card(
                      key: Key(aviso.id),
                      elevation: 2.0,
                      margin:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(8.0),
                        title: Text(
                          aviso['titulo'] ?? 'Sem Título',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              aviso['descricao'] ?? 'Sem Descrição',
                            ),
                            SizedBox(height: 8.0),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16.0),
                                SizedBox(width: 4.0),
                                Text(
                                  aviso['data'] ?? 'Sem Data',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 116, 115, 115),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.signal_wifi_off,
                    size: 50,
                    color: Colors.red,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Sem conexão com a Internet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
      floatingActionButton:
          widget.userType == 'Coordenacao' || widget.userType == 'Professor'
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AgendaCards(),
                      ),
                    );
                  },
                  child: Icon(Icons.add),
                )
              : null,
    );
  }
}
