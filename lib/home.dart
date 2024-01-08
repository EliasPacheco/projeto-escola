import 'package:escola/alunos/AlunoHome.dart';
import 'package:escola/alunos/ChatScreen.dart';
import 'package:escola/alunos/ConteudosScreen.dart';
import 'package:escola/alunos/HorariosScreen.dart';
import 'package:escola/alunos/MatriculaScreen.dart';
import 'package:escola/alunos/AvisosScreen.dart';
import 'package:escola/alunos/OcorrenciasScreen.dart';
import 'package:escola/financeiro/FinanceiroHome.dart';
import 'package:escola/suporte/SuporteScreen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MySchoolApp extends StatelessWidget {
  const MySchoolApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
      routes: {
        'alunos/AlunoHome': (context) => AlunoHome(),
        'financeiro/FinanceiroHome': (context) => FinanceiroHome(),
        'alunos/AvisosScreen': (context) => AvisosHome(),
        'alunos/MatriculaScreen': (context) => MatriculaScreen(),
        'alunos/OcorrenciasScreen': (context) => OcorrenciasScreen(),
        'alunos/ConteudosScreen': (context) => ConteudosScreen(),
        'suporte/SuporteScreen': (context) => SuporteScreen(),
        'alunos/ChatScreen': (context) => ChatScreen(),
        'alunos/HorariosScreen': (context) => HorariosScreen(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escola App'),
      ),
      body: GridView.count(
        crossAxisCount: 3,
        padding: EdgeInsets.all(16.0),
        children: [
          MyCard(
            title: 'Comunicados',
            icon: FontAwesomeIcons.bell,
            cardColor: Colors.white, // Alterado para branco
            borderColor: Color.fromARGB(255, 59, 16, 212),
            onTap: () {
              Navigator.pushNamed(context, 'alunos/AvisosScreen');
            },
          ),
          MyCard(
            //icon: FontAwesomeIcons.fileAlt,
            title: 'Aluno',
            icon: FontAwesomeIcons.userGraduate,
            cardColor: Colors.white, // Alterado para branco
            borderColor: Color.fromARGB(255, 59, 16, 212),
            onTap: () {
              Navigator.pushNamed(context, 'alunos/AlunoHome');
            },
          ),
          MyCard(
            title: 'Financeiro',
            icon: FontAwesomeIcons.handHoldingDollar,
            cardColor: Colors.white, // Alterado para branco
            borderColor: Color.fromARGB(255, 59, 16, 212),
            onTap: () {
              Navigator.pushNamed(context, 'financeiro/FinanceiroHome');
            },
          ),
          MyCard(
            title: 'Agenda',
            icon: FontAwesomeIcons.calendarCheck,
            cardColor: Colors.white, // Alterado para branco
            borderColor: Color.fromARGB(255, 59, 16, 212),
            onTap: () {},
          ),
          MyCard(
            title: 'Ocorrências',
            icon: FontAwesomeIcons.circleExclamation,
            cardColor: Colors.white, // Alterado para branco
            borderColor: Color.fromARGB(255, 59, 16, 212),
            onTap: () {
              Navigator.pushNamed(context, 'alunos/OcorrenciasScreen');
            },
          ),
          MyCard(
            title: 'Conteúdos',
            icon: FontAwesomeIcons.book,
            cardColor: Colors.white, // Alterado para branco
            borderColor: Color.fromARGB(255, 59, 16, 212),
            onTap: () {
              //Navigator.pushNamed(context, 'alunos/ConteudosScreen');
            },
          ),
          MyCard(
            title: 'Chat',
            icon: FontAwesomeIcons.solidCommentDots,
            cardColor: Colors.white, // Alterado para branco
            borderColor: Color.fromARGB(255, 59, 16, 212),
            onTap: () {
              Navigator.pushNamed(context, 'alunos/ChatScreen');
            },
          ),
          MyCard(
            title: 'Horários',
            icon: FontAwesomeIcons.calendarAlt,
            cardColor: Colors.white, // Alterado para branco
            borderColor: Color.fromARGB(255, 59, 16, 212),
            onTap: () {
              Navigator.pushNamed(context, 'alunos/HorariosScreen');
            },
          ),
          MyCard(
            title: 'Suporte',
            icon: FontAwesomeIcons.solidCircleUser,
            cardColor: Colors.white, // Alterado para branco
            borderColor: Color.fromARGB(255, 59, 16, 212),
            onTap: () {
              Navigator.pushNamed(context, 'suporte/SuporteScreen');
            },
          ),
        ],
      ),
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
              side:
                  BorderSide(color: borderColor), // Adicionado para borda roxa
            ),
            color: cardColor, // Alterado para cor de fundo branca
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(
                icon,
                size: 50.0,
                color: borderColor, // Alterado para roxo
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
