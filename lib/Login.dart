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
import 'package:connectivity_plus/connectivity_plus.dart';

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

  Connectivity _connectivity = Connectivity();
  bool _temConexaoInternet = true;

  @override
  void initState() {
    super.initState();
    _verificarConexaoInternet();
    _monitorarConexao();
  }

  void _monitorarConexao() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _temConexaoInternet = result != ConnectivityResult.none;
      });
    });
  }

  Future<void> _verificarConexaoInternet() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    setState(() {
      _temConexaoInternet = connectivityResult != ConnectivityResult.none;
    });
  }

  Future<void> _signInWithMatriculaCpfAndPassword() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      String matriculaCpf = _matriculaCpfController.text.trim();
      String senha = _senhaController.text.trim();

      print('Matrícula/CPF: $matriculaCpf');
      print('Senha: $senha');

      Map<String, dynamic>? alunoData;

      // Crie uma lista de consultas que serão executadas em paralelo
      List<Query<Map<String, dynamic>>> queries = [
        FirebaseFirestore.instance
            .collection('coordenacao')
            .where('cpf', isEqualTo: matriculaCpf)
            .where('senha', isEqualTo: senha),
        FirebaseFirestore.instance
            .collection('professores')
            .where('cpf', isEqualTo: matriculaCpf)
            .where('senha', isEqualTo: senha),
      ];

      // Execute as consultas em paralelo
      Query<Map<String, dynamic>> queryAlunos = FirebaseFirestore.instance
          .collectionGroup('alunos')
          .where('cpfResponsavel1', isEqualTo: matriculaCpf)
          .where('matricula', isEqualTo: senha);

      queries.add(queryAlunos);

      // Use o método `get` para buscar dados de diferentes coleções ao mesmo tempo
      List<QuerySnapshot<Map<String, dynamic>>> results =
          await Future.wait(queries.map((query) => query.get()));

      // Verifique os resultados
      for (QuerySnapshot<Map<String, dynamic>> result in results) {
        if (result.docs.isNotEmpty) {
          // Se encontrar dados em alguma consulta, trate como login bem-sucedido
          alunoData = result.docs.first.data();
          _handleSuccessfulLogin(matriculaCpf, alunoData);
          return;
        }
      }

      // Se não encontrou dados em nenhuma consulta, exibe o Snackbar
      showInvalidCredentialsSnackbar();
    } on FirebaseAuthException catch (e) {
      print('Erro de login: $e');
      // Tratar erro, mostrar mensagem, etc.
    } catch (e) {
      print('Erro inesperado: $e');
      // Tratar erro inesperado
    } finally {
      if (mounted) {
        _loadingCompleter = Completer<void>();
        Future.delayed(Duration(seconds: 1), () {});

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
    String snackBarMessage = 'Login bem-sucedido';

    // Mostrar SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(snackBarMessage),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );

    await Future.delayed(Duration(seconds: 2));

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

  void showInvalidCredentialsSnackbar() {
    if (!_temConexaoInternet) {
      // Snackbar para quando não há conexão com a internet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sem conexão com a internet'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Snackbar para CPF ou Matrícula inválidos quando há conexão com a internet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CPF ou Matrícula inválidos. Usuário não encontrado.'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/escola.png', // Substitua pelo caminho correto da sua logo
              height: 250.0,
            ),
            SizedBox(height: 16.0),
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
