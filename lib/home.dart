import 'package:escola/Login.dart';
import 'package:escola/alunos/AgendaScreen.dart';
import 'package:escola/alunos/AlunoHome.dart';
import 'package:escola/alunos/AvisosScreen.dart';
import 'package:escola/alunos/ChatScreen.dart';
import 'package:escola/alunos/ConteudosScreen.dart';
import 'package:escola/alunos/HorariosScreen.dart';
import 'package:escola/alunos/MatriculaScreen.dart';
import 'package:escola/alunos/OcorrenciasScreen.dart';
import 'package:escola/alunos/StudentScreen.dart';
import 'package:escola/financeiro/FinanceiroHome.dart';
import 'package:escola/funcionarios/Cadastrarfuncionario.dart';
import 'package:escola/suporte/SuporteScreen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MySchoolApp extends StatelessWidget {
  final String matriculaCpf;
  final Map<String, dynamic>? alunoData;
  final String userType;
  final Map<String, dynamic>? professorData;

  const MySchoolApp({
    Key? key,
    required this.matriculaCpf,
    required this.userType,
    this.alunoData,
    this.professorData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(
        matriculaCpf: matriculaCpf,
        alunoData: alunoData,
        userType: userType,
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        'alunos/AlunoHome': (context) => AlunoHome(
              userType: userType,
              professorData: professorData, // Passe as informações do professor
            ),
        'financeiro/FinanceiroHome': (context) => FinanceiroHome(
              userType: userType,
            ),
        'alunos/AvisosScreen': (context) => AvisosHome(
              matriculaCpf: matriculaCpf,
              alunoData: alunoData,
              userType: userType,
            ),
        'alunos/MatriculaScreen': (context) => MatriculaScreen(),
        'alunos/OcorrenciasScreen': (context) => OcorrenciasScreen(
              matriculaCpf: matriculaCpf,
              alunoData: alunoData,
              userType: userType,
            ),
        'alunos/ConteudosScreen': (context) => ConteudosScreen(),
        'suporte/SuporteScreen': (context) => SuporteScreen(),
        'alunos/ChatScreen': (context) => ChatScreen(),
        'alunos/HorariosScreen': (context) => HorariosScreen(),
        'Login': (context) => LoginPage(),
        'alunos/StudentScreen': (context) => StudentScreen(
              matriculaCpf: matriculaCpf,
              alunoData: alunoData,
            ),
        'alunos/AgendaScreen': (context) => AgendaScreen(
              matriculaCpf: matriculaCpf,
              alunoData: alunoData,
              userType: userType,
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
        title: const Text('Escola App'),
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
          MyCard(
            title: 'Financeiro',
            icon: FontAwesomeIcons.handHoldingDollar,
            cardColor: Colors.white,
            borderColor: Color.fromARGB(255, 59, 16, 212),
            onTap: () {
              Navigator.pushNamed(
                context,
                'financeiro/FinanceiroHome',
                arguments: {
                  'userType': userType,
                },
              );
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
              //Navigator.pushNamed(context, 'alunos/ConteudosScreen');
            },
          ),
          MyCard(
            title: 'Chat',
            icon: FontAwesomeIcons.solidCommentDots,
            cardColor: Colors.white,
            borderColor: Color.fromARGB(255, 59, 16, 212),
            onTap: () {
              Navigator.pushNamed(context, 'alunos/ChatScreen');
            },
          ),
          MyCard(
            title: 'Horários',
            icon: FontAwesomeIcons.calendarAlt,
            cardColor: Colors.white,
            borderColor: Color.fromARGB(255, 59, 16, 212),
            onTap: () {
              Navigator.pushNamed(context, 'alunos/HorariosScreen');
            },
          ),
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
