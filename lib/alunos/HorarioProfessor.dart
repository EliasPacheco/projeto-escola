import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HorarioProfessor extends StatefulWidget {
  final String matriculaCpf;
  final Map<String, dynamic>? alunoData;
  final String userType;
  final Map<String, dynamic>? professorData;

  HorarioProfessor({
    Key? key,
    required this.matriculaCpf,
    this.alunoData,
    required this.userType,
    this.professorData,
  }) : super(key: key);

  @override
  _HorarioProfessorState createState() => _HorarioProfessorState();
}

class _HorarioProfessorState extends State<HorarioProfessor> {
  late List<Aluno> alunos;
  List<String> turma = [
    'Maternal',
    'Infantil I',
    'Infantil II',
    '1º Ano',
    '2º Ano',
    '3º Ano',
    '4º Ano',
    '5º Ano',
    '6º Ano'
  ];

  late Stream<List<Map<String, dynamic>>> imagensStream;

  bool _temConexaoInternet = true;
  Connectivity _connectivity = Connectivity();

  bool isLoading = false;

  String? selectedTurma;
  String? selectedProfessor;
  String? turmaEscolhidaNome;
  List<String> professoresList =
      []; // Adicione esta lista para armazenar os nomes dos professores

  @override
  void initState() {
    super.initState();
    _verificarConexaoInternet();
    _monitorarConexao();
    imagensStream = buscarImagensStream();
  }

