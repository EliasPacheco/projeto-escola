import 'package:escola/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue, // Altere a cor principal conforme necessário
        colorScheme: ColorScheme.light(
          primary: Colors.blue, // Cor principal
          secondary: Colors.orange, // Cor de destaque
        ),
        fontFamily: 'Roboto', // Escolha a fonte desejada
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _matriculaCpfController = TextEditingController();
  TextEditingController _senhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _matriculaCpfController,
              decoration: InputDecoration(
                labelText: 'Matrícula ou CPF',
                icon: Icon(Icons.person), // Adicione um ícone para o campo
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _senhaController,
              decoration: InputDecoration(
                labelText: 'Senha',
                icon: Icon(Icons.lock), // Adicione um ícone para o campo
              ),
              obscureText: true,
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                // Adicione aqui a lógica de autenticação
                String matriculaCpf = _matriculaCpfController.text;
                String senha = _senhaController.text;

                // Adicione a lógica de autenticação aqui
                // Exemplo simples: apenas imprime os valores inseridos
                print('Matrícula ou CPF: $matriculaCpf');
                print('Senha: $senha');

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MySchoolApp()),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context)
                    .colorScheme
                    .secondary, // Use a cor de destaque
              ),
              child: const Text(
                'Entrar',
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
