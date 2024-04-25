import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class MatriculaScreen extends StatefulWidget {
  @override
  _MatriculaScreenState createState() => _MatriculaScreenState();
}

class _MatriculaScreenState extends State<MatriculaScreen> {
  TextEditingController nomeController = TextEditingController();
  TextEditingController nomePaiController = TextEditingController();
  TextEditingController nomeMaeController = TextEditingController();
  TextEditingController serieController = TextEditingController();
  TextEditingController dataMatriculaController = TextEditingController();
  TextEditingController matriculaController = TextEditingController();
  TextEditingController senhaController =
      TextEditingController(); // Novo controlador

  List<String> anexos = [];

  var dataNascimentoController = TextEditingController();
  var cpfResponsavel1Controller = TextEditingController();
  var telefoneResponsavel1Controller = TextEditingController();

  var dataNascimentoFormatter = MaskTextInputFormatter(
      mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});
  var cpfFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
  var telefoneFormatter = MaskTextInputFormatter(
      mask: '(##) # ####-####', filter: {"#": RegExp(r'[0-9]')});

  bool isDocumentoAnexado = false;
  String? serieSelecionada;
  String? nomeArquivo;
  bool _arquivoSendoProcessado = false;
  File? arquivoSelecionado;

  List<String> documentosAnexados = [];
  List<bool> botoesDesativados = [false, false, false, false];

  final CollectionReference alunosCollection =
      FirebaseFirestore.instance.collection('alunos');

  Map<String, dynamic> materiasPorSerie = {
    'Maternal': {
      'Portugues': {},
      'Matematica': {},
      'Natureza e Sociedade': {},
      'Ingles': {},
    },
    'Infantil I': {
      'Portugues': {},
      'Matematica': {},
      'Natureza e Sociedade': {},
      'Ingles': {},
    },
    'Infantil II': {
      'Portugues': {},
      'Matematica': {},
      'Natureza e Sociedade': {},
      'Ingles': {},
    },
    '1º Ano': {
      'Portugues': {},
      'Gramatica': {},
      'Producao Textual': {},
      'Matematica': {},
      'Historia': {},
      'Geografia': {},
      'Ciencias': {},
      'Religiao': {},
      'Artes': {},
      'Ingles': {},
    },
    '2º Ano': {
      'Portugues': {},
      'Gramatica': {},
      'Producao Textual': {},
      'Matematica': {},
      'Historia': {},
      'Geografia': {},
      'Ciencias': {},
      'Religiao': {},
      'Artes': {},
      'Ingles': {},
    },
    '3º Ano': {
      'Portugues': {},
      'Gramatica': {},
      'Producao Textual': {},
      'Matematica': {},
      'Educacao Financeira': {},
      'Historia': {},
      'Geografia': {},
      'Ciencias': {},
      'Religiao': {},
      'Empreendedorismo': {},
      'Artes': {},
      'Ingles': {},
    },
    '4º Ano': {
      'Portugues': {},
      'Gramatica': {},
      'Producao Textual': {},
      'Matematica': {},
      'Educacao Financeira': {},
      'Historia': {},
      'Geografia': {},
      'Ciencias': {},
      'Religiao': {},
      'Empreendedorismo': {},
      'Artes': {},
      'Ingles': {},
    },
    '5º Ano': {
      'Portugues': {},
      'Gramatica': {},
      'Producao Textual': {},
      'Matematica': {},
      'Educacao Financeira': {},
      'Historia': {},
      'Geografia': {},
      'Ciencias': {},
      'Religiao': {},
      'Empreendedorismo': {},
      'Artes': {},
      'Ingles': {},
    },
    '6º Ano': {
      'Portugues': {},
      'Gramatica': {},
      'Producao Textual': {},
      'Matematica': {},
      'Educacao Financeira': {},
      'Historia': {},
      'Geografia': {},
      'Ciencias': {},
      'Religiao': {},
      'Empreendedorismo': {},
      'Artes': {},
      'Ingles': {},
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Matrícula'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(nomeController, 'Nome do Aluno', Icons.person),
              _buildDropdownButton(),
              _buildTextField(
                dataNascimentoController,
                'Data de Nascimento',
                Icons.calendar_today,
                maskFormatter: dataNascimentoFormatter,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                dataMatriculaController,
                'Data da Matrícula',
                Icons.event,
                maskFormatter: dataNascimentoFormatter,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                matriculaController,
                'Matrícula',
                Icons.confirmation_number,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                senhaController,
                'Senha',
                Icons.lock,
                keyboardType: TextInputType.text,
              ),
              /*ElevatedButton(
                onPressed: () {
                  _anexarDocumento(context, 'Declaração Escolar', 4);
                },
                child: Text('Anexar Declaração Escolar'),
                style: _getButtonStyle(4),
              ),*/
              ElevatedButton.icon(
                onPressed: !_arquivoSendoProcessado
                    ? () async {
                        setState(() {
                          _arquivoSendoProcessado = true;
                        });

                        try {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['xlsx'],
                          );

                          if (result != null && result.files.isNotEmpty) {
                            setState(() {
                              arquivoSelecionado =
                                  File(result.files.single.path!);
                              nomeArquivo = result.files.single.name;
                            });
                          } else {
                            print('Nenhum arquivo selecionado.');
                          }
                        } catch (e) {
                          print('Erro ao carregar o arquivo: $e');
                        } finally {
                          setState(() {
                            _arquivoSendoProcessado = false;
                          });
                        }
                      }
                    : null,
                icon: Icon(
                  Icons.file_upload,
                  color: Colors.white,
                ), // Ícone adicionado
                label: Text(
                  'Importar Arquivo XLSX',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // Alteração de cor do botão
                ),
              ),
              // Exibição do nome do arquivo abaixo do botão
              Row(
                children: [
                  Expanded(
                    child: Text(nomeArquivo ?? ''),
                  ),
                  if (nomeArquivo != null)
                    IconButton(
                      icon: Icon(Icons.clear, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          nomeArquivo = null;
                          arquivoSelecionado = null;
                        });
                      },
                    ),
                ],
              ),

              SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () {
                    _realizarMatricula();
                  },
                  child: Text('Realizar Matrícula',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  DateTime _parseCellValue(dynamic value) {
    if (value is DateTime) {
      return value;
    } else {
      return DateTime.parse(value.toString());
    }
  }

  ButtonStyle _getButtonStyle(int index) {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.all(
        botoesDesativados[index] ? Colors.grey : Colors.blue,
      ),
      textStyle: MaterialStateProperty.all(
        TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText,
    IconData iconData, // Adicionando um parâmetro para o ícone
    {
    TextInputType keyboardType = TextInputType.text,
    MaskTextInputFormatter? maskFormatter,
  }) {
    // Adiciona um listener para garantir que a primeira letra seja sempre maiúscula
    controller.addListener(() {
      final text = controller.text;
      if (text.isNotEmpty) {
        controller.value = controller.value.copyWith(
          text: text.substring(0, 1).toUpperCase() + text.substring(1),
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });

    return Column(
      children: [
        TextFormField(
          controller: controller,
          inputFormatters: maskFormatter != null ? [maskFormatter] : null,
          decoration: InputDecoration(
            labelText: labelText,
            border: OutlineInputBorder(),
            prefixIcon: Icon(iconData), // Ícone adicionado como prefixo
          ),
          keyboardType: keyboardType,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDropdownButton() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: serieSelecionada, // Alteração aqui
          items: [
            'Maternal',
            'Infantil I',
            'Infantil II',
            '1º Ano',
            '2º Ano',
            '3º Ano',
            '4º Ano',
            '5º Ano',
            '6º Ano',
          ].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              serieSelecionada = newValue; // Alteração aqui
            });
          },
          decoration: InputDecoration(
            labelText: 'Série',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.school),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  String alunoUid = "";

  void _realizarMatricula() async {
    if (_arquivoSendoProcessado) {
      // Mostrar uma mensagem informando que um arquivo está sendo processado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aguarde enquanto o arquivo está sendo processado.'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_camposObrigatoriosPreenchidos() && nomeArquivo == null) {
      // Mostrar mensagem de erro apenas se nenhum arquivo estiver sendo processado e os campos obrigatórios não estiverem preenchidos
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Preencha todos os campos obrigatórios ou importe um arquivo XLSX!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Map<String, dynamic> alunoData = {
      'nome': nomeController.text,
      'serie': serieSelecionada,
      'dataNascimento': dataNascimentoController.text,
      'dataMatricula': dataMatriculaController.text,
      'matricula': matriculaController.text,
      'senha': senhaController.text, // Inclua a senha no mapa de dados
      'materias': materiasPorSerie[serieSelecionada],
    };

    // Gere um UID único para o aluno
    alunoUid = alunosCollection.doc().id;
    alunoData['uid'] = alunoUid;

    // Adicione o aluno à coleção de séries
    alunosCollection
        .doc(serieSelecionada)
        .collection('alunos')
        .doc(alunoUid)
        .set(alunoData)
        .then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Matrícula realizada com sucesso!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
      print('Matrícula realizada com sucesso! Document ID: $alunoUid');
      _limparCampos();
    }).catchError((error) {
      print('Erro ao realizar a matrícula: $error');
    });

    try {
      if (arquivoSelecionado != null) {
        if (!arquivoSelecionado!.existsSync()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('O arquivo não existe mais no dispositivo.'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        var bytes = await arquivoSelecionado!.readAsBytes();
        var excel = Excel.decodeBytes(bytes);
        var sheet = excel.tables.keys.first;

        var rows = excel.tables[sheet]!.rows;
        for (var row in rows) {
          var nome = row[0]?.value.toString();
          var serie = row[1]?.value.toString();
          var dataNascimento = formatDate(_parseCellValue(row[2]?.value));
          var dataMatricula = formatDate(_parseCellValue(row[3]?.value));
          var matricula = row[4]?.value.toString();
          var senha = row[5]?.value.toString();

          String alunoUid = alunosCollection.doc().id;

          Map<String, dynamic> alunoData = {
            'nome': nome,
            'serie': serie,
            'dataNascimento': dataNascimento,
            'dataMatricula': dataMatricula,
            'matricula': matricula,
            'senha': senha,
            'uid': alunoUid,
            'materias': materiasPorSerie[serie],
          };

          await alunosCollection
              .doc(serie)
              .collection('alunos')
              .doc(alunoUid)
              .set(alunoData);

          print('Aluno adicionado com sucesso: $alunoUid');
        }

        print('Arquivo carregado com sucesso.');
      }
    } catch (e) {
      print('Erro ao carregar o arquivo: $e');
    }

    // Limpe os campos após a matrícula ser realizada
    _limparCampos();
    setState(() {
      nomeArquivo = null;
      arquivoSelecionado = null;
      serieSelecionada = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Matrícula realizada com sucesso!'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  bool _camposObrigatoriosPreenchidos() {
    return nomeController.text.isNotEmpty &&
        serieSelecionada != null &&
        dataNascimentoController.text.isNotEmpty &&
        dataMatriculaController.text.isNotEmpty &&
        matriculaController.text.isNotEmpty &&
        senhaController.text.isNotEmpty;
  }

  void _limparCampos() {
    nomeController.clear();
    dataNascimentoController.clear();
    dataMatriculaController.clear();
    matriculaController.clear();
    serieSelecionada = null;
    senhaController.clear();
  }
}
