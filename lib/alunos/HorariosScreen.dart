import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HorariosScreen extends StatefulWidget {
  final String matriculaCpf;
  final Map<String, dynamic>? alunoData;
  final String userType;
  final Map<String, dynamic>? professorData;

  HorariosScreen({
    Key? key,
    required this.matriculaCpf,
    this.alunoData,
    required this.userType,
    this.professorData,
  }) : super(key: key);

  @override
  _HorariosScreenState createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
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
  String selectedAno = 'Maternal';

  late Stream<List<Map<String, dynamic>>> imagensStream;

  bool _temConexaoInternet = true;
  Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    _verificarConexaoInternet();
    _monitorarConexao(); // Adicione esta linha para monitorar a conexão
    imagensStream = buscarImagensStream(selectedAno);
  }

  // Adicione este método para monitorar a conexão
  void _monitorarConexao() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _temConexaoInternet = result != ConnectivityResult.none;
        if (_temConexaoInternet) {
          imagensStream = buscarImagensStream(selectedAno);
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

  Stream<List<Map<String, dynamic>>> buscarImagensStream(String selectedAno) {
    if (widget.userType == 'Coordenacao') {
      // Se o tipo de usuário for 'Coordenacao', consulta todos os documentos
      return FirebaseFirestore.instance
          .collection('horario')
          .where(FieldPath.documentId, isEqualTo: selectedAno)
          .snapshots()
          .map((QuerySnapshot querySnapshot) {
        List<Map<String, dynamic>> dataList = [];
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          data['docId'] = document.id; // Adiciona o ID do documento aos dados
          dataList.add(data);
        }

        if (dataList.isNotEmpty) {
          print('Dados da coleção "horario" para $selectedAno: $dataList');
          return dataList;
        } else {
          print('Nenhuma imagemUrl encontrada na turma $selectedAno.');
          return [];
        }
      });
    } else if (widget.userType == 'Aluno') {
      // Se o tipo de usuário for 'Aluno', consulta apenas o documento da turma do aluno
      String turmaAluno = getTurmaAluno(widget.alunoData ?? {});
      return FirebaseFirestore.instance
          .collection('horario')
          .where(FieldPath.documentId, isEqualTo: turmaAluno)
          .snapshots()
          .map((QuerySnapshot querySnapshot) {
        List<Map<String, dynamic>> dataList = [];
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          data['docId'] = document.id; // Adiciona o ID do documento aos dados
          dataList.add(data);
        }

        if (dataList.isNotEmpty) {
          print('Dados da coleção "horario" para $turmaAluno: $dataList');
          return dataList;
        } else {
          print('Nenhuma imagemUrl encontrada na turma $turmaAluno.');
          return [];
        }
      });
    } else {
      // Outros tipos de usuários
      return FirebaseFirestore.instance
          .collection('horario')
          .where(FieldPath.documentId, isEqualTo: selectedAno)
          .snapshots()
          .map((QuerySnapshot querySnapshot) {
        List<Map<String, dynamic>> dataList = [];
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          data['docId'] = document.id; // Adiciona o ID do documento aos dados
          dataList.add(data);
        }

        if (dataList.isNotEmpty) {
          print('Dados da coleção "horario" para $selectedAno: $dataList');
          return dataList;
        } else {
          print('Nenhuma imagemUrl encontrada na turma $selectedAno.');
          return [];
        }
      });
    }
  }

  bool isLoading = false;

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

    String storagePath = 'horario/$selectedAno/1.jpg';

    Reference storageReference =
        FirebaseStorage.instance.ref().child(storagePath);

    try {
      TaskSnapshot taskSnapshot = await storageReference.putFile(imageFile);
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      CollectionReference horarioCollection =
          FirebaseFirestore.instance.collection('horario');

      await horarioCollection.doc(selectedAno).set({
        'imagemUrl': imageUrl,
      });

      print('Imagem enviada com sucesso para o $selectedAno');

      // Agora, atualize o stream após o envio da imagem
      setState(() {
        imagensStream = buscarImagensStream(selectedAno);
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

  void _openImage(
      List<Map<String, dynamic>> imageUrls, String turmaSelecionada) {
    print('Abrindo imagem');

    if (imageUrls.isNotEmpty) {
      Map<String, dynamic> imageData = imageUrls.first;
      String imageUrl = imageData['imagemUrl'];

      // Adicione o print para mostrar a turma
      print('Turma da imagem: $turmaSelecionada');

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

  void filtrarPorAno(String selectedAno) {
    setState(() {
      this.selectedAno = selectedAno;
      imagensStream = buscarImagensStream(selectedAno);
    });

    if (widget.userType == 'Aluno') {
      // Se o usuário for do tipo 'Aluno', verifique se a turma da imagem é a mesma do aluno
      imagensStream.first.then((imageUrls) {
        bool alunoTemFoto = imageUrls.any((imageData) {
          String turmaDaImagem = imageData['docId'];
          String turmaAluno = getTurmaAluno(widget.alunoData ?? {});

          // Ajuste na lógica para comparar corretamente as turmas
          return turmaAluno.toLowerCase() == turmaDaImagem.toLowerCase();
        });

        if (!alunoTemFoto) {
          setState(() {
            // Caso não tenha imagem para a turma do aluno, limpe o stream
            imagensStream = Stream.value([]);
          });
        }
      });
    }
  }

  String getTurmaAluno(Map<String, dynamic> alunoData) {
    return alunoData['serie'] ??
        ''; // Altere isso conforme a estrutura real dos dados.
  }

  @override
  Widget build(BuildContext context) {
    print(
        'Tipo de usuário: ${widget.professorData ?? "Nenhum tipo de usuário"}');

    String turmaAluno = getTurmaAluno(widget.alunoData ?? {});

    return Scaffold(
      appBar: AppBar(
        title: Text('Horários'),
        actions: [
          if (widget.userType == 'Coordenacao')
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: selectedAno,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedAno = newValue!;
                  });

                  filtrarPorAno(selectedAno);
                },
                items: (widget.userType == 'Professor')
                    ? widget.professorData!['series']
                        .map<DropdownMenuItem<String>>((serie) {
                        return DropdownMenuItem<String>(
                          value: serie as String,
                          child: Text(serie),
                        );
                      }).toList()
                    : (widget.userType == 'Coordenacao')
                        ? turma.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList()
                        : [],
              ),
            ),
        ],
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
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible:
                        _temConexaoInternet, // Torna o widget visível apenas se houver conexão com a Internet
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
                        _openImage(imageUrls, selectedAno);
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
                await _pickImage();
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
