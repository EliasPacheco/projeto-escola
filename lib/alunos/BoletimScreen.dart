import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escola/alunos/AlunoHome.dart';
import 'package:flutter/material.dart';

class BoletimScreen extends StatefulWidget {
  final String userType;
  final Aluno aluno;

  BoletimScreen({
    Key? key,
    required this.userType,
    required this.aluno,
  }) : super(key: key);

  @override
  State<BoletimScreen> createState() => _BoletimScreenState();
}

class _BoletimScreenState extends State<BoletimScreen> {
  late Aluno _aluno;
  Map<String, dynamic> _materias = {};

  @override
  void initState() {
    super.initState();
    _aluno = widget.aluno;

    // Modifique o código para buscar os dados corretamente no Firestore
    FirebaseFirestore.instance
        .collection('alunos')
        .doc(_aluno.serie)
        .collection('alunos')
        .doc(_aluno.documentId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          _materias = documentSnapshot['materias'] ??
              {}; // Usando ?? para tratar caso 'materias' seja nulo
        });
      } else {
        print('Documento do aluno não encontrado no Firestore.');
      }
    }).catchError((error) {
      print('Erro ao buscar dados do Firestore: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Boletim - ${_aluno.nome}'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildSubjectCards(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSubjectCards() {
    List<Widget> subjectCards = [];

    if (_materias != null && _materias!.isNotEmpty) {
      _materias!.forEach((subject, grades) {
        List<Widget> subjectRows = [];

        List<String> months = [
          'Janeiro',
          'Fevereiro',
          'Março',
          'Abril',
          'Maio',
          'Junho',
          'Julho',
          'Agosto',
          'Setembro',
          'Outubro',
          'Novembro',
          'Dezembro'
        ];

        for (String month in months) {
          String grade = grades[month] != null ? grades[month].toString() : '';
          Color color = grade.isNotEmpty ? Colors.blue : Colors.orange;

          subjectRows.add(_buildSubjectRow(month, grade, color));
        }

        Widget subjectCard =
            _buildExpandableCard(subject, Icons.subject, subjectRows);
        subjectCards.add(subjectCard);
      });
    } else {
      // Adicione uma mensagem indicando que os dados estão sendo carregados
      subjectCards.add(
        Card(
          child: ListTile(
            title: Text('Carregando boletim...'),
          ),
        ),
      );
    }

    return subjectCards;
  }

  Widget _buildExpandableCard(
      String subject, IconData iconData, List<Widget> subjectRows) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.only(bottom: 20),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Matéria: $subject',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Icon(iconData),
          ],
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notas:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ...subjectRows,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectRow(String subject, String grade, Color color) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(width: 8),
              Text(
                subject,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(
            grade,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
