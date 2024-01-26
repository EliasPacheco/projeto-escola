import 'package:escola/Login.dart';
import 'package:escola/alunos/AgendaScreen.dart';
import 'package:escola/alunos/AlunoHome.dart';
import 'package:escola/alunos/ChatHome.dart';
import 'package:escola/alunos/ChatScreen.dart';
import 'package:escola/alunos/ConteudosScreen.dart';
import 'package:escola/alunos/Horarioprofessor.dart';
import 'package:escola/alunos/HorariosScreen.dart';
import 'package:escola/alunos/MatriculaScreen.dart';
import 'package:escola/alunos/AvisosScreen.dart';
import 'package:escola/alunos/OcorrenciasScreen.dart';
import 'package:escola/alunos/StudentScreen.dart';
import 'package:escola/financeiro/FinanceiroHome.dart';
import 'package:escola/financeiro/FinanceiroScreen.dart';
import 'package:escola/funcionarios/Cadastrarfuncionario.dart';
import 'package:escola/suporte/SuporteScreen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:escola/alunos/AlunoHome.dart' as AlunoHomePackage;

class MySchoolApp extends StatefulWidget {
  final String matriculaCpf;
  final Map<String, dynamic>? alunoData;
  final Map<String, dynamic>? professorData;
  final String userType; 

  const MySchoolApp({
    Key? key,
    required this.matriculaCpf,
    this.alunoData,
    required this.userType,
    this.professorData,
  }) : super(key: key);

  @override
  State<MySchoolApp> createState() => _MySchoolAppState();
}

