import 'package:escola/alunos/AlunoHome.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escola/cards/Agendacards.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
  String selectedAno = 'Maternal';

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

  Map<String, Color> cardColors = {};

  @override
  void initState() {
    serieAluno = widget.alunoData?['serie'];
    _loadCardColors();
    super.initState();
    // Verificar o tipo de usuário e, se for aluno, obter a série
    if (widget.userType == 'Aluno') {
      serieAluno = widget.alunoData?['serie'];
    }
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
    print('Aluno Data: ${widget.alunoData ?? "Nenhum dado de professor"}');
    print('Tipo de usuário: ${widget.userType ?? "Nenhum tipo de usuário"}');
    return Scaffold(
      appBar: AppBar(
        title: Text('Agenda Escolar'),
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
      body: FutureBuilder<QuerySnapshot>(
        future: (widget.userType == 'Aluno')
            ? FirebaseFirestore.instance
                .collection('agenda')
                .doc(widget.alunoData?['turma'])
                .collection('agenda')
                .get()
            : FirebaseFirestore.instance
                .collection('agenda')
                .doc(selectedAno)
                .collection('agenda')
                .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar os dados'),
            );
          }

          List<DocumentSnapshot> documentos = snapshot.data!.docs;

          print(
              'Número de documentos na coleção "Agendas": ${documentos.length}');

          if (documentos.isEmpty) {
            return Center(
              child: Text('Sem Agendas'),
            );
          }

          return ListView.builder(
            key: UniqueKey(),
            itemCount: documentos.length,
            itemBuilder: (context, index) {
              if (index >= documentos.length) {
                return Container();
              }

              var aviso = documentos[index];

              // Restante do código para exibir os comunicados
              return GestureDetector(
                onTap: () {
                  _showDialog(aviso);
                },
                child: Card(
                  key: Key(aviso.id),
                  elevation: 2.0,
                  margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  color: cardColors[aviso.id],
                  child: ListTile(
                    contentPadding: EdgeInsets.all(8.0),
                    title: Text(
                      aviso['titulo'] ?? 'Sem Título',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
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
                ),
              );
            },
          );
        },
      ),
      floatingActionButton:
          widget.userType == 'Coordenacao' || widget.userType == 'Professor'
              ? FloatingActionButton(
                  onPressed: () {
                    // Adicione a lógica para adicionar novos avisos aqui
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

  void _showDialog(DocumentSnapshot aviso) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sobre a Atividade'),
          content: Text(aviso['descricao'] ?? 'Sem Descrição'),
          actions: [
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    _updateCardColor(
                        aviso.id, Color.fromARGB(255, 224, 51, 39));
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Não Fiz',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 206, 64, 54),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _updateCardColor(
                        aviso.id, const Color.fromARGB(255, 92, 214, 96));
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Fiz',
                    style: TextStyle(
                      color: Colors.green,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _resetCardColor(aviso.id);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Em andamento',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _resetCardColor(String avisoId) {
    setState(() {
      cardColors.remove(avisoId);
      _saveCardColors();
    });
  }

  Future<void> _loadCardColors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String colorsString = prefs.getString('cardColors') ?? '{}';

    try {
      Map<String, dynamic> decodedColors = json.decode(colorsString);
      setState(() {
        cardColors = Map<String, Color>.from(
          decodedColors.map(
            (key, value) => MapEntry<String, Color>(
                key, Color(int.parse(value, radix: 16))),
          ),
        );
      });
    } catch (e) {
      print('Erro ao decodificar as cores dos cartões: $e');
    }
  }

  // Método para salvar as cores dos cartões no armazenamento local
  Future<void> _saveCardColors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String colorsString = json.encode(
      cardColors
          .map((key, value) => MapEntry(key, value.value.toRadixString(16))),
    );
    await prefs.setString('cardColors', colorsString);
  }

  // Método para atualizar a cor do card
  void _updateCardColor(String avisoId, Color color) {
    setState(() {
      cardColors[avisoId] = color;
      _saveCardColors(); // Salvar as cores no armazenamento local
    });
  }
}
