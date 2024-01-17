import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escola/cards/Agendacards.dart';
import 'package:escola/cards/Formacard.dart';
import 'package:flutter/material.dart';

class AgendaScreen extends StatefulWidget {
  final String matriculaCpf;
  final Map<String, dynamic>? alunoData;
  final String userType;

  AgendaScreen({
    Key? key,
    required this.matriculaCpf,
    this.alunoData,
    required this.userType,
  }) : super(key: key);

  @override
  _AgendaScreenState createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  String? serieAluno;

  @override
  void initState() {
    serieAluno = widget.alunoData?['serie'];
    super.initState();
    // Verificar o tipo de usuário e, se for aluno, obter a série
    if (widget.userType == 'Aluno') {
      serieAluno = widget.alunoData?['serie'];
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Aluno Data: ${widget.alunoData ?? "Nenhum dado de professor"}');
    print('Tipo de usuário: ${widget.userType ?? "Nenhum tipo de usuário"}');
    return Scaffold(
      appBar: AppBar(
        title: Text('Agenda Escolar'),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('agenda')
              .doc(widget.alunoData?['turma'])
              .collection('agenda')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
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
              itemCount: documentos.length,
              itemBuilder: (context, index) {
                var aviso = documentos[index];

                // Verificar se o campo 'turma' existe no caminho do documento
                var turmaAgenda = aviso.reference.parent?.parent?.id;
                if (turmaAgenda == null) {
                  print('Agenda sem turma ou caminho inválido: $aviso');
                  return Container(); // Ou qualquer outro tratamento que desejar
                }

                // Verificar se o aluno pertence à mesma turma do Agenda
                if (widget.alunoData?['turma'] == turmaAgenda) {
                  print('Agenda exibido para o aluno: $aviso');
                  return Card(
                    elevation: 2.0,
                    margin:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(8.0),
                      title: Text(
                        aviso['titulo'] ?? 'Sem Título',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(aviso['descricao'] ?? 'Sem Descrição'),
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
                } else {
                  print('Agenda não exibido para o aluno: $aviso');
                  return Container();
                }
              },
            );
          }),
      floatingActionButton: widget.userType == 'Coordenacao'
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
}
