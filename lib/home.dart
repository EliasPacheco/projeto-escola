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
            title: 'Financeiro',
            icon: FontAwesomeIcons.chartLine,
            cardColor: Colors.blue,
            onTap: () {
              Navigator.pushNamed(context, 'financeiro/FinanceiroHome');
            },
          ),
          MyCard(
            title: 'Alunos',
            icon: FontAwesomeIcons.users,
            cardColor: Colors.green,
            onTap: () {
              Navigator.pushNamed(context, 'alunos/AlunoHome');
            },
          ),
          MyCard(
            title: 'Matricula',
            icon: FontAwesomeIcons.graduationCap,
            cardColor: Colors.blue,
            onTap: () {
              Navigator.pushNamed(context, 'alunos/MatriculaScreen');
            },
          ),
          MyCard(
            title: 'Avisos',
            icon: FontAwesomeIcons.bell,
            cardColor: Colors.red,
            onTap: () {
              Navigator.pushNamed(context, 'avisos/AvisosHome');
            },
          ),
          // Adicione mais cartões conforme necessário
        ],
      ),
    );
  }
}

class MyCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color cardColor;
  final Function()? onTap;

  MyCard({
    required this.title,
    required this.icon,
    required this.cardColor,
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
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(
                icon,
                size: 50.0,
                color: cardColor,
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
