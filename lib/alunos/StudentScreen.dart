import 'package:escola/Login.dart';
import 'package:escola/alunos/AlunoHome.dart';
import 'package:escola/alunos/BoletimScreen.dart';
import 'package:escola/financeiro/FinanceiroScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentScreen extends StatefulWidget {
  final String matriculaCpf;
  final Map<String, dynamic>? alunoData;
  final String userType;

  const StudentScreen({
    Key? key,
    required this.matriculaCpf,
    required this.userType,
    this.alunoData,
  }) : super(key: key);

  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  late String nome;
  late String serie;
  late String dataNascimento;
  late String matricula;
  String? _imageUrl;

  bool _isLoadingImage = false;
  bool _isImageLoading = false;

  late ImagePicker _imagePicker;
  PickedFile? _pickedFile;

  // Firestore reference
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Stream<DocumentSnapshot> _studentStream;

  void _signOut(BuildContext context) async {
    try {
      // Navegue de volta à tela de login removendo todas as rotas empilhadas
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
        (route) => false,
      );
    } catch (e) {
      print('Erro ao sair da conta: $e');
      // Trate o erro, mostre uma mensagem, etc.
    }
  }

  @override
  void initState() {
    super.initState();
    nome = widget.alunoData?['nome'] ?? 'Nome não disponível';
    serie = widget.alunoData?['serie'] ?? 'Série não disponível';
    dataNascimento = widget.alunoData?['dataNascimento'] ??
        'Data de nascimento não disponível';
    matricula = widget.alunoData?['matricula'] ?? 'Matrícula não disponível';
    _imagePicker = ImagePicker();
    _imageUrl = widget.alunoData?['imageUrl'];

    // Configure o stream para ouvir as alterações no documento do aluno
    String turma = widget.alunoData?['turma'] ?? 'OutraTurma';
    String uid = widget.alunoData?['uid'] ?? '';

    try {
      _studentStream = _firestore
          .collection('alunos')
          .doc(turma)
          .collection('alunos')
          .doc(uid) // Use o UID como o identificador do documento
          .snapshots();
    } catch (error) {
      print('Erro ao configurar o stream: $error');
    }
  }

  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  // Função para atualizar o documento do Firestore com o URL da imagem
  Future<void> _updateImageUrl(String imageUrl) async {
    try {
      print('Updating Firestore with image URL: $imageUrl');

      // Obtenha as informações do aluno
      String nome = widget.alunoData?['nome'] ?? '';
      String serie = widget.alunoData?['serie'] ?? '';
      String dataNascimento = widget.alunoData?['dataNascimento'] ?? '';
      String matricula = widget.alunoData?['matricula'] ?? '';

      // Obtenha a turma do aluno
      String turma = widget.alunoData?['turma'] ?? 'OutraTurma';

      // Construa a referência para a coleção de alunos na turma
      CollectionReference alunosRef =
          _firestore.collection('alunos/$turma/alunos');

      // Faça uma consulta para encontrar documentos com informações iguais às do usuário
      QuerySnapshot querySnapshot = await alunosRef
          .where('nome', isEqualTo: nome)
          .where('serie', isEqualTo: serie)
          .where('dataNascimento', isEqualTo: dataNascimento)
          .where('matricula', isEqualTo: matricula)
          .get();

      // Atualize a URL real da imagem em cada documento encontrado
      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        await documentSnapshot.reference.update({
          'imageUrl': imageUrl,
        });
      }
    } catch (erro) {
      print('Erro ao atualizar URL da imagem: $erro');
    }
  }

