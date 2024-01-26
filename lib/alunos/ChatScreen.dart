import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Adicione esta importação para formatar datas

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
  final List<ChatMessage> _messages = <ChatMessage>[];
  Set<String> selectedMessages = Set<String>();

  File? _image;

  late String conversationId;

  CollectionReference _messagesCollection =
      FirebaseFirestore.instance.collection('messages');

  @override
  void initState() {
    super.initState();
    // Crie uma identificação única para a conversa com base nos usuários
    List<String> users = [
      widget.matriculaCpf,
    ]..sort();

    conversationId = widget.alunoData?['nome'] ?? '';
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
    // Adicione este bloco de código para exibir um AlertDialog
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
                  selectedMessages.clear(); // Limpar seleção ao cancelar
                });
                Navigator.of(context).pop(false); // Cancelar
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirmar
                selectedMessages.clear();
              },
              child: Text("Confirmar"),
            ),
          ],
        );
      },
    );

    if (confirmDelete != null && confirmDelete) {
      // Remova a mensagem do Firestore usando o ID do documento
      await _messagesCollection
          .doc(widget.alunoData?['nome'])
          .collection('messages')
          .doc(documentId)
          .delete();

      // Remova a mensagem da lista local se o índice for válido
      if (index >= 0 && index < _messages.length) {
        setState(() {
          _messages.removeAt(index);
        });
      }
    }
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
                  _isLoading =
                      false; // Marque como carregado após o primeiro carregamento
                  return Center(
                    child: Text("Sem mensagens enviadas"),
                  );
                }

                var document = snapshot.data!;
                var messages = document['messages'] ?? [];

                if (_isLoading) {
                  _isLoading =
                      false; // Marque como carregado após o primeiro carregamento
                }

                if (messages.isEmpty) {
                  return Center(
                    child: Text("Sem mensagens enviadas"),
                  );
                }

                List<ChatMessage> messageWidgets = [];
                for (var message in messages) {
                  messageWidgets.add(
                    ChatMessage(
                      text: message['text'],
                      image: message['image'] != null
                          ? File(message['image'])
                          : null,
                      isCurrentUser: message['sender'] == widget.matriculaCpf,
                      timestamp: message['timestamp'],
                      isSelected: selectedMessages
                          .contains(message['timestamp'].toString()),
                      onDelete: () => _deleteMessage(messages.indexOf(message),
                          message['timestamp'].toString()),
                      documentId: message['timestamp'].toString(),
                      userName: message['sender'] == widget.matriculaCpf
                          ? 'Você'
                          : widget.alunoData?['nome'] ?? 'Other',
                      imageUrl: widget.alunoData?['imageUrl'] ??
                          '', // Passe a URL da imagem diretamente
                    ),
                  );
                }

                messageWidgets
                    .sort((a, b) => b.timestamp.compareTo(a.timestamp));

                return ListView(
                  padding: const EdgeInsets.all(8.0),
                  reverse: true,
                  children: messageWidgets,
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

class ChatMessage extends StatelessWidget {
  ChatMessage({
    required this.text,
    this.image,
    required this.isCurrentUser,
    required this.timestamp,
    this.isSelected = false,
    required this.onDelete,
    required this.documentId,
    required this.userName,
    required this.imageUrl,
  });

  final String text;
  final File? image;
  final bool isCurrentUser;
  final Timestamp timestamp;
  final bool isSelected;
  final VoidCallback onDelete;
  final String documentId;
  final String userName;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    // Formate a data e hora usando a biblioteca intl
    String formattedTime = DateFormat('HH:mm').format(timestamp.toDate());

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        border: isSelected ? Border.all(color: Colors.blue, width: 2.0) : null,
        borderRadius: BorderRadius.circular(10.0),
        color: isSelected ? Colors.blue.withOpacity(0.1) : null,
        boxShadow: [
          isSelected
              ? BoxShadow(
                  color: Colors.blue.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                )
              : BoxShadow(
                  color:
                      const Color.fromARGB(255, 255, 255, 255).withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: imageUrl.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      imageUrl,
                      width: 40.0,
                      height: 40.0,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        }
                      },
                    ),
                  )
                : CircleAvatar(
                    radius: 20.0,
                    backgroundColor: Colors.blue,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : '',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  isCurrentUser
                      ? 'Você'
                      : (userName?.split(' ')[0] ??
                          'Other'), // Use apenas o primeiro nome
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: isCurrentUser ? Colors.blue : Colors.black,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Text(
                  formattedTime, // Adicione a exibição do horário
                  style: TextStyle(fontSize: 12.0, color: Colors.grey),
                ),
                if (isSelected)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: onDelete,
                        color: Colors.red, // Cor do ícone de exclusão
                      ),
                      // Adicione outros ícones ou ações conforme necessário
                    ],
                  ),
                if (image != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8.0),
                    child: Image.file(
                      image!,
                      width: 150.0,
                      height: 150.0,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
