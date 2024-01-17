import 'package:flutter/material.dart';


class StudentScreen extends StatelessWidget {

  final String matriculaCpf;
  final Map<String, dynamic>? alunoData; // Adicione esta linha

  const StudentScreen({
    Key? key,
    required this.matriculaCpf,
    this.alunoData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil do Aluno'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildStudentPhoto(),
            SizedBox(height: 20),
            buildStudentInfo('Nome:', 'Elias Pacheco', Icons.person),
            buildStudentInfo('Série:', '9º Ano', Icons.school),
            buildStudentInfo('Data de Nascimento:', '01/01/2005', Icons.calendar_today),
            buildStudentInfo('Matrícula:', '123456', Icons.confirmation_number),
          ],
        ),
      ),
    );
  }

  Widget buildStudentPhoto() {
    return CircleAvatar(
      radius: 100,
      backgroundImage: AssetImage(
          'assets/eu.jpg'), // Substitua pelo caminho da foto do aluno
    );
  }

  Widget buildStudentInfo(String label, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, size: 30),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 17),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 15),
          ),
        ],
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
    );
  }
}
