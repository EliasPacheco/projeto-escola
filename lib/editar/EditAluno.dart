import 'package:escola/alunos/AlunoHome.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class EditarAlunoScreen extends StatefulWidget {
  final String userType;
  final Aluno aluno;

  EditarAlunoScreen({
    Key? key,
    required this.userType,
    required this.aluno,
  }) : super(key: key);
  @override
  _EditarAlunoScreenState createState() => _EditarAlunoScreenState();
}

class _EditarAlunoScreenState extends State<EditarAlunoScreen> {
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
void initState() {
  super.initState();
  _carregarDadosAluno();
}

void _carregarDadosAluno() {
  FirebaseFirestore.instance
      .collection('alunos')
      .doc(widget.aluno.serie) // Supondo que a série seja o ID do documento do aluno
      .collection('alunos')
      .doc(widget.aluno.documentId)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    if (documentSnapshot.exists) {
      setState(() {
        // Preencher os controladores com as informações do aluno
        nomeController.text = documentSnapshot['nome'];
        serieSelecionada = documentSnapshot['serie'];
        dataNascimentoController.text = documentSnapshot['dataNascimento'] ?? '';
        dataMatriculaController.text = documentSnapshot['dataMatricula'] ?? '';
        matriculaController.text = documentSnapshot['matricula'] ?? '';
        senhaController.text = documentSnapshot['senha'] ?? '';
        // Preencher outros campos conforme necessário
      });
    } else {
      print('Documento do aluno não encontrado.');
    }
  }).catchError((error) {
    print('Erro ao carregar dados do aluno: $error');
  });
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Editar Aluno'),
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
            _buildTextField(nomeController, 'Nome', Icons.person),
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _salvarEdicaoAluno();
              },
              child: Text('Salvar', style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // Alteração de cor do botão
                ), 
            ),
          ],
        ),
      ),
    ),
  );
}

void _salvarEdicaoAluno() {
  // Verificar se algum campo obrigatório está vazio
  if (!_camposObrigatoriosPreenchidos()) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Preencha todos os campos obrigatórios!'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
    return; // Sair da função se algum campo estiver vazio
  }

  // Atualizar os dados do aluno no Firestore
  FirebaseFirestore.instance
      .collection('alunos')
      .doc(widget.aluno.serie) // Supondo que a série seja o ID do documento do aluno
      .collection('alunos')
      .doc(widget.aluno.documentId)
      .update({
        'nome': nomeController.text,
        'serie': serieSelecionada,
        'dataNascimento': dataNascimentoController.text,
        'dataMatricula': dataMatriculaController.text,
        'matricula': matriculaController.text,
        'senha': senhaController.text,
        // Adicione aqui outros campos conforme necessário
      })
      .then((value) {
        // Exibir uma mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Informações do aluno salvas com sucesso!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      })
      .catchError((error) {
        // Em caso de erro, exibir uma mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar as informações do aluno.'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
        print('Erro ao salvar as informações do aluno: $error');
      });
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


  bool _camposObrigatoriosPreenchidos() {
    return nomeController.text.isNotEmpty &&
        serieSelecionada != null &&
        dataNascimentoController.text.isNotEmpty &&
        dataMatriculaController.text.isNotEmpty &&
        matriculaController.text.isNotEmpty &&
        senhaController.text.isNotEmpty;
  }
}
