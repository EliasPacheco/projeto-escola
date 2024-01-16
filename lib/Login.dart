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

      print('Matrícula/CPF: $matriculaCpf');
      print('Senha: $senha');

      // Verifica na coleção 'coordenacao'
      QuerySnapshot<Map<String, dynamic>> coordenacaoQuery =
          await FirebaseFirestore.instance
              .collection('coordenacao')
              .where('cpf', isEqualTo: matriculaCpf)
              .where('senha', isEqualTo: senha)
              .get();

      if (coordenacaoQuery.docs.isNotEmpty) {
        _handleSuccessfulLogin(matriculaCpf, null);
        return;
      }

      // Se não encontrar na 'coordenacao', verifica na coleção 'professores'
      QuerySnapshot<Map<String, dynamic>> professoresQuery =
          await FirebaseFirestore.instance
              .collection('professores')
              .where('cpf', isEqualTo: matriculaCpf)
              .where('senha', isEqualTo: senha)
              .get();

      if (professoresQuery.docs.isNotEmpty) {
        _handleSuccessfulLogin(matriculaCpf, null);
        return;
      }

      // Se não encontrar em 'professores' ou 'coordenacao', verifica na coleção 'alunos'
      Map<String, dynamic>? alunoData = await _checkAlunos(matriculaCpf, senha);
      if (alunoData != null) {
        _handleSuccessfulLogin(matriculaCpf, alunoData);
        return;
      }

      throw FirebaseAuthException(
        code: 'user-not-found',
        message:
            'Credenciais inválidas. Usuário não encontrado nas coleções especificadas.',
      );
    } on FirebaseAuthException catch (e) {
      print('Erro de login: $e');
      // Tratar erro, mostrar mensagem, etc.
    } catch (e) {
      print('Erro inesperado: $e');
      // Tratar erro inesperado
    }
  }

  Future<Map<String, dynamic>?> _checkAlunos(
      String matriculaCpf, String senha) async {
    List<String> turmas = [
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

    for (String turma in turmas) {
      QuerySnapshot<Map<String, dynamic>> alunosQuery = await FirebaseFirestore
          .instance
          .collection('alunos/$turma/alunos')
          .where('cpfResponsavel1', isEqualTo: matriculaCpf)
          .get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> alunoSnapshot
          in alunosQuery.docs) {
        CollectionReference<Map<String, dynamic>> turmaCollection =
            FirebaseFirestore.instance.collection('alunos/$turma/alunos');

        QuerySnapshot<Map<String, dynamic>> alunoInfoQuery =
            await turmaCollection.where('matricula', isEqualTo: senha).get();

        if (alunoInfoQuery.docs.isNotEmpty) {
          Map<String, dynamic> alunoData = alunoInfoQuery.docs.first.data();
          alunoData['turma'] = turma; // Adicione o nome da turma ao mapa
          return alunoData;
        }
      }
    }

    return null;
  }

  void _handleSuccessfulLogin(String matriculaCpf, Map<String, dynamic>? alunoData) {
    print('Login bem-sucedido: $matriculaCpf');
    print('Detalhes do alunoData: $alunoData');

    // Show information in a SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Login bem-sucedido. Detalhes: $alunoData'),
        duration: Duration(seconds: 3),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MySchoolApp(
          matriculaCpf: matriculaCpf,
          alunoData: alunoData ?? {},
        ),
      ),
    );
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
