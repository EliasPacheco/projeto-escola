import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matrícula',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MatriculaScreen(),
    );
  }
}

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
  TextEditingController naturalidadeController = TextEditingController();
  TextEditingController enderecoResponsavel1Controller =
      TextEditingController();
  TextEditingController enderecoResponsavel2Controller =
      TextEditingController();
  TextEditingController cpfResponsavel2Controller = TextEditingController();
  TextEditingController telefoneResponsavel2Controller =
      TextEditingController();
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(nomeController, 'Nome do Aluno'),
              _buildTextField(nomePaiController, 'Nome do Pai'),
              _buildTextField(nomeMaeController, 'Nome da Mãe'),
              _buildDropdownButton(),
              _buildTextField(
                dataNascimentoController,
                'Data de Nascimento',
                maskFormatter: dataNascimentoFormatter,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(naturalidadeController, 'Naturalidade'),
              _buildTextField(
                dataMatriculaController,
                'Data da Matrícula',
                maskFormatter: dataNascimentoFormatter,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                matriculaController,
                'Matrícula',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              _buildTextField(
                  enderecoResponsavel1Controller, 'Endereço do Responsável 1'),
              _buildTextField(
                cpfResponsavel1Controller,
                'Cpf do responsável 1',
                keyboardType: TextInputType.number,
                maskFormatter: cpfFormatter,
              ),
              _buildTextField(
                telefoneResponsavel1Controller,
                'Telefone 1',
                keyboardType: TextInputType.phone,
                maskFormatter: telefoneFormatter,
              ),
              _buildTextField(
                  enderecoResponsavel2Controller, 'Endereço do Responsável 2'),
              _buildTextField(
                cpfResponsavel2Controller,
                'Cpf do responsável 2',
                keyboardType: TextInputType.number,
                maskFormatter: cpfFormatter,
              ),
              _buildTextField(
                telefoneResponsavel2Controller,
                'Telefone 2',
                keyboardType: TextInputType.phone,
                maskFormatter: telefoneFormatter,
              ),
              _buildTextField(
                senhaController,
                'Senha',
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 10),
              if (isDocumentoAnexado)
                Column(
                  children: documentosAnexados
                      .asMap()
                      .entries
                      .map(
                        (entry) => Row(
                          children: [
                            Text(
                              'Documento Anexado: ${entry.value}',
                              style:
                                  TextStyle(color: Colors.green, fontSize: 14),
                            ),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                _removerDocumento(entry.key);
                              },
                              child: Icon(
                                Icons.close,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  _anexarDocumento(context, 'RG do Aluno', 0);
                },
                child: Text('Anexar RG do Aluno'),
                style: _getButtonStyle(0),
              ),
              ElevatedButton(
                onPressed: () {
                  _anexarDocumento(context, 'RG do Responsável', 1);
                },
                child: Text('Anexar RG do Responsável'),
                style: _getButtonStyle(1),
              ),
              ElevatedButton(
                onPressed: () {
                  _anexarDocumento(context, 'Comprovante de Residência', 2);
                },
                child: Text('Anexar Comprovante de Residência'),
                style: _getButtonStyle(2),
              ),
              ElevatedButton(
                onPressed: () {
                  _anexarDocumento(context, 'Histórico Escolar', 3);
                },
                child: Text('Anexar Histórico Escolar'),
                style: _getButtonStyle(3),
              ),
              /*ElevatedButton(
                onPressed: () {
                  _anexarDocumento(context, 'Declaração Escolar', 4);
                },
                child: Text('Anexar Declaração Escolar'),
                style: _getButtonStyle(4),
              ),*/
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _realizarMatricula();
                },
                child: Text('Realizar Matrícula'),
              ),
            ],
          ),
        ),
      ),
    );
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
    String labelText, {
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
        TextField(
          controller: controller,
          inputFormatters: maskFormatter != null ? [maskFormatter] : null,
          decoration: InputDecoration(
            labelText: labelText,
            border: OutlineInputBorder(),
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
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  void _removerDocumento(int index) {
    setState(() {
      documentosAnexados.removeAt(index);
      if (documentosAnexados.isEmpty) {
        isDocumentoAnexado = false;
      }
      for (int i = 0; i < botoesDesativados.length; i++) {
        if (documentosAnexados.contains('RG do Aluno') && i == 0) {
          botoesDesativados[i] = true;
        } else if (documentosAnexados.contains('RG do Responsável') && i == 1) {
          botoesDesativados[i] = true;
        } else if (documentosAnexados.contains('Comprovante de Residência') &&
            i == 2) {
          botoesDesativados[i] = true;
        } else if (documentosAnexados.contains('Histórico Escolar') && i == 3) {
          botoesDesativados[i] = true;
        } else {
          botoesDesativados[i] = false;
        }
      }
    });
  }

  Future<void> _anexarDocumento(
      BuildContext context, String tipoDocumento, int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        documentosAnexados.add(tipoDocumento);
        isDocumentoAnexado = true;
        botoesDesativados[index] = true;
      });
    }
  }

  String alunoUid = "";

  void _realizarMatricula() async {
    if (!_camposObrigatoriosPreenchidos()) {
      // Mostrar mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preencha todos os campos obrigatórios!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Map<String, dynamic> alunoData = {
      'nome': nomeController.text,
      'nomePai': nomePaiController.text,
      'nomeMae': nomeMaeController.text,
      'serie': serieSelecionada,
      'dataNascimento': dataNascimentoController.text,
      'naturalidade': naturalidadeController.text,
      'dataMatricula': dataMatriculaController.text,
      'matricula': matriculaController.text,
      'enderecoResponsavel1': enderecoResponsavel1Controller.text,
      'cpfResponsavel1': cpfResponsavel1Controller.text,
      'telefoneResponsavel1': telefoneResponsavel1Controller.text,
      'enderecoResponsavel2': enderecoResponsavel2Controller.text,
      'cpfResponsavel2': cpfResponsavel2Controller.text,
      'telefoneResponsavel2': telefoneResponsavel2Controller.text,
      'senha': senhaController.text, // Inclua a senha no mapa de dados
      'documentosAnexados': documentosAnexados,
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
    nomePaiController.clear();
    nomeMaeController.clear();
    serieController.clear();
    dataNascimentoController.clear();
    cpfResponsavel1Controller.clear();
    telefoneResponsavel1Controller.clear();
    enderecoResponsavel1Controller.clear();
    cpfResponsavel2Controller.clear();
    telefoneResponsavel2Controller.clear();
    enderecoResponsavel2Controller.clear();
    dataMatriculaController.clear();
    matriculaController.clear();
    naturalidadeController.clear();
    serieSelecionada = null;
    isDocumentoAnexado = false;
    documentosAnexados.clear();
    senhaController.clear();
    botoesDesativados = [false, false, false, false];
  }
}