// Função para fazer o upload da imagem para o Firebase Storage
  Future<void> _uploadImageToStorage(File imageFile) async {
    try {
      setState(() {
        _isLoadingImage = true;
      });

      // Obtain the class of the student
      String turma = widget.alunoData?['turma'] ?? 'OutraTurma';

      // Construa o caminho do arquivo no Firebase Storage com extensão .jpg
      String storagePath = 'alunos/$turma/${nome}_image.jpg';

      // Remova caracteres especiais do caminho (opcional)
      storagePath = storagePath.replaceAll(' ', '_');

      print('Uploading image to storage: $storagePath');

      // Create a reference to the file in Firebase Storage
      Reference storageRef = _firebaseStorage.ref().child(storagePath);

      // Upload the file to Firebase Storage
      UploadTask uploadTask = storageRef.putFile(imageFile);

      // Wait for the upload to complete
      await uploadTask.whenComplete(() {});

      // Obtain the download URL of the newly uploaded file
      String imageUrl = await storageRef.getDownloadURL();

      print('Image uploaded successfully. URL: $imageUrl');

      // Update Firestore with the image URL
      await _updateImageUrl(imageUrl);

      // Atualize a interface do usuário para exibir a imagem carregada
      setState(() {
        _pickedFile = PickedFile(imageFile.path);
        _isLoadingImage = false;
      });
    } catch (error) {
      print('Error uploading image to Storage: $error');
      setState(() {
        _isLoadingImage = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      PickedFile? pickedFile =
          await _imagePicker.getImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _pickedFile = pickedFile;
          _imageUrl = null;
        });

        // Faça o upload da imagem para o Firebase Storage
        await _uploadImageToStorage(File(pickedFile.path));
      }
    } catch (error) {
      print('Erro ao escolher a imagem: $error');
    }
  }

  bool _hasImage() {
    return _pickedFile != null || _imageUrl != null;
  }

  @override
  Widget build(BuildContext context) {
    print('Aluno Data: ${widget.alunoData ?? "Nenhum dado de aluno"}');
    String primeiroNome = nome.split(' ')[0];
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    'Perfil do $primeiroNome',
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.exit_to_app),
                color: Colors.red,
                iconSize: 30,
                onPressed: () {
                  _signOut(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _studentStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Use o widget Center para centralizar o CircularProgressIndicator
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.data() == null) {
            return Text('Erro ao carregar dados do aluno');
          }

          Map<String, dynamic>? alunoData =
              snapshot.data!.data() as Map<String, dynamic>?;

          // Verifica se a URL da imagem foi atualizada
          String? imageUrl = alunoData?['imageUrl'];
          if (imageUrl != null && imageUrl != _imageUrl) {
            // Adie a chamada do setState para o próximo frame usando Future.microtask
            Future.microtask(() {
              // Atualize as variáveis de estado com os novos dados
              setState(() {
                nome = alunoData?['nome'] ?? 'Nome não disponível';
                serie = alunoData?['serie'] ?? 'Série não disponível';
                dataNascimento = alunoData?['dataNascimento'] ??
                    'Data de nascimento não disponível';
                matricula =
                    alunoData?['matricula'] ?? 'Matrícula não disponível';
                _imageUrl = imageUrl;
              });
            });
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.grey,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (!_hasImage())
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Colors.white,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Clique aqui para escolher uma foto',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        if (!_hasImage() && _isImageLoading)
                          CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        if (_hasImage())
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              if (_pickedFile == null && _imageUrl != null)
                                FutureBuilder(
                                  future: _loadNetworkImage(_imageUrl!),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      return ClipOval(
                                        child: snapshot.data as Widget,
                                      );
                                    } else if (snapshot.hasError) {
                                      print(
                                          'Erro ao carregar a imagem: ${snapshot.error}');
                                      return Icon(
                                        Icons.error_outline,
                                        size: 40,
                                        color: Colors.white,
                                      );
                                    } else {
                                      return SizedBox();
                                    }
                                  },
                                ),
                              if (_pickedFile != null)
                                ClipOval(
                                  child: Image.file(
                                    File(_pickedFile!.path),
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                buildStudentInfo('Nome:', nome, Icons.person),
                buildStudentInfo('Série:', serie, Icons.school),
                buildStudentInfo('Data de Nascimento:', dataNascimento,
                    Icons.calendar_today),
                buildStudentInfo(
                    'Matrícula:', matricula, Icons.confirmation_number),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FinanceiroScreen(
                          userType: widget.userType,
                          aluno: Aluno(
                            nome: widget.alunoData?['nome'],
                            serie: widget.alunoData?['serie'],
                            documentId: widget.alunoData?['uid'],
                          ),
                        ),
                      ),
                    );
                  },
                  child: Text('Ir para Financeiro'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BoletimScreen(
                          userType: widget.userType,
                          alunoData: widget.alunoData,
                          aluno: Aluno(
                            nome: widget.alunoData?['nome'],
                            serie: widget.alunoData?['serie'],
                            documentId: widget.alunoData?['uid'],
                          ),
                        ),
                      ),
                    );
                  },
                  child: Text('Ir para Boletim'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

// Nova função para carregar imagens da rede com tratamento de erros
  Future<Widget> _loadNetworkImage(String imageUrl) async {
    try {
      return Image.network(
        imageUrl,
        width: 200,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Erro ao carregar a imagem da rede: $error');
          return Icon(
            Icons.error_outline,
            size: 40,
            color: Colors.white,
          );
        },
      );
    } catch (error) {
      print('Erro ao carregar a imagem da rede: $error');
      return Icon(
        Icons.error_outline,
        size: 40,
        color: Colors.white,
      );
    }
  }

  Widget buildStudentInfo(String label, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, size: 30),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 17),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 15),
          ),
        ],
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
    );
  }
}
