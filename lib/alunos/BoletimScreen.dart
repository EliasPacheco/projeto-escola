import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BoletimScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Boletim"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildExpandableCard('Matemática', FontAwesomeIcons.calculator, [
                _buildSubjectRow('Janeiro', '9.5', Colors.blue),
                _buildSubjectRow('Fevereiro', '8.0', Colors.green),
                _buildSubjectRow('Março', '', Colors.orange),
                _buildSubjectRow('Abril', '', Colors.orange),
                _buildSubjectRow('Maio', '', Colors.orange),
                _buildSubjectRow('Junho', '', Colors.orange),
                _buildSubjectRow('Julho', '', Colors.orange),
                _buildSubjectRow('Agosto', '', Colors.orange),
                _buildSubjectRow('Setembro', '', Colors.orange),
                _buildSubjectRow('Outubro', '', Colors.orange),
                _buildSubjectRow('Novembro', '', Colors.orange),
                _buildSubjectRow('Dezembro', '', Colors.orange),
              ]),
              _buildExpandableCard('Português', FontAwesomeIcons.book, [
                _buildSubjectRow('Janeiro', '9.5', Colors.blue),
                _buildSubjectRow('Fevereiro', '8.0', Colors.green),
                _buildSubjectRow('Março', '', Colors.orange),
                _buildSubjectRow('Abril', '', Colors.orange),
                _buildSubjectRow('Maio', '', Colors.orange),
                _buildSubjectRow('Junho', '', Colors.orange),
                _buildSubjectRow('Julho', '', Colors.orange),
                _buildSubjectRow('Agosto', '', Colors.orange),
                _buildSubjectRow('Setembro', '', Colors.orange),
                _buildSubjectRow('Outubro', '', Colors.orange),
                _buildSubjectRow('Novembro', '', Colors.orange),
                _buildSubjectRow('Dezembro', '', Colors.orange),
              ]),
              _buildExpandableCard('Ciências', FontAwesomeIcons.microscope, [
                _buildSubjectRow('Janeiro', '9.5', Colors.blue),
                _buildSubjectRow('Fevereiro', '8.0', Colors.green),
                _buildSubjectRow('Março', '', Colors.orange),
                _buildSubjectRow('Abril', '', Colors.orange),
                _buildSubjectRow('Maio', '', Colors.orange),
                _buildSubjectRow('Junho', '', Colors.orange),
                _buildSubjectRow('Julho', '', Colors.orange),
                _buildSubjectRow('Agosto', '', Colors.orange),
                _buildSubjectRow('Setembro', '', Colors.orange),
                _buildSubjectRow('Outubro', '', Colors.orange),
                _buildSubjectRow('Novembro', '', Colors.orange),
                _buildSubjectRow('Dezembro', '', Colors.orange),
              ]),
              _buildExpandableCard('Fisica', FontAwesomeIcons.lightbulb, [
                _buildSubjectRow('Janeiro', '9.5', Colors.blue),
                _buildSubjectRow('Fevereiro', '8.0', Colors.green),
                _buildSubjectRow('Março', '', Colors.orange),
                _buildSubjectRow('Abril', '', Colors.orange),
                _buildSubjectRow('Maio', '', Colors.orange),
                _buildSubjectRow('Junho', '', Colors.orange),
                _buildSubjectRow('Julho', '', Colors.orange),
                _buildSubjectRow('Agosto', '', Colors.orange),
                _buildSubjectRow('Setembro', '', Colors.orange),
                _buildSubjectRow('Outubro', '', Colors.orange),
                _buildSubjectRow('Novembro', '', Colors.orange),
                _buildSubjectRow('Dezembro', '', Colors.orange),
              ]),
              _buildExpandableCard('Quimica', FontAwesomeIcons.flask, [
                _buildSubjectRow('Janeiro', '9.5', Colors.blue),
                _buildSubjectRow('Fevereiro', '8.0', Colors.green),
                _buildSubjectRow('Março', '', Colors.orange),
                _buildSubjectRow('Abril', '', Colors.orange),
                _buildSubjectRow('Maio', '', Colors.orange),
                _buildSubjectRow('Junho', '', Colors.orange),
                _buildSubjectRow('Julho', '', Colors.orange),
                _buildSubjectRow('Agosto', '', Colors.orange),
                _buildSubjectRow('Setembro', '', Colors.orange),
                _buildSubjectRow('Outubro', '', Colors.orange),
                _buildSubjectRow('Novembro', '', Colors.orange),
                _buildSubjectRow('Dezembro', '', Colors.orange),
              ]),
              _buildExpandableCard('Artes', FontAwesomeIcons.palette, [
                _buildSubjectRow('Janeiro', '9.5', Colors.blue),
                _buildSubjectRow('Fevereiro', '8.0', Colors.green),
                _buildSubjectRow('Março', '', Colors.orange),
                _buildSubjectRow('Abril', '', Colors.orange),
                _buildSubjectRow('Maio', '', Colors.orange),
                _buildSubjectRow('Junho', '', Colors.orange),
                _buildSubjectRow('Julho', '', Colors.orange),
                _buildSubjectRow('Agosto', '', Colors.orange),
                _buildSubjectRow('Setembro', '', Colors.orange),
                _buildSubjectRow('Outubro', '', Colors.orange),
                _buildSubjectRow('Novembro', '', Colors.orange),
                _buildSubjectRow('Dezembro', '', Colors.orange),
              ]),
              _buildExpandableCard('Inglês', FontAwesomeIcons.language, [
                _buildSubjectRow('Janeiro', '9.5', Colors.blue),
                _buildSubjectRow('Fevereiro', '8.0', Colors.green),
                _buildSubjectRow('Março', '', Colors.orange),
                _buildSubjectRow('Abril', '', Colors.orange),
                _buildSubjectRow('Maio', '', Colors.orange),
                _buildSubjectRow('Junho', '', Colors.orange),
                _buildSubjectRow('Julho', '', Colors.orange),
                _buildSubjectRow('Agosto', '', Colors.orange),
                _buildSubjectRow('Setembro', '', Colors.orange),
                _buildSubjectRow('Outubro', '', Colors.orange),
                _buildSubjectRow('Novembro', '', Colors.orange),
                _buildSubjectRow('Dezembro', '', Colors.orange),
              ]),
              _buildExpandableCard('Espanhol', FontAwesomeIcons.language, [
                _buildSubjectRow('Janeiro', '9.5', Colors.blue),
                _buildSubjectRow('Fevereiro', '8.0', Colors.green),
                _buildSubjectRow('Março', '', Colors.orange),
                _buildSubjectRow('Abril', '', Colors.orange),
                _buildSubjectRow('Maio', '', Colors.orange),
                _buildSubjectRow('Junho', '', Colors.orange),
                _buildSubjectRow('Julho', '', Colors.orange),
                _buildSubjectRow('Agosto', '', Colors.orange),
                _buildSubjectRow('Setembro', '', Colors.orange),
                _buildSubjectRow('Outubro', '', Colors.orange),
                _buildSubjectRow('Novembro', '', Colors.orange),
                _buildSubjectRow('Dezembro', '', Colors.orange),
              ]),
              // Add more cards for other subjects or months as needed
              SizedBox(height: 20),
              Text(
                'Média Geral: 8.3',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
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
