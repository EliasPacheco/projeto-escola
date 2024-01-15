import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:escola/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<void> _signInWithMatriculaCpfAndPassword() async {
    try {
      String matriculaCpf = _matriculaCpfController.text.trim();
      String senha = _senhaController.text.trim();

      QuerySnapshot<Map<String, dynamic>> coordenacaoQuery =
          await FirebaseFirestore.instance
              .collection('professores')
              .where('cpf', isEqualTo: matriculaCpf)
              .where('senha', isEqualTo: senha)
              .get();

      if (coordenacaoQuery.docs.isEmpty) {
        QuerySnapshot<Map<String, dynamic>> professoresQuery =
            await FirebaseFirestore.instance
                .collection('coordenacao')
                .where('cpf', isEqualTo: matriculaCpf)
                .where('senha', isEqualTo: senha)
                .get();

        if (professoresQuery.docs.isEmpty) {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'Usuário não encontrado nas coleções especificadas',
          );
        }
      }

      print('Login bem-sucedido: $matriculaCpf');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MySchoolApp()),
      );
    } on FirebaseAuthException catch (e) {
      print('Erro de login: $e');
      // Tratar erro, mostrar mensagem, etc.
    } catch (e) {
      print('Erro inesperado: $e');
      // Tratar erro inesperado
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
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
              onPressed: _signInWithMatriculaCpfAndPassword,
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
