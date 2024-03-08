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
              _buildDropdownButton(),
              _buildTextField(
                dataNascimentoController,
                'Data de Nascimento',
                maskFormatter: dataNascimentoFormatter,
                keyboardType: TextInputType.number,
              ),
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
              _buildTextField(
                senhaController,
                'Senha',
                keyboardType: TextInputType.text,
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
