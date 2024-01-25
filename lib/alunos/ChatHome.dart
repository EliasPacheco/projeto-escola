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

          // Cria um mapa para armazenar as mensagens agrupadas pelo nome do usuário
          Map<String, String> userLastMessage = {};

          snapshot.data!.docs.forEach((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            String nome = data['nome'] ?? ''; // Trata o valor nulo
            String mensagem = data['text'] ?? ''; // Trata o valor nulo

            // Atualiza a última mensagem para o nome do usuário no mapa
            userLastMessage[nome] = mensagem;
          });

          return ListView.builder(
            itemCount: userLastMessage.length,
            itemBuilder: (context, index) {
              String nomeUsuario = userLastMessage.keys.elementAt(index);
              String ultimaMensagem = userLastMessage[nomeUsuario]!;

              return ListTile(
                leading: CircleAvatar(
                  child: Text(nomeUsuario.isNotEmpty ? nomeUsuario[0] : ''), // Trata o valor nulo
                ),
                title: Text(nomeUsuario),
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

void main() {
  runApp(MaterialApp(
    home: ChatHome(),
  ));
}
