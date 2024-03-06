import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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

  bool _temConexaoInternet = true;
  Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    _verificarConexaoInternet();
    _monitorarConexao();

    List<String> users = [
      widget.matriculaCpf,
    ]..sort();

    conversationId = widget.alunoData?['nome'] ?? '';
    _scrollController = ScrollController();
  }

  void _monitorarConexao() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _temConexaoInternet = result != ConnectivityResult.none;
        if (_temConexaoInternet) {
          // Atualiza o stream com base no novo ano selecionado
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

  File? _image;
  String imageUrl = "";
  bool _isImageUploading = false;

  late String conversationId;

  CollectionReference _messagesCollection =
      FirebaseFirestore.instance.collection('messages');

  late ScrollController _scrollController;

  @override
  void dispose() {
    _scrollController
        .dispose(); // Dispose do ScrollController para evitar vazamento de memória
    super.dispose();
  }

  void _handleSubmitted(String text) async {
    _textController.clear();
    DateTime now = DateTime.now();

    String imageUrl = "";

    if (_image != null) {
      setState(() {
        _isImageUploading = true;
      });

      // Upload da imagem para o Firestore Storage
      final firebase_storage.Reference storageRef = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(_image!);

      // Obtém a URL da imagem no Firestore Storage
      imageUrl = await storageRef.getDownloadURL();

      setState(() {
        _isImageUploading = false;
      });
    }

    await _messagesCollection.doc(widget.alunoData?['nome']).set({
      'messages': FieldValue.arrayUnion([
        {
          'sender': widget.alunoData?['nome'],
          'text': text,
          'image': imageUrl, // Salva a URL da imagem
          'timestamp': Timestamp.fromDate(now),
        },
      ]),
    }, SetOptions(merge: true));

    setState(() {
      _image = null;
    });
  }

  void _getImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _getImageFromSource(ImageSource.gallery);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library),
                    SizedBox(width: 8),
                    Text("Galeria"),
                  ],
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _getImageFromSource(ImageSource.camera);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  onPrimary: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt),
                    SizedBox(width: 8),
                    Text("Câmera"),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isDifferentDate(DateTime date1, DateTime date2) {
    return !isSameDay(date1, date2);
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildMessageTile(
      String sender, String text, bool isAlunoMessage, Timestamp timestamp,
      {String? imageUrl}) {
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
              ? Color(0xFFDCF8C6)
              : Colors.white, // Cores dos balões de mensagem
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
            if (text.isNotEmpty)
              Text(
                text,
                style: TextStyle(color: Colors.black87),
              ),
            if (imageUrl != null &&
                imageUrl
                    .isNotEmpty) // Verifique se a URL da imagem está presente
              _buildImageWidget(imageUrl),
            SizedBox(height: 4),
            Text(
              _formatTimestamp(timestamp.toDate()),
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    return GestureDetector(
      onTap: () {
        _showFullScreenImage(imageUrl);
      },
      child: FutureBuilder(
        future: precacheImage(NetworkImage(imageUrl), context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Image.network(
              imageUrl,
              width: 150, // ajuste conforme necessário
              height: 150, // ajuste conforme necessário
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  void _showFullScreenImage(String imageUrl) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Scaffold(
        body: PhotoViewGallery.builder(
          itemCount: 1,
          builder: (context, index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(imageUrl),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          },
          scrollPhysics: BouncingScrollPhysics(),
          backgroundDecoration: BoxDecoration(
            color: Colors.black,
          ),
          pageController: PageController(),
          onPageChanged: (index) {
            // faça algo na mudança de página, se necessário
          },
        ),
      );
    }));
  }

  Future<void> _getImageFromSource(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // Show full-screen image dialog only if the image is not null
      if (_image != null) {
        await _showImagePreviewDialog();
      }
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
              onPressed: () async {
                _getImage();
                if (_image != null) {
                  await _showImagePreviewDialog();
                }
              },
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

  Future<void> _showImagePreviewDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isImageUploading
                      ? CircularProgressIndicator() // Indicador de progresso circular
                      : Image.file(_image!), // Display the selected image
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _image = null; // Limpar a foto escolhida
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          onPrimary: Colors.white,
                        ),
                        child: Text("Cancelar"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _handleSubmitted(
                              ""); // Send the message with the image
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          onPrimary: Colors.white,
                        ),
                        child: Text("Enviar"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
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
      body: _temConexaoInternet
          ? Column(
              children: <Widget>[
                Flexible(
                    child: StreamBuilder(
                        stream:
                            _messagesCollection.doc(conversationId).snapshots(),
                        builder: (context,
                            AsyncSnapshot<DocumentSnapshot> snapshot) {
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
                          var documentData =
                              (document.data() as Map<String, dynamic>?) ?? {};
                          var messages = documentData['messages'] ?? [];
                          var respostas =
                              (documentData['respostas'] as List<dynamic>?) ??
                                  [];

                          if (_isLoading) {
                            _isLoading = false;
                            // Adicionando um delay para permitir a renderização inicial antes de rolar para baixo
                            Future.delayed(Duration(milliseconds: 1), () {
                              _scrollController.jumpTo(
                                  _scrollController.position.maxScrollExtent);
                            });
                          }

                          if (messages.isEmpty && respostas.isEmpty) {
                            return Center(
                              child: Text("Sem mensagens enviadas"),
                            );
                          }

                          List<Map<String, dynamic>> combinedList = [];

                          for (var message in messages) {
                            var imageUrl = message[
                                'image']; // Obtenha a URL da imagem, se existir

                            var messageData = {
                              'sender': message['sender'],
                              'text': message['text'],
                              'isAlunoMessage': true,
                              'timestamp': message['timestamp'],
                              'imageUrl':
                                  imageUrl, // Adicione a URL da imagem à lista, mesmo que seja nula ou vazia
                            };

                            combinedList.add(messageData);
                          }

                          for (var resposta in respostas) {
                            var imageUrl = resposta[
                                'image']; // Obtenha a URL da imagem, se existir

                            combinedList.add({
                              'sender': resposta['sender'],
                              'text': resposta['text'],
                              'isAlunoMessage': false,
                              'timestamp': resposta['timestamp'],
                              'imageUrl':
                                  imageUrl, // Adicione a URL da imagem à lista, mesmo que seja nula ou vazia
                            });
                          }

                          combinedList.sort((a, b) =>
                              a['timestamp'].compareTo(b['timestamp']));

                          return ListView.builder(
                            controller: _scrollController,
                            itemCount: combinedList.length,
                            itemBuilder: (context, index) {
                              var message = combinedList[index];
                              var timestamp = message['timestamp'] as Timestamp;

                              if (index == 0 ||
                                  _isDifferentDate(
                                      timestamp.toDate(),
                                      combinedList[index - 1]['timestamp']
                                          .toDate())) {
                                return Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                      ),
                                      child: Text(
                                        _formatDate(timestamp.toDate()),
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    _buildMessageTile(
                                      message['sender'],
                                      message['text'],
                                      message['isAlunoMessage'],
                                      timestamp,
                                      imageUrl: message['imageUrl'],
                                    ),
                                  ],
                                );
                              } else {
                                return _buildMessageTile(
                                  message['sender'],
                                  message['text'],
                                  message['isAlunoMessage'],
                                  timestamp,
                                  imageUrl: message['imageUrl'],
                                );
                              }
                            },
                          );
                        })),
                Divider(height: 1.0),
                _buildTextComposer(),
              ],
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
    );
  }

  // Rest of the code remains the same

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
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

String _formatTimestamp(DateTime timestamp) {
  final formatter = DateFormat('HH:mm'); // Formato 'HH:mm' para hora e minuto
  return formatter.format(timestamp.toLocal());
}
