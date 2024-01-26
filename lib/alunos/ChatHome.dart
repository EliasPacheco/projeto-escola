import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escola/alunos/ChatAlunoScreen.dart';
import 'package:escola/alunos/ChatScreen.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Coordenação'),
      ),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance.collectionGroup('messages').snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('Nenhuma mensagem encontrada.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              // Extrai o nome do aluno do caminho do documento
              String nomeAluno =
                  snapshot.data!.docs[index].reference.path.split('/').last;

              // Acesse as mensagens do aluno específico
              List<dynamic> messages = data['messages'] ?? [];

              // Obtenha a última mensagem
              String ultimaMensagem = '';
              if (messages.isNotEmpty) {
                ultimaMensagem = messages.last['text'] ?? '';
              }

              return ListTile(
                leading: CircleAvatar(
                  child: Text(nomeAluno.isNotEmpty ? nomeAluno[0] : ''),
                ),
                title: Text(nomeAluno),
                subtitle: Text(
                  ultimaMensagem.length > 50
                      ? '${ultimaMensagem.substring(0, 50)}...'
                      : ultimaMensagem,
                ),
                onTap: () {
                  // Ao clicar no aluno, navegue para a tela de chat do aluno
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatAlunoScreen(
                        matriculaCpf: nomeAluno,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
