import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escola/alunos/ChatAlunoScreen.dart';
import 'package:flutter/material.dart';

class ChatHome extends StatefulWidget {
  final String matriculaCpf;
  final Map<String, dynamic>? alunoData;
  final String userType;

  const ChatHome({
    Key? key,
    required this.matriculaCpf,
    required this.alunoData,
    required this.userType,
  }) : super(key: key);

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  String _formatarHora(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String horaFormatada = '${dateTime.hour}:${dateTime.minute}';
    return horaFormatada;
  }

  void _showDeleteConfirmationDialog(String nomeAluno) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Excluir Conversa"),
          content: Text(
              "Tem certeza de que deseja excluir a conversa com $nomeAluno?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                _deleteConversation(nomeAluno);
                Navigator.of(context).pop();
              },
              child: Text("Excluir"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteConversation(String nomeAluno) async {
    try {
      await FirebaseFirestore.instance
          .collection(
              'messages') // Substitua 'suaColecao' pelo nome da sua coleção
          .doc(nomeAluno)
          .delete();

      // Atualize o estado ou faça qualquer outra coisa após a exclusão bem-sucedida
      print('Conversa com $nomeAluno excluída com sucesso.');
    } catch (e) {
      print("Erro ao excluir a conversa: $e");
      // Trate o erro conforme necessário
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat Coordenação',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collectionGroup('messages')
              .snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'Nenhuma mensagem encontrada.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;

                String nomeAluno =
                    snapshot.data!.docs[index].reference.path.split('/').last;

                List<dynamic> messages = data['messages'] ?? [];
                List<dynamic> respostas = data['respostas'] ?? [];

                List<dynamic> allMessages = [...messages, ...respostas];
                allMessages.sort((a, b) => (b['timestamp'] as Timestamp)
                    .compareTo(a['timestamp'] as Timestamp));

                String ultimaMensagem = '';
                if (allMessages.isNotEmpty) {
                  ultimaMensagem = allMessages.first['text'] ?? '';
                }

                bool ultimaMensagemDaResposta =
                    respostas.contains(allMessages.first);

                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  color: Colors.white,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(15),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(nomeAluno.isNotEmpty ? nomeAluno[0] : ''),
                    ),
                    title: Text(
                      nomeAluno,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ultimaMensagemDaResposta)
                          Text(
                            'Você: ${ultimaMensagem.length > 48 ? "${ultimaMensagem.substring(0, 48)}..." : ultimaMensagem}',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          )
                        else if (ultimaMensagem.isNotEmpty)
                          Text(
                            ultimaMensagem.length > 50
                                ? '${ultimaMensagem.substring(0, 50)}...'
                                : ultimaMensagem,
                            style: TextStyle(fontSize: 14),
                          )
                        else
                          Row(
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.grey,
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Text(
                                'Foto',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            _formatarHora(allMessages.first['timestamp']),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: GestureDetector(
                      onTap: () {
                        _showDeleteConfirmationDialog(nomeAluno);
                      },
                      child: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatAlunoScreen(
                            matriculaCpf: nomeAluno,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
