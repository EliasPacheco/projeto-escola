import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'dart:async';

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

  bool _temConexaoInternet = true;
  Connectivity _connectivity = Connectivity();

  File? _image;
  bool _isImageUploading = false;

  @override
  void initState() {
    super.initState();
    _verificarConexaoInternet();
    _monitorarConexao();
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

  String extractFirstName(String fullName) {
    List<String> parts = fullName.split(' ');
    return parts.isNotEmpty ? parts[0] : fullName;
  }

  Widget _buildMessageInput() {
    return IconTheme(
      data: IconThemeData(color: Colors.blue),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.lightBlueAccent, // Cor de destaque na barra de entrada
          borderRadius: BorderRadius.circular(10), // Borda arredondada
        ),
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () async {
                _getImage();
                if (_image != null) {
                  await _showImagePreviewDialog();
                }
              },
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white, // Cor de fundo do campo de entrada
                  borderRadius: BorderRadius.circular(20), // Borda arredondada
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      vertical: 5), // Ajuste o padding vertical aqui
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration.collapsed(
                      hintText: "Digite uma mensagem",
                    ),
                    style: TextStyle(color: Colors.black), // Cor do texto
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _sendMessage();
                  }),
            ),
          ],
        ),
      ),
    );
  }

  bool _isDifferentDate(
      Timestamp currentTimestamp, Timestamp previousTimestamp) {
    DateTime currentDate = currentTimestamp.toDate();
    DateTime previousDate = previousTimestamp.toDate();
    return !isSameDay(currentDate, previousDate);
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
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
              return Text('Carregando...');
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text('Chat com Aluno');
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
      body: _temConexaoInternet
          ? StreamBuilder(
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

                var documentData =
                    snapshot.data!.data() as Map<String, dynamic>;

                var messages = documentData['messages'] ?? [];
                var respostas = documentData['respostas'] ?? [];

                List<Map<String, dynamic>> combinedList = [];

                for (var message in messages) {
                  var imageUrl = message['image'];
                  combinedList.add({
                    'sender': message['sender'],
                    'text': message['text'],
                    'isAlunoMessage': true,
                    'timestamp': message['timestamp'],
                    'imageUrl': imageUrl,
                  });
                }

                for (var resposta in respostas) {
                  var imageUrl = resposta['image'];
                  combinedList.add({
                    'sender': resposta['sender'],
                    'text': resposta['text'],
                    'isAlunoMessage': false,
                    'timestamp': resposta['timestamp'],
                    'imageUrl': imageUrl,
                  });
                }

                combinedList
                    .sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  Timer(Duration(milliseconds: 100), () {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  });
                });

                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                      ),
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('messages')
                            .doc(widget.matriculaCpf)
                            .snapshots(),
                        builder: (context,
                            AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }

                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return Text('Sem mensagens');
                          }

                          var messages = snapshot.data!['messages'] ?? [];
                          var firstMessageTimestamp = messages.isNotEmpty
                              ? messages.first['timestamp']
                              : null;

                          if (firstMessageTimestamp != null) {
                            DateTime firstMessageDate =
                                firstMessageTimestamp.toDate();
                            String formattedDate = DateFormat('dd/MM/yyyy')
                                .format(firstMessageDate);

                            return Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: combinedList.length,
                        itemBuilder: (context, index) {
                          var message = combinedList[index];

                          if (index > 0 &&
                              _isDifferentDate(message['timestamp'],
                                  combinedList[index - 1]['timestamp'])) {
                            DateTime messageDate =
                                message['timestamp'].toDate();
                            String formattedDate =
                                DateFormat('dd/MM/yyyy').format(messageDate);

                            return Column(
                              children: [
                                SizedBox(height: 8),
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                  ),
                                  child: Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                _buildMessageTile(
                                    message['sender'],
                                    message['text'],
                                    message['isAlunoMessage'],
                                    message['timestamp'],
                                    imageUrl: message['imageUrl']),
                              ],
                            );
                          } else {
                            return _buildMessageTile(
                                message['sender'],
                                message['text'],
                                message['isAlunoMessage'],
                                message['timestamp'],
                                imageUrl: message['imageUrl']);
                          }
                        },
                      ),
                    ),
                    _buildMessageInput(),
                  ],
                );
              },
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
      String sender, String text, bool isAlunoMessage, Timestamp timestamp,
      {String? imageUrl}) {
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
            if (text.isNotEmpty)
              Text(
                text,
                style: TextStyle(color: Colors.black87),
              ),
            if (imageUrl != null &&
                imageUrl.isNotEmpty) // Check if imageUrl is provided
              _buildImageWidget(imageUrl),
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
        appBar: AppBar(
          title: Text("Foto"),
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
            // do something on page change
          },
        ),
      );
    }));
  }

  _showImagePreviewDialog() async {
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
                      ? CircularProgressIndicator()
                      : _image != null
                          ? Image.file(_image!) // Display the selected image
                          : Container(), // If _image is null, display an empty container
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _image = null;
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
                          _sendMessage(); // Send the message with the image
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

  String _formatTimestamp(DateTime timestamp) {
    final formatter = DateFormat('HH:mm'); // Formato 'HH:mm' para hora e minuto
    return formatter.format(timestamp.toLocal());
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

  void _sendMessage() async {
    String messageText = _messageController.text.trim();
    if (messageText.isNotEmpty || _image != null) {
      final matriculaCpf = widget.matriculaCpf;

      // Verifica se há uma imagem pendente
      if (_image != null) {
        setState(() {
          _isImageUploading = true;
        });

        // Upload da imagem para o Firestore Storage
        final firebase_storage.Reference storageRef =
            firebase_storage.FirebaseStorage.instance.ref().child(
                'images/$matriculaCpf/${DateTime.now().millisecondsSinceEpoch}.jpg');

        await storageRef.putFile(_image!);

        // Obtém a URL da imagem no Firestore Storage
        String imageUrl = await storageRef.getDownloadURL();

        setState(() {
          _isImageUploading = false;
        });

        // Adicione a URL da imagem ao Firestore
        await FirebaseFirestore.instance
            .collection('messages')
            .doc(matriculaCpf)
            .update({
          'respostas': FieldValue.arrayUnion([
            {
              'sender': 'Coordenação',
              'text':
                  messageText, // Aqui, você pode optar por não incluir o texto se quiser enviar apenas a imagem
              'timestamp': DateTime.now(),
              'image': imageUrl,
            }
          ]),
        });

        // Limpa a imagem após o envio bem-sucedido
        setState(() {
          _image = null;
        });
      } else {
        // Se não houver imagem, envie apenas a mensagem de texto
        await FirebaseFirestore.instance
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
      }

      // Limpe o controlador de mensagens
      _messageController.clear();
    }
  }
}