class _MySchoolAppState extends State<MySchoolApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(
        matriculaCpf: widget.matriculaCpf,
        alunoData: widget.alunoData,
        userType: widget.userType,
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        'alunos/AlunoHome': (context) => AlunoHome(
              userType: widget.userType,
              professorData: widget.professorData,
              alunoData: widget.alunoData,
            ),
        'financeiro/FinanceiroHome': (context) => FinanceiroHome(
              userType: widget.userType,
              professorData: widget.professorData,
            ),
        'alunos/AvisosScreen': (context) => AvisosHome(
              matriculaCpf: widget.matriculaCpf,
              alunoData: widget.alunoData,
              userType: widget.userType,
              professorData: widget.professorData,
            ),
        'alunos/MatriculaScreen': (context) => MatriculaScreen(),
        'alunos/OcorrenciasScreen': (context) => OcorrenciasScreen(
              matriculaCpf: widget.matriculaCpf,
              alunoData: widget.alunoData,
              userType: widget.userType,
            ),
        'alunos/ConteudosScreen': (context) => ConteudosScreen(
              matriculaCpf: widget.matriculaCpf,
              alunoData: widget.alunoData,
              userType: widget.userType,
              professorData: widget.professorData,
            ),
        'suporte/SuporteScreen': (context) => SuporteScreen(),
        'alunos/ChatScreen': (context) => ChatScreen(
              matriculaCpf: widget.matriculaCpf,
              alunoData: widget.alunoData,
              userType: widget.userType,
            ),
        'alunos/ChatHome': (context) => ChatHome(
              matriculaCpf: widget.matriculaCpf,
              alunoData: widget.alunoData,
              userType: widget.userType,
            ),
        'alunos/HorariosScreen': (context) => HorariosScreen(
              matriculaCpf: widget.matriculaCpf,
              alunoData: widget.alunoData,
              userType: widget.userType,
              professorData: widget.professorData,
            ),
        'Login': (context) => LoginPage(),
        'alunos/StudentScreen': (context) => StudentScreen(
              matriculaCpf: widget.matriculaCpf,
              alunoData: widget.alunoData,
              userType: widget.userType,
            ),
        'alunos/AgendaScreen': (context) => AgendaScreen(
              matriculaCpf: widget.matriculaCpf,
              alunoData: widget.alunoData,
              userType: widget.userType,
              professorData: widget.professorData,
            ),
        'alunos/HorarioProfessor': (context) => HorarioProfessor(
              matriculaCpf: widget.matriculaCpf,
              alunoData: widget.alunoData,
              userType: widget.userType,
              professorData: widget.professorData,
            ),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String matriculaCpf;
  final Map<String, dynamic>? alunoData;
  final String userType;
  final Map<String, dynamic>? professorData;

  MyHomePage({
    Key? key,
    required this.matriculaCpf,
    this.alunoData,
    required this.userType,
    this.professorData,
  }) : super(key: key);

  bool get isAluno => alunoData != null;
  bool get isProfessor => alunoData == null && !isAluno;
  bool get isCoordenacao => alunoData == null && !isAluno && !isProfessor;

  void _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(
        context,
        'Login',
        arguments: {
          'professorData': professorData,
        },
      );
    } catch (e) {
      print('Erro ao fazer logout: $e');
      // Trate o erro, mostre uma mensagem, etc.
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Tipo de usuário: $userType');

    bool isAluno = userType == 'Aluno';
    bool isProfessor = userType == 'Professor';
    bool isCoordenacao = userType == 'Coordenacao';

    print('isAluno: $isAluno');
    print('isProfessor: $isProfessor');
    print('isCoordenacao: $isCoordenacao');

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            color: Colors.red,
            onPressed: () {
              // Adicione a lógica para fazer logout aqui
              _signOut(context);
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 3,
        padding: EdgeInsets.all(16.0),
        children: [
          MyCard(
            title: 'Comunicados',
            icon: FontAwesomeIcons.bell,
            cardColor: Colors.white,
            borderColor: Color.fromARGB(255, 59, 16, 212),
            onTap: () {
              Navigator.pushNamed(context, 'alunos/AvisosScreen');
            },
          ),
          MyCard(
            title: 'Alunos',
            icon: FontAwesomeIcons.userGraduate,
            cardColor: Colors.white,
            borderColor: Color.fromARGB(255, 59, 16, 212),
            onTap: () {
              if (userType == 'Aluno') {
                Navigator.pushNamed(
                  context,
                  'alunos/StudentScreen',
                  arguments: {
                    'userType': userType,
                    'professorData': professorData,
                    //'alunoUid': alunoData?['uid'], // Passa o UID do aluno
                  },
                );
              } else {
                Navigator.pushNamed(
                  context,
                  'alunos/AlunoHome',
                  arguments: {
                    'userType': userType,
                    'professorData': professorData,
                  },
                );
              }
            },
          ),
          if (userType != 'Professor')
            MyCard(
              title: 'Financeiro',
              icon: FontAwesomeIcons.handHoldingDollar,
              cardColor: Colors.white,
              borderColor: Color.fromARGB(255, 59, 16, 212),
              onTap: () {
                if (userType == 'Aluno') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FinanceiroScreen(
                        userType: userType,
                        aluno: AlunoHomePackage.Aluno(
                          nome: alunoData?['nome'],
                          serie: alunoData?['serie'],
                          documentId: alunoData?['uid'],
                        ),
                      ),
                    ),
                  );
                } else {
                  Navigator.pushNamed(
                    context,
                    'financeiro/FinanceiroHome',
                    arguments: {
                      'userType': userType,
                      'professorData': professorData,
                    },
                  );
                }
              },
            ),
          MyCard(
            title: 'Agenda',
            icon: FontAwesomeIcons.calendarCheck,
            cardColor: Colors.white,
            borderColor: Color.fromARGB(255, 59, 16, 212),
            onTap: () {
              Navigator.pushNamed(context, 'alunos/AgendaScreen');
            },
          ),
          if (userType != 'Professor')
            MyCard(
              title: 'Ocorrências',
              icon: FontAwesomeIcons.circleExclamation,
              cardColor: Colors.white,
              borderColor: Color.fromARGB(255, 59, 16, 212),
              onTap: () {
                print('Detalhes do alunoData enviado: $alunoData');
                Navigator.pushNamed(
                  context,
                  'alunos/OcorrenciasScreen',
                  arguments: {
                    'matriculaCpf': matriculaCpf,
                    'alunoData': alunoData,
                    'userType': userType,
                    'professorData': professorData,
                  },
                );
              },
            ),
          MyCard(
            title: 'Conteúdos',
            icon: FontAwesomeIcons.book,
            cardColor: Colors.white,
            borderColor: Color.fromARGB(255, 59, 16, 212),
            onTap: () {
              Navigator.pushNamed(context, 'alunos/ConteudosScreen');
            },
          ),
          if (userType != 'Professor')
            MyCard(
              title: 'Chat',
              icon: FontAwesomeIcons.solidCommentDots,
              cardColor: Colors.white,
              borderColor: Color.fromARGB(255, 59, 16, 212),
              onTap: () {
                if (userType == 'Aluno') {
                  Navigator.pushNamed(context, 'alunos/ChatScreen');
                } else {
                  Navigator.pushNamed(context, 'alunos/ChatHome');
                }
              },
            ),
          MyCard(
            title: 'Horários',
            icon: FontAwesomeIcons.calendarAlt,
            cardColor: Colors.white,
            borderColor: Color.fromARGB(255, 59, 16, 212),
            onTap: () {
              if (isCoordenacao) {
                String selectedRoute =
                    ''; // Variável para armazenar a rota escolhida

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Qual horário deseja acessar?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            selectedRoute = 'alunos/HorariosScreen';
                            Navigator.pop(context); // Fecha o AlertDialog
                          },
                          child: Text('Aluno'),
                        ),
                        TextButton(
                          onPressed: () {
                            selectedRoute = 'alunos/HorarioProfessor';
                            Navigator.pop(context); // Fecha o AlertDialog
                          },
                          child: Text('Professor'),
                        ),
                      ],
                    );
                  },
                ).then((value) {
                  // Faça a navegação fora do AlertDialog
                  if (selectedRoute.isNotEmpty) {
                    Navigator.pushNamed(context, selectedRoute);
                  }
                });
              } else if (isProfessor) {
                Navigator.pushNamed(
                  context,
                  'alunos/HorarioProfessor',
                );
              } else {
                Navigator.pushNamed(context, 'alunos/HorariosScreen');
              }
            },
          ),
          if (userType != 'Professor')
            MyCard(
              title: 'Suporte',
              icon: FontAwesomeIcons.solidCircleUser,
              cardColor: Colors.white,
              borderColor: Color.fromARGB(255, 59, 16, 212),
              onTap: () {
                Navigator.pushNamed(context, 'suporte/SuporteScreen');
              },
            ),
        ],
      ),
      floatingActionButton: userType == 'Coordenacao'
          ? FloatingActionButton(
              onPressed: () {
                // Adicione a lógica para adicionar novos avisos aqui
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CadastroFuncionarioScreen(),
                  ),
                );
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}

class MyCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color cardColor;
  final Color borderColor;
  final Function()? onTap;

  MyCard({
    required this.title,
    required this.icon,
    required this.cardColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(
                color: borderColor,
              ),
            ),
            color: cardColor,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(
                icon,
                size: 50.0,
                color: borderColor,
              ),
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            title,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
