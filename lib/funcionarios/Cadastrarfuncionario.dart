import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.green),
        fontFamily: 'Roboto',
      ),
      home: CadastroFuncionarioScreen(),
    );
  }
}

class ChooseTurmasDialog extends StatefulWidget {
  final List<String> seriesOptions;
  final List<String> selectedSeries;

  ChooseTurmasDialog(
      {required this.seriesOptions, required this.selectedSeries});

  @override
  _ChooseTurmasDialogState createState() => _ChooseTurmasDialogState();
}

class _ChooseTurmasDialogState extends State<ChooseTurmasDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Escolher Turmas'),
      content: Column(
        children: widget.seriesOptions.map((series) {
          return CheckboxListTile(
            title: Text(series),
            value: widget.selectedSeries.contains(series),
            onChanged: (bool? value) {
              setState(() {
                if (value!) {
                  widget.selectedSeries.add(series);
                } else {
                  widget.selectedSeries.remove(series);
                }
              });
            },
          );
        }).toList(),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(widget.selectedSeries);
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}

class ChooseMateriasDialog extends StatefulWidget {
  final List<String> materiasOptions;
  final List<String> selectedMaterias;

  ChooseMateriasDialog(
      {required this.materiasOptions, required this.selectedMaterias});

  @override
  _ChooseMateriasDialogState createState() => _ChooseMateriasDialogState();
}

