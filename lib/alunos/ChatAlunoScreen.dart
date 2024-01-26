import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChatAlunoScreen extends StatefulWidget {
  final String matriculaCpf;

  const ChatAlunoScreen({Key? key, required this.matriculaCpf})
      : super(key: key);

  @override
  _ChatAlunoScreenState createState() => _ChatAlunoScreenState();
}

class _ChatAlunoScreenState extends State<ChatAlunoScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  String extractFirstName(String fullName) {
    List<String> parts = fullName.split(' ');
    return parts.isNotEmpty ? parts[0] : fullName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('messages')
              .doc(widget.matriculaCpf)
              .snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Carregando...'); // ou algum valor padrão
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text('Chat com Aluno'); // ou algum valor padrão
            }

            var messages = snapshot.data!['messages'] ?? [];
            var lastMessage = messages.isNotEmpty ? messages.last : null;
            var sender =
                lastMessage != null && lastMessage['sender'] != 'Coordenação'
                    ? extractFirstName(lastMessage['sender'])
                    : 'Aluno';

            return Text('Chat com $sender');
          },
        ),
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .doc(widget.matriculaCpf)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Nenhuma mensagem encontrada para este aluno.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          var documentData = snapshot.data!.data() as Map<String, dynamic>;

          var messages = documentData['messages'] ?? [];
          var respostas = documentData['respostas'] ?? [];

          List<Map<String, dynamic>> combinedList = [];

          for (var message in messages) {
            combinedList.add({
              'sender': message['sender'],
              'text': message['text'],
              'isAlunoMessage': true,
              'timestamp': message['timestamp'],
            });
          }

          for (var resposta in respostas) {
            combinedList.add({
              'sender': resposta['sender'],
              'text': resposta['text'],
              'isAlunoMessage': false,
              'timestamp': resposta['timestamp'],
            });
          }

          combinedList.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

          WidgetsBinding.instance!.addPostFrameCallback((_) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          });

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: combinedList.length,
                  itemBuilder: (context, index) {
                    var message = combinedList[index];
                    return _buildMessageTile(
                      message['sender'],
                      message['text'],
                      message['isAlunoMessage'],
                      message['timestamp'],
                    );
                  },
                ),
              ),
              _buildMessageInput(),
            ],
          );
        },
      ),
    );
  }

  String extractFirstAndThirdName(String fullName) {
    List<String> parts = fullName.split(' ');

    if (parts.length >= 3) {
      return "${parts[0]} ${parts[2]}";
    } else if (parts.length == 2) {
      return "${parts[0]} ${parts[1]}";
    } else {
      return fullName;
    }
  }

  Widget _buildMessageTile(
      String sender, String text, bool isAlunoMessage, Timestamp timestamp) {
    String formattedSender =
        isAlunoMessage ? extractFirstAndThirdName(sender) : sender;

    DateTime messageTime = timestamp.toDate();

    return Align(
      alignment: isAlunoMessage ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isAlunoMessage
              ? Colors.white
              : Color(0xFFDCF8C6), // Cores dos balões de mensagem
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedSender,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isAlunoMessage ? Colors.black : Colors.green,
              ),
            ),
            SizedBox(height: 4),
            Text(
              text,
              style: TextStyle(color: Colors.black87),
            ),
            SizedBox(height: 4),
            Text(
              _formatTimestamp(messageTime),
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final formatter = DateFormat('HH:mm'); // Formato 'HH:mm' para hora e minuto
    return formatter.format(timestamp.toLocal());
  }

  Widget _buildMessageInput() {
    return IconTheme(
      data: IconThemeData(color: Colors.blue),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: _getImage,
            ),
            Flexible(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration.collapsed(
                  hintText: "Digite uma mensagem",
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendMessage();
                  }),
            ),
          ],
        ),
      ),
    );
  }

  File? _image;
  Future<void> _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _sendMessage() async {
    String messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      final matriculaCpf = widget.matriculaCpf;

      final docSnapshot = await FirebaseFirestore.instance
          .collection('messages')
          .doc(matriculaCpf)
          .get();

      if (docSnapshot.exists) {
        FirebaseFirestore.instance
            .collection('messages')
            .doc(matriculaCpf)
            .update({
          'respostas': FieldValue.arrayUnion([
            {
              'sender': 'Coordenação',
              'text': messageText,
              'timestamp': DateTime.now(),
            }
          ]),
        });
      } else {
        FirebaseFirestore.instance
            .collection('messages')
            .doc(matriculaCpf)
            .set({
          'respostas': [
            {
              'sender': 'Coordenação',
              'text': messageText,
              'timestamp': DateTime.now(),
            }
          ],
          'messages': [], // Adiciona a estrutura 'messages' ao documento
        });
      }

      _messageController.clear();
    }
  }
}