  void _monitorarConexao() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _temConexaoInternet = result != ConnectivityResult.none;
        if (_temConexaoInternet) {
          imagensStream = buscarImagensStream();
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

  Stream<List<Map<String, dynamic>>> buscarImagensStream() {
    return FirebaseFirestore.instance
        .collection('professores')
        .where('cpf', isEqualTo: widget.professorData?['cpf'])
        .snapshots()
        .asyncMap((QuerySnapshot querySnapshot) async {
      List<Map<String, dynamic>> professorDataList = [];

      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        data['docId'] = documentSnapshot.id;

        if (data.containsKey('imagemUrl')) {
          professorDataList.add(data);
        }
      }

      return professorDataList;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        isLoading = true;
        _uploadImageToStorage(File(pickedFile.path));
      } else {
        print('Nenhuma imagem selecionada.');
      }
    });
  }

  Future<void> _uploadImageToStorage(File imageFile) async {
    if (imageFile == null) {
      print('Nenhuma imagem selecionada.');
      return;
    }

    // Verifique se selectedProfessor não é nulo ou vazio antes de prosseguir
    if (selectedProfessor == null || selectedProfessor!.isEmpty ?? true) {
      print('Selecione um professor antes de enviar a imagem.');
      return;
    }

    try {
      // 1. Obtenha o UID do professor selecionado
      String professorName = selectedProfessor!;

      // Consulte a coleção "professores" para obter o UID
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('professores')
          .where('nome', isEqualTo: professorName)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('Professor não encontrado na coleção "professores".');
        return;
      }

      String professorUid = querySnapshot.docs.first.id;

      // 2. Crie a string com o nome imagemUrl dentro do UID do professor
      String imageUrlFieldName = 'imagemUrl'; // Nome do campo de imagemUrl

      // 3. Armazene a imagem no Storage
      String storagePath = 'professorhorario/$professorUid/1.jpg';
      Reference storageReference =
          FirebaseStorage.instance.ref().child(storagePath);

      TaskSnapshot taskSnapshot = await storageReference.putFile(imageFile);
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      // 4. Atualize o campo imagemUrl dentro do UID do professor
      await FirebaseFirestore.instance
          .collection('professores')
          .doc(professorUid)
          .update({
        imageUrlFieldName: imageUrl,
      });

      // 5. Atualize o stream após o envio da imagem
      setState(() {
        imagensStream = buscarImagensStream();
        isLoading = false; // Finaliza o indicador de carregamento

        Future.delayed(Duration(seconds: 5), () {
          setState(() {
            isLoading = false; // Finaliza o indicador de carregamento
          });
        });
      });
    } catch (e) {
      print('Erro ao enviar imagem: $e');
      setState(() {
        isLoading =
            false; // Finaliza o indicador de carregamento em caso de erro
      });
    }
  }

  void _openImage(List<Map<String, dynamic>> imageUrls) {
    print('Abrindo imagem');

    if (imageUrls.isNotEmpty) {
      Map<String, dynamic> imageData = imageUrls.first;
      String imageUrl = imageData['imagemUrl'];

      // Adicione o print para mostrar a turma

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoViewGallery.builder(
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
          ),
        ),
      ).then((value) {
        print('Fechou a galeria');
      });
    } else {
      // Tratar caso em que não há imagens
      print('Nenhuma imagem encontrada.');
    }
  }

  String getTurmaAluno(Map<String, dynamic> alunoData) {
    return alunoData['serie'] ??
        ''; // Altere isso conforme a estrutura real dos dados.
  }

  Future<void> _showTurmaDialog() async {
    String? chosenTurma;
    String? initialSelectedProfessor = selectedProfessor;
    bool showChooseImageButton =
        false; // Flag para controlar a visibilidade do botão "Escolher Imagem"

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Escolha a turma'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Escolha a turma'),
                DropdownButton<String>(
                  value: selectedTurma,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTurma = newValue!;
                      // Redefinir o professor selecionado ao mudar de turma
                      selectedProfessor = null;
                      showChooseImageButton =
                          false; // Oculta o botão ao mudar de turma
                    });
                  },
                  items: turma.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
                // Remova o TextFormField e adicione diretamente o código para mostrar os professores
                if (selectedTurma != null) ...{
                  Text('Professor:'),
                  FutureBuilder<List<String>>(
                    future: buscarProfessores(selectedTurma!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Erro ao carregar os professores');
                      } else {
                        List<String> professoresList = snapshot.data ?? [];
                        return Column(
                          children: [
                            DropdownButton<String>(
                              value: selectedProfessor,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedProfessor = newValue!;
                                  showChooseImageButton =
                                      true; // Mostra o botão ao escolher o professor
                                });
                              },
                              items:
                                  professoresList.map<DropdownMenuItem<String>>(
                                (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                },
                              ).toList(),
                            ),
                            if (showChooseImageButton) SizedBox(height: 16),
                            if (showChooseImageButton)
                              ElevatedButton(
                                onPressed: () async {
                                  // Fechar o diálogo de turma
                                  await _pickImage(); // Chamar o método para escolher a imagem
                                },
                                child: Text('Escolher Imagem'),
                              ),
                          ],
                        );
                      }
                    },
                  ),
                },
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  if (selectedTurma != null && selectedProfessor != null) {
                    setState(() {
                      turmaEscolhidaNome = selectedTurma;
                    });
                    _showSelectedOptionsDialog(
                        selectedTurma!, turmaEscolhidaNome!);

                    // Atualize o stream após a escolha da turma
                    setState(() {
                      imagensStream = buscarImagensStream();
                    });
                  }
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        });
      },
    );

    // Restaurar o valor original do professor selecionado
    selectedProfessor = initialSelectedProfessor;
  }

  Future<List<String>> buscarProfessores(String turma) async {
    CollectionReference professoresCollection =
        FirebaseFirestore.instance.collection('professores');

    // Realiza a consulta na coleção de professores
    QuerySnapshot professoresSnapshot =
        await professoresCollection.where('series', arrayContains: turma).get();

    // Obtém a lista de nomes dos professores, garantindo a exclusividade
    Set<String> professoresSet = Set<String>.from(professoresSnapshot.docs
        .map((professorDoc) => professorDoc['nome'] as String));

    return professoresSet.toList();
  }

  // Adicione o seguinte método para mostrar a opção selecionada
  Future<void> _showSelectedOptionsDialog(
      String turma, String turmaNome) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Opção Selecionada'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Turma selecionada: $turmaNome'), // Exibe o nome da turma
              Text('Professor selecionado: $turma'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print(
        'Tipo de usuário: ${widget.professorData ?? "Nenhum tipo de usuário"}');

    print("Horario Professor");

    String turmaAluno = getTurmaAluno(widget.alunoData ?? {});

    return Scaffold(
      appBar: AppBar(
        title: Text('Horários Professor'),
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
      body: Center(
          child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: imagensStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error,
                    size: 50,
                    color: Colors.red,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Erro ao carregar a imagem',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ],
              ),
            );
          } else {
            List<Map<String, dynamic>> imageUrls = snapshot.data ?? [];
            if (imageUrls.isNotEmpty) {
              String imageUrl = imageUrls.first['imagemUrl'];

              // Adicione esta linha para imprimir a imagemUrl no console
              print('Imagem URL: $imageUrl');

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: _temConexaoInternet,
                    child: Text(
                      'Clique na imagem para ampliar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      if (_temConexaoInternet) {
                        _openImage(
                          imageUrls,
                        );
                      } else {
                        // Adicione aqui qualquer ação que desejar quando não houver internet
                        // Por exemplo, exibir um snackbar ou realizar outra ação.
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_temConexaoInternet)
                          Image.network(
                            imageUrl,
                            height: 350,
                            width: 350,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 10),
                                    Text(
                                      '',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        if (_temConexaoInternet && isLoading)
                          CircularProgressIndicator(),
                        if (!_temConexaoInternet)
                          Column(
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
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              // Verificar a conexão com a Internet
              if (_temConexaoInternet) {
                return Center(
                  child: Text('Sem horário para mostrar.'),
                );
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.signal_wifi_off, // Ícone de Wi-Fi desativado
                        size: 50,
                        color: Colors
                            .red, // Cor do ícone, você pode ajustar conforme necessário
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Sem conexão com a Internet',
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    ],
                  ),
                );
              }
            }
          }
        },
      )),
      floatingActionButton: widget.userType == 'Coordenacao'
          ? FloatingActionButton(
              backgroundColor: Color(0xff2E71E8),
              foregroundColor: Colors.white,
              onPressed: () async {
                await _showTurmaDialog();
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}

class Aluno {
  final String documentId;
  final String nome;
  final String serie;

  Aluno({
    required this.documentId,
    required this.nome,
    required this.serie,
  });
}
