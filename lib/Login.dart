import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:escola/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart' as localAuthProvider;
import 'package:brasil_fields/brasil_fields.dart'; // Adicionado pacote brasil_fields

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
  String userTypeText = '';

  bool _isCoordenacao = false;
  bool _isLoading = false;
  Completer<void>? _loadingCompleter;

  Future<void> _signInWithMatriculaCpfAndPassword() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true; // Inicia o indicador de progresso
        });
      }

      String matriculaCpf = _matriculaCpfController.text.trim();
      String senha = _senhaController.text.trim();

      print('Matrícula/CPF: $matriculaCpf');
      print('Senha: $senha');

      Map<String, dynamic>? alunoData;

      // Verifica na coleção 'coordenacao'
      QuerySnapshot<Map<String, dynamic>> coordenacaoQuery =
          await FirebaseFirestore.instance
              .collection('coordenacao')
              .where('cpf', isEqualTo: matriculaCpf)
              .where('senha', isEqualTo: senha)
              .get();

      // Se não encontrar na 'coordenacao', verifica na coleção 'professores'
      QuerySnapshot<Map<String, dynamic>> professoresQuery =
          await FirebaseFirestore.instance
              .collection('professores')
              .where('cpf', isEqualTo: matriculaCpf)
              .where('senha', isEqualTo: senha)
              .get();

      // Se não encontrar em 'professores' ou 'coordenacao', verifica na coleção 'alunos'
      alunoData = await _checkAlunos(matriculaCpf, senha);
      if (alunoData != null) {
        _handleSuccessfulLogin(matriculaCpf, alunoData);
        print('Login bem-sucedido como Aluno(a)');
        return;
      }

      if (coordenacaoQuery.docs.isNotEmpty) {
        _handleSuccessfulLogin(matriculaCpf, alunoData);
        print('Login bem-sucedido como coordenacao');
        return;
      }

      if (professoresQuery.docs.isNotEmpty) {
        _handleSuccessfulLogin(matriculaCpf, null);
        print('Login bem-sucedido como professor(a)');
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
    } finally {
      if (mounted) {
        _loadingCompleter = Completer<void>();
        Future.delayed(Duration(seconds: 15), () {
          if (!_loadingCompleter!.isCompleted) {
            _loadingCompleter!.complete();
          }
        });

        try {
          await _loadingCompleter!.future;
        } catch (e) {
          // Tratar erro, se necessário
        }

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
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

  @override
  void dispose() {
    // Cancela qualquer operação assíncrona pendente ao descartar o widget
    _matriculaCpfController.dispose();
    _senhaController.dispose();
    _loadingCompleter
        ?.complete(); // Completa o Future se ainda não estiver concluído
    super.dispose();
  }

  void _handleSuccessfulLogin(
      String matriculaCpf, Map<String, dynamic>? alunoData) async {
    print('Login bem-sucedido: $matriculaCpf');
    print('Detalhes do alunoData: $alunoData');

    bool isAluno = alunoData != null;
    bool isProfessor = false;
    bool isCoordenacao = false;

    try {
      // Verifica na coleção 'coordenacao'
      QuerySnapshot<Map<String, dynamic>> coordenacaoQuery =
          await FirebaseFirestore.instance
              .collection('coordenacao')
              .where('cpf', isEqualTo: matriculaCpf)
              .get();

      if (coordenacaoQuery.docs.isNotEmpty) {
        isCoordenacao = true;
      } else {
        // Se não for coordenador, verifica na coleção 'alunos'
        alunoData =
            await _checkAlunos(matriculaCpf, _senhaController.text.trim());
        if (alunoData != null) {
          isAluno = true;
        } else {
          // Se não for aluno, verifica na coleção 'professores'
          QuerySnapshot<Map<String, dynamic>> professoresQuery =
              await FirebaseFirestore.instance
                  .collection('professores')
                  .where('cpf', isEqualTo: matriculaCpf)
                  .get();

          if (professoresQuery.docs.isNotEmpty) {
            isProfessor = true;

            // Obtém as informações do professor
            Map<String, dynamic> professorData =
                professoresQuery.docs.first.data();

            // Adicione o envio das informações para a próxima tela
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MySchoolApp(
                  matriculaCpf: matriculaCpf,
                  alunoData: alunoData,
                  userType: 'Professor',
                  professorData:
                      isProfessor ? professorData : <String, dynamic>{},
                ),
              ),
            );

            print(
                'Informações do professor enviadas para a próxima tela: $professorData');

            return;
          }
        }
      }
    } catch (e) {
      print('Erro ao verificar tipo de usuário: $e');
      // Tratar erro, mostrar mensagem, etc.
    }

    // Construir a mensagem da SnackBar com base no tipo de usuário
    String userTypeText = _getUserTypeText(isAluno, isProfessor, isCoordenacao);
    Provider.of<localAuthProvider.LocalAuthProvider>(context, listen: false)
        .setUserType(userTypeText);
    String snackBarMessage = 'Login bem-sucedido como $userTypeText';

    // Mostrar SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(snackBarMessage),
        duration: Duration(seconds: 3),
      ),
    );

    // Navegar para a próxima tela, se não for um professor
    if (!isProfessor) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MySchoolApp(
            matriculaCpf: matriculaCpf,
            alunoData: alunoData,
            userType: userTypeText,
          ),
        ),
      );
    }
  }

  String _getUserTypeText(bool isAluno, bool isProfessor, bool isCoordenacao) {
    if (isCoordenacao) {
      return 'Coordenacao';
    } else if (isProfessor) {
      return 'Professor';
    } else if (isAluno) {
      return 'Aluno';
    } else {
      return 'Tipo de usuário desconhecido';
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
                labelText: 'CPF',
                icon: Icon(Icons.person),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CpfInputFormatter(),
              ],
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _senhaController,
              decoration: InputDecoration(
                labelText: 'Matrícula',
                icon: Icon(Icons.lock),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              obscureText: true,
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      setState(() {
                        _isLoading = true;
                      });
                      _signInWithMatriculaCpfAndPassword();
                    },
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).colorScheme.secondary,
              ),
              child: _isLoading
                  ? Container(
                      width: 160, // Defina o tamanho desejado
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              'Fazendo login',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          CircularProgressIndicator(),
                        ],
                      ),
                    )
                  : Text(
                      'Entrar',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
