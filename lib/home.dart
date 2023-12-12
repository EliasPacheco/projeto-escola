import 'package:escola/alunos/AlunoHome.dart';
import 'package:escola/alunos/MatriculaScreen.dart';
import 'package:escola/avisos/AvisosHome.dart';
import 'package:escola/financeiro/FinanceiroHome.dart';
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
        'avisos/AvisosHome': (context) => AvisosHome(),
        'alunos/MatriculaScreen': (context) => MatriculaScreen(),
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
            cardColor: Colors.white,  // Alterado para branco
            borderColor: Colors.purple,  // Alterado para branco
            onTap: () {
              Navigator.pushNamed(context, 'avisos/AvisosHome');
            },
          ),
          MyCard(
            title: 'Boletim',
            icon: FontAwesomeIcons.fileAlt,
            cardColor: Colors.white,  // Alterado para branco
            borderColor: Colors.purple,
            onTap: () {},
          ),
          MyCard(
            title: 'Financeiro',
            icon: FontAwesomeIcons.handHoldingDollar,
            cardColor: Colors.white,  // Alterado para branco
            borderColor: Colors.purple,
            onTap: () {
              Navigator.pushNamed(context, 'financeiro/FinanceiroHome');
            },
          ),
          MyCard(
            title: 'Agenda',
            icon: FontAwesomeIcons.calendarCheck,
            cardColor: Colors.white,  // Alterado para branco
            borderColor: Colors.purple,
            onTap: () {},
          ),
          MyCard(
            title: 'Ocorrências',
            icon: FontAwesomeIcons.circleExclamation,
            cardColor: Colors.white,  // Alterado para branco
            borderColor: Colors.purple,
            onTap: () {},
          ),
          MyCard(
            title: 'Conteúdos',
            icon: FontAwesomeIcons.book,
            cardColor: Colors.white,  // Alterado para branco
            borderColor: Colors.purple,
            onTap: () {},
          ),
          MyCard(
            title: 'Chat',
            icon: FontAwesomeIcons.solidCommentDots,
            cardColor: Colors.white,  // Alterado para branco
            borderColor: Colors.purple,
            onTap: () {
              //Navigator.pushNamed(context, 'alunos/AlunoHome');
            },
          ),
          MyCard(
            title: 'Horários',
            icon: FontAwesomeIcons.calendarAlt,
            cardColor: Colors.white,  // Alterado para branco
            borderColor: Colors.purple,
            onTap: () {

              //Navigator.pushNamed(context, 'alunos/MatriculaScreen');
            },
          ),
          MyCard(
            title: 'Suporte',
            icon: FontAwesomeIcons.solidCircleUser,
            cardColor: Colors.white,  // Alterado para branco
            borderColor: Colors.purple,
            onTap: () {

              //Navigator.pushNamed(context, 'alunos/MatriculaScreen');
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
              side: BorderSide(color: borderColor),  // Adicionado para borda roxa
            ),
            color: cardColor,  // Alterado para cor de fundo branca
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(
                icon,
                size: 50.0,
                color: borderColor,  // Alterado para roxo
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
