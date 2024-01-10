import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

class CadastroFuncionarioScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Funcionário',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
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
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  static const String _coordenacaoRole = 'Coordenação';
  static const String _professorRole = 'Professor(a)';

  Future<void> _cadastrarFuncionario() async {
    if (_nameController.text.isEmpty ||
        _cpfController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, preencha todos os campos.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      String collectionName =
          _selectedRole == _coordenacaoRole ? 'coordenacao' : 'professores';

      await firestore.collection(collectionName).add({
        'nome': _nameController.text,
        'cpf': _cpfController.text,
        'email': _emailController.text,
        'telefone': _phoneController.text,
        'senha': _passwordController.text,
        'funcao': _selectedRole,
      });

      _nameController.clear();
      _cpfController.clear();
      _phoneController.clear();
      _passwordController.clear();

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Nome',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _cpfController,
          decoration: InputDecoration(
            labelText: 'CPF',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 10),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'E-mail',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 10),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Senha',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
          obscureText: true,
        ),
        SizedBox(height: 10),
        DropdownButton<String>(
          value: _selectedRole,
          onChanged: (String? newValue) {
            setState(() {
              _selectedRole = newValue!;
            });
          },
          items: <String>[_coordenacaoRole, _professorRole]
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: TextStyle(fontSize: 16)),
            );
          }).toList(),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _cadastrarFuncionario,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text('Cadastrar', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }
}
