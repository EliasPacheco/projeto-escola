import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Coordenação'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collectionGroup('messages').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
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
              Map<String, dynamic> data = snapshot.data!.docs[index].data() as Map<String, dynamic>;

              // Extrai o nome do aluno do caminho do documento
              String nomeAluno = snapshot.data!.docs[index].reference.path.split('/').last;

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
                  ultimaMensagem.length > 50 ? '${ultimaMensagem.substring(0, 50)}...' : ultimaMensagem,
                ),
                onTap: () {
                  // Adicione aqui a ação ao clicar em um usuário
                },
              );
            },
          );
        },
      ),
    );
  }
}
