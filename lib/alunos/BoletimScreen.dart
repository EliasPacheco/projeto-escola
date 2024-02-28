import 'package:escola/alunos/AlunoHome.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BoletimScreen extends StatefulWidget {
  final String userType;
  final Aluno aluno;
  final Map<String, dynamic>? alunoData;

  BoletimScreen({
    Key? key,
    required this.userType,
    required this.aluno,
    this.alunoData,
  }) : super(key: key);

  @override
  State<BoletimScreen> createState() => _BoletimScreenState();
}

class _BoletimScreenState extends State<BoletimScreen> {
  late Aluno _aluno; // Adicione essa linha para armazenar o objeto Aluno
  List<Widget> subjectCards = []; // Adicione esta linha

  @override
  void initState() {
    super.initState();
    _aluno = widget.aluno; // Atribua o valor ao objeto _aluno
  }

  @override
  Widget build(BuildContext context) {
    print('Aluno Data: ${widget.alunoData ?? "Nenhum dado de aluno"}');
    print('Subject Cards: $subjectCards'); // Agora você pode acessar a variável

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

  print('Aluno Data (BoletimScreen): ${widget.alunoData}');

  if (widget.alunoData != null &&
      widget.alunoData!['materias'] is Map) {
    Map<String, dynamic> materias = widget.alunoData!['materias'];

    print('Materias (BoletimScreen): $materias');

    if (materias.isNotEmpty) {
      materias.forEach((subject, grades) {
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

          print('Subject: $subject, Month: $month, Grade: $grade');
          subjectRows.add(_buildSubjectRow(month, grade, color));
        }

        Widget subjectCard =
            _buildExpandableCard(subject, Icons.subject, subjectRows);
        subjectCards.add(subjectCard);
      });
    } else {
      print('Materias (BoletimScreen): Mapa de matérias vazio.');
      // Adicione uma mensagem indicando que o boletim não está disponível.
      subjectCards.add(
        Card(
          child: ListTile(
            title: Text('Boletim não disponível.'),
          ),
        ),
      );
    }
  } else {
    print('Materias (BoletimScreen): Dados inválidos ou ausentes.');
    // Adicione uma mensagem indicando que os dados do boletim não estão disponíveis.
    subjectCards.add(
      Card(
        child: ListTile(
          title: Text('Boletim não disponível.'),
        ),
      ),
    );
  }

  print('Subject Cards (BoletimScreen): $subjectCards');

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
