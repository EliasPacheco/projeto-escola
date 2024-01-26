import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String matriculaCpf;
  final Map<String, dynamic>? alunoData;
  final String userType;

  const ChatScreen({
    Key? key,
    required this.matriculaCpf,
    required this.alunoData,
    required this.userType,
  }) : super(key: key);

  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  Set<String> selectedMessages = Set<String>();

  File? _image;

  late String conversationId;

  CollectionReference _messagesCollection =
      FirebaseFirestore.instance.collection('messages');

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    List<String> users = [
      widget.matriculaCpf,
    ]..sort();

    conversationId = widget.alunoData?['nome'] ?? '';
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController
        .dispose(); // Dispose do ScrollController para evitar vazamento de memória
    super.dispose();
  }

  void _handleSubmitted(String text) async {
    _textController.clear();
    DateTime now = DateTime.now();

    await _messagesCollection.doc(widget.alunoData?['nome']).set({
      'messages': FieldValue.arrayUnion([
        {
          'sender': widget.alunoData?['nome'],
          'text': text,
          'image': _image != null ? _image!.path : null,
          'timestamp': Timestamp.fromDate(now),
        },
      ]),
    }, SetOptions(merge: true));

    setState(() {
      _image = null;
    });
  }

  Future<void> _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _deleteMessage(int index, String documentId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Excluir Mensagem"),
          content: Text("Deseja realmente excluir esta mensagem?"),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedMessages.clear();
                });
                Navigator.of(context).pop(false);
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                selectedMessages.clear();
              },
              child: Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextComposer() {
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
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: InputDecoration.collapsed(
                  hintText: "Digite uma mensagem",
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isLoading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
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
      body: Column(
        children: <Widget>[
          Flexible(
            child: StreamBuilder(
              stream: _messagesCollection.doc(conversationId).snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  _isLoading = false;
                  return Center(
                    child: Text("Sem mensagens enviadas"),
                  );
                }

                var document = snapshot.data!;
                var messages = document['messages'] ?? [];
                var respostas = document['respostas'] ?? [];

                if (_isLoading) {
                  _isLoading = false;
                  // Adicionando um delay para permitir a renderização inicial antes de rolar para baixo
                  Future.delayed(Duration(milliseconds: 1), () {
                    _scrollController
                        .jumpTo(_scrollController.position.maxScrollExtent);
                  });
                }

                if (messages.isEmpty && respostas.isEmpty) {
                  return Center(
                    child: Text("Sem mensagens enviadas"),
                  );
                }

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

                combinedList
                    .sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

                return ListView.builder(
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
                );
              },
            ),
          ),
          Divider(height: 1.0),
          _buildTextComposer(),
        ],
      ),
    );
  }
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
    alignment: isAlunoMessage ? Alignment.centerRight : Alignment.centerLeft,
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
