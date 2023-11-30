import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MySchoolApp extends StatelessWidget {
  const MySchoolApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
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
        crossAxisCount: 2,
        padding: EdgeInsets.all(16.0),
        children: [
          MyCard(
            title: 'Financeiro',
            content: 'Detalhes de finanças aqui',
            icon: FontAwesomeIcons.chartLine,
            cardColor: Colors.blue,
          ),
          MyCard(
            title: 'Alunos',
            content: 'Lista de alunos aqui',
            icon: FontAwesomeIcons.users,
            cardColor: Colors.green,
          ),
          MyCard(
            title: 'Matricula',
            content: 'Detalhes do perfil',
            icon: FontAwesomeIcons.graduationCap,
            cardColor: Colors.blue,
          ),
          MyCard(
            title: 'Comunicados',
            content: 'Detalhes dos comunicados aqui',
            icon: FontAwesomeIcons.bell,
            cardColor: Colors.red,
          ),

          // Adicione mais cards conforme necessário
        ],
      ),
    );
  }
}

class MyCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color cardColor;

  MyCard({
    required this.title,
    required this.content,
    required this.icon,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        onTap: () {
          // Adicione a navegação ou ação desejada quando o card for tocado
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 50.0,
                color: cardColor,
              ),
              SizedBox(height: 16.0),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                content,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
