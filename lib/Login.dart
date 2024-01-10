import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:escola/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.orange,
        ),
        fontFamily: 'Roboto',
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

  Future<void> _signInWithEmailAndPassword() async {
    try {
      String matriculaCpf = _matriculaCpfController.text.trim();
      String senha = _senhaController.text.trim();

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: matriculaCpf, password: senha);

      print('Login bem-sucedido: ${userCredential.user!.uid}');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MySchoolApp()),
      );
    } on FirebaseAuthException catch (e) {
      print('Erro de login: $e');
      // Aqui você pode tratar diferentes tipos de erros, como
      // 'user-not-found', 'wrong-password', etc.
      // Exemplo: mostrar uma mensagem de erro ao usuário
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text('Erro de login: $e'),
      // ));
    }
  }

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
                icon: Icon(Icons.person),
              ),
              keyboardType: TextInputType.emailAddress,
              //number,
              //inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _senhaController,
              decoration: InputDecoration(
                labelText: 'Senha',
                icon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _signInWithEmailAndPassword,
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).colorScheme.secondary,
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
