import 'package:escola/alunos/AlunoHome.dart';
import 'package:escola/cards/Conteudocard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConteudosScreen extends StatefulWidget {
  final String matriculaCpf;
  final Map<String, dynamic>? alunoData;
  final String userType;
  final Map<String, dynamic>? professorData;

  ConteudosScreen({
    Key? key,
    required this.matriculaCpf,
    this.alunoData,
    required this.userType,
    this.professorData,
  }) : super(key: key);

  @override
  _ConteudosScreenState createState() => _ConteudosScreenState();
}

class _ConteudosScreenState extends State<ConteudosScreen> {
  String? serieAluno;
  bool _temConexaoInternet = true;
  Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    serieAluno = widget.alunoData?['serie'];
    super.initState();
    // Verificar o tipo de usuário e, se for aluno, obter a série
    if (widget.userType == 'Aluno') {
      serieAluno = widget.alunoData?['serie'];
    }
    _verificarConexaoInternet();
    _monitorarConexao();
  }

  void _monitorarConexao() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _temConexaoInternet = result != ConnectivityResult.none;
        if (_temConexaoInternet) {}
      });
    });
  }

  Future<void> _verificarConexaoInternet() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    setState(() {
      _temConexaoInternet = connectivityResult != ConnectivityResult.none;
    });
  }

  DateTime parseDate(String dateString) {
    List<String> parts = dateString.split('/');
    if (parts.length == 3) {
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } else {
      throw FormatException('Invalid date format: $dateString');
    }
  }

  Future<void> _downloadDocumento(String documento) async {
    try {
      var conteudoQuery;
      if (widget.userType == 'Aluno') {
        conteudoQuery = await FirebaseFirestore.instance
            .collection('conteudos')
            .doc(widget.alunoData?['turma'])
            .collection('conteudos')
            .where('arquivos', arrayContains: documento)
            .get();
      } else {
        conteudoQuery = await FirebaseFirestore.instance
            .collection('conteudos')
            .doc(selectedAno)
            .collection('conteudos')
            .where('arquivos', arrayContains: documento)
            .get();
      }

      if (conteudoQuery.docs.isNotEmpty) {
        var conteudo = conteudoQuery.docs[0].data();

        if (conteudo.containsKey('urls') && conteudo['urls'] != null) {
          var urls = conteudo['urls'];
          var urlIndex = (conteudo['arquivos'] as List?)?.indexOf(documento);

          if (urlIndex != null && urlIndex >= 0 && urlIndex < urls.length) {
            var downloadUrl = urls[urlIndex];

            // Define o caminho diretamente para a pasta /Download/
            var filePath = '/storage/emulated/0/Download/$documento';

            // Mostra uma notificação que o download começou
            Fluttertoast.showToast(msg: 'Baixando: $documento');

            // Usando Dio para baixar diretamente
            var dio = Dio();

            // Adiciona um listener para atualizar o progresso do download
            dio.download(
              downloadUrl,
              filePath,
              onReceiveProgress: (received, total) {
                // Atualiza a notificação de progresso
                if ((received / total * 100) % 10 == 0) {
                  Fluttertoast.showToast(
                    msg:
                        'Progresso: ${(received / total * 100).toStringAsFixed(1)}%',
                  );
                }
              },
              options: Options(
                receiveTimeout:
                    15000, // Aumenta o tempo limite de recebimento para 15 segundos
              ),
            );

            print('Documento salvo em: $filePath'); // Adicionado print
            Fluttertoast.showToast(
                msg: 'Download concluído: $documento, Salvo em: $filePath');
          } else {
            _showErroDialog('URL do documento não encontrada no Firestore.');
          }
        } else {
          _showErroDialog('URLs dos documentos não encontradas no Firestore.');
        }
      } else {
        _showErroDialog('Documento não encontrado no Firestore.');
        print('Documento não encontrado no Firestore.');
      }
    } catch (e) {
      print('Erro ao baixar o documento: $e');
      _showErroDialog('Erro ao baixar o documento: $e');
    }
  }

  void _showErroDialog(String mensagem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erro'),
          content: Text(mensagem),
          actions: [
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

  Widget _buildFileIcon(String documento) {
    String extension = documento.split('.').last;
    IconData? fileIcon;

    if (extension == 'docx' || extension == 'doc') {
      fileIcon = Icons.description;
    } else if (extension == 'pdf') {
      fileIcon = Icons.picture_as_pdf;
    } else if (extension == 'xlsx' || extension == 'xls') {
      fileIcon = FontAwesomeIcons.fileExport;
    } else if (extension == 'ppt' || extension == 'pptx') {
      fileIcon = FontAwesomeIcons.filePowerpoint;
    } else {
      fileIcon = Icons.insert_drive_file;
    }

    return Icon(fileIcon, size: 40.0, color: Colors.blue);
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      String truncatedText = '${text.substring(0, maxLength)}..';
      String extension = text.split('.').last;
      return '$truncatedText.$extension';
    }
  }

  Future<void> _showDownloadConfirmation(String arquivo) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmação'),
          content: Text('Deseja baixar o arquivo $arquivo?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o modal
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Chama o método para baixar o documento
                _downloadDocumento(arquivo);
                Navigator.of(context).pop(); // Fecha o modal
              },
              child: Text('Baixar'),
            ),
          ],
        );
      },
    );
  }

  String selectedAno = 'Maternal';

  late Stream<List<Aluno>> alunosStream;

  List<String> anos = [
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

  Stream<List<Aluno>> buscarAlunosStream(String selectedAno) {
    return FirebaseFirestore.instance
        .collection('alunos')
        .doc(selectedAno)
        .collection('alunos')
        .snapshots()
        .map((QuerySnapshot querySnapshot) {
      return querySnapshot.docs.map((DocumentSnapshot document) {
        return Aluno(
          documentId: document.id,
          nome: (document['nome'] ?? '').toString(),
          serie: (document['serie'] ?? '').toString(),
        );
      }).toList();
    });
  }

  void filtrarPorAno(String selectedAno) {
    setState(() {
      this.selectedAno = selectedAno;
      // Atualiza o stream com o novo ano selecionado
      alunosStream = buscarAlunosStream(selectedAno);
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Aluno Data: ${widget.alunoData ?? "Nenhum dado de professor"}');
    print('Tipo de usuário: ${widget.userType ?? "Nenhum tipo de usuário"}');

    return Scaffold(
      appBar: AppBar(
        title: Text('Conteudos'),
        actions: [
          if (widget.userType == 'Coordenacao' ||
              widget.userType == 'Professor')
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: selectedAno,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedAno = newValue!;
                  });

                  // Chama a função para filtrar os alunos com base no novo ano selecionado
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
                        ? anos.map<DropdownMenuItem<String>>((String value) {
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
      body: _temConexaoInternet
          ? FutureBuilder<QuerySnapshot>(
              future: (widget.userType == 'Aluno')
                  ? FirebaseFirestore.instance
                      .collection('conteudos')
                      .doc(widget.alunoData?['turma'])
                      .collection('conteudos')
                      .get()
                  : FirebaseFirestore.instance
                      .collection('conteudos')
                      .doc(selectedAno)
                      .collection('conteudos')
                      .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro ao carregar os dados'),
                  );
                }

                List<DocumentSnapshot> documentos = snapshot.data!.docs;

                // Ordena os documentos com base na data
                documentos.sort((a, b) {
                  DateTime dataA = parseDate(a['data']);
                  DateTime dataB = parseDate(b['data']);
                  return dataA.compareTo(dataB);
                });

                print(
                    'Número de documentos na coleção "conteudos": ${documentos.length}');

                if (documentos.isEmpty) {
                  return Center(
                    child: Text('Sem Conteudos'),
                  );
                }

                return ListView.builder(
                  itemCount: documentos.length,
                  itemBuilder: (context, index) {
                    var conteudo =
                        documentos[index].data() as Map<String, dynamic>?;

                    return Card(
                      elevation: 2.0,
                      margin:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(8.0),
                        title: Center(
                          child: Text(
                            conteudo?['data'] ?? 'Sem Data',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (conteudo?['arquivos'] != null &&
                                conteudo?['arquivos'] is List)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 12.0),
                                  for (var arquivo
                                      in (conteudo?['arquivos'] as List?) ?? [])
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            _showDownloadConfirmation(
                                                arquivo.toString());
                                          },
                                          child: Column(
                                            children: [
                                              _buildFileIcon(
                                                  arquivo.toString()),
                                              SizedBox(height: 4.0),
                                              InkWell(
                                                onTap: () {
                                                  _showDownloadConfirmation(
                                                      arquivo.toString());
                                                },
                                                child: Text(
                                                  _truncateText(
                                                      arquivo.toString(), 19),
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      TextStyle(fontSize: 16.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 8.0),
                                      ],
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
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
      floatingActionButton:
          widget.userType == 'Coordenacao' || widget.userType == 'Professor'
              ? FloatingActionButton(
                  onPressed: () {
                    // Adicione a lógica para adicionar novos conteúdos aqui
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConteudoCard(),
                      ),
                    );
                  },
                  child: Icon(Icons.add),
                )
              : null,
    );
  }
}