class _ChooseMateriasDialogState extends State<ChooseMateriasDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Escolher Matérias'),
      content: SingleChildScrollView(
        child: Column(
          children: widget.materiasOptions.map((materia) {
            return CheckboxListTile(
              title: Text(materia),
              value: widget.selectedMaterias.contains(materia),
              onChanged: (bool? value) {
                setState(() {
                  if (value!) {
                    widget.selectedMaterias.add(materia);
                  } else {
                    widget.selectedMaterias.remove(materia);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(widget.selectedMaterias);
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}

class CadastroFuncionarioScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cadastro de Funcionário',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CadastroFuncionarioForm(),
      ),
    );
  }
}

class CadastroFuncionarioForm extends StatefulWidget {
  @override
  _CadastroFuncionarioFormState createState() =>
      _CadastroFuncionarioFormState();
}

class _CadastroFuncionarioFormState extends State<CadastroFuncionarioForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  static const String _coordenacaoRole = 'Coordenação';
  static const String _professorRole = 'Professor(a)';

  List<String> _seriesOptions = [
    'Maternal',
    'Infantil I',
    'Infantil II',
    '1º Ano',
    '2º Ano',
    '3º Ano',
    '4º Ano',
    '5º Ano',
    '6º Ano',
  ];

  List<String> _selectedSeries = [];
  List<String> _selectedMaterias = [];

  // Map to store subject lists for each series
  Map<String, List<String>> subjectLists = {
    'Maternal': [
      'Português-Maternal',
      'Matemática-Maternal',
      'Natureza e Sociedade-Maternal',
      'Inglês-Maternal'
    ],
    'Infantil I': [
      'Português-Infantil I',
      'Matemática-Infantil I',
      'Natureza e Sociedade-Infantil I',
      'Inglês-Infantil I'
    ],
    'Infantil II': [
      'Português-Infantil II',
      'Matemática-Infantil II',
      'Natureza e Sociedade-Infantil II',
      'Inglês-Infantil II'
    ],
    '1º Ano': [
      'Português-1º Ano',
      'Gramática-1º Ano',
      'Produção Textual-1º Ano',
      'Matemática-1º Ano',
      'História-1º Ano',
      'Geografia-1º Ano',
      'Ciências-1º Ano',
      'Religião-1º Ano',
      'Artes-1º Ano',
      'Inglês-1º Ano'
    ],
    '2º Ano': [
      'Português-2º Ano',
      'Gramática-2º Ano',
      'Produção Textual-2º Ano',
      'Matemática-2º Ano',
      'História-2º Ano',
      'Geografia-2º Ano',
      'Ciências-2º Ano',
      'Religião-2º Ano',
      'Artes-2º Ano',
      'Inglês-2º Ano'
    ],
    '3º Ano': [
      'Português-3º Ano',
      'Gramática-3º Ano',
      'Produção Textual-3º Ano',
      'Matemática-3º Ano',
      'Educação Financeira-3º Ano',
      'História-3º Ano',
      'Geografia-2º Ano',
      'Ciências-2º Ano',
      'Religião-2º Ano',
      'Empreendedorismo-2º Ano',
      'Artes-2º Ano',
      'Inglês-2º Ano'
    ],
    '4º Ano': [
      'Português-4º Ano',
      'Gramática-4º Ano',
      'Produção Textual-4º Ano',
      'Matemática-4º Ano',
      'Educação Financeira-4º Ano',
      'História-4º Ano',
      'Geografia-4º Ano',
      'Ciências-4º Ano',
      'Religião-4º Ano',
      'Empreendedorismo-4º Ano',
      'Artes-4º Ano',
      'Inglês-4º Ano'
    ],
    '5º Ano': [
      'Português-5º Ano',
      'Gramática-5º Ano',
      'Produção Textual-5º Ano',
      'Matemática-5º Ano',
      'Educação Financeira-5º Ano',
      'História-5º Ano',
      'Geografia-5º Ano',
      'Ciências-5º Ano',
      'Religião-5º Ano',
      'Empreendedorismo-5º Ano',
      'Artes-5º Ano',
      'Inglês-5º Ano'
    ],
    '6º Ano': [
      'Português-6º Ano',
      'Gramática-6º Ano',
      'Produção Textual-6º Ano',
      'Matemática-6º Ano',
      'Educação Financeira-6º Ano',
      'História-6º Ano',
      'Geografia-6º Ano',
      'Ciências-6º Ano',
      'Religião-6º Ano',
      'Empreendedorismo-6º Ano',
      'Artes-6º Ano',
      'Inglês-6º Ano'
    ],
  };

  Future<void> _cadastrarFuncionario() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      String collectionName =
          _selectedRole == _coordenacaoRole ? 'coordenacao' : 'professores';

      Map<String, dynamic> data = {
        'nome': _nameController.text,
        'cpf': _cpfController.text,
        'email': _emailController.text,
        'senha': _cpfController.text,
        'funcao': _selectedRole,
        'series': _selectedSeries,
        'materias': _selectedMaterias,
      };

      await firestore.collection(collectionName).add(data);

      _nameController.clear();
      _cpfController.clear();
      _passwordController.clear();
      _emailController.clear();
      _selectedSeries.clear();
      _selectedMaterias.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cadastro realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Erro ao cadastrar funcionário: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cadastrar funcionário. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _selectedRole = _coordenacaoRole;

  void _showChooseTurmasDialog() async {
    List<String>? selectedTurmas = await showDialog(
      context: context,
      builder: (context) {
        return ChooseTurmasDialog(
          seriesOptions: _seriesOptions,
          selectedSeries: _selectedSeries,
        );
      },
    );

    if (selectedTurmas != null) {
      setState(() {
        _selectedSeries = selectedTurmas;
      });
    }
  }

  void _showChooseMateriasDialog() async {
    List<String>? selectedMaterias = await showDialog(
      context: context,
      builder: (context) {
        return ChooseMateriasDialog(
          materiasOptions: _selectedSeries
              .map((turma) => subjectLists[turma] ?? [])
              .expand((materias) => materias)
              .toSet()
              .toList(),
          selectedMaterias: _selectedMaterias,
        );
      },
    );

    if (selectedMaterias != null) {
      setState(() {
        _selectedMaterias = selectedMaterias;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nome',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _cpfController,
            decoration: InputDecoration(
              labelText: 'CPF',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 10),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'E-mail',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 10),
          TextField(
            controller: _cpfController,
            decoration: InputDecoration(
              labelText: 'Senha',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            //obscureText: true,
          ),
          DropdownButton<String>(
            value: _selectedRole,
            onChanged: (String? newValue) {
              setState(() {
                _selectedRole = newValue!;
              });
            },
            items: <String>[_coordenacaoRole, _professorRole]
                .map<DropdownMenuItem<String>>(
              (String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(fontSize: 16)),
                );
              },
            ).toList(),
          ),
          if (_selectedRole == _professorRole)
            ElevatedButton(
              onPressed: _showChooseTurmasDialog,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Escolher Turmas', style: TextStyle(fontSize: 18)),
            ),
          if (_selectedRole == _professorRole)
            ElevatedButton(
              onPressed: () {
                _showChooseMateriasDialog();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Escolher Matérias', style: TextStyle(fontSize: 18)),
            ),
          if (_selectedRole == _professorRole)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 10),
                Text(
                  'Turmas selecionadas:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  _selectedSeries.isNotEmpty
                      ? _selectedSeries.join(', ')
                      : 'Nenhuma turma selecionada',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Matérias selecionadas:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  _selectedMaterias.isNotEmpty
                      ? _selectedMaterias.join(', ')
                      : 'Nenhuma matéria selecionada',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ElevatedButton(
            onPressed: _cadastrarFuncionario,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text('Cadastrar', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
