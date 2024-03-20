import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escola/alunos/AlunoHome.dart';

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

    FirebaseFirestore.instance
        .collection('alunos')
        .doc(_aluno.serie)
        .collection('alunos')
        .doc(_aluno.documentId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          _materias = documentSnapshot['materias'] ?? {};
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
        title: Text('Boletim - ' + _aluno.nome.toString().split(' ')[0]),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
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

    if (_materias != null && _materias.isNotEmpty) {
      _materias.forEach((subject, grades) {
        List<Widget> subjectRows = [];

        List<String> months = [
          'Fevereiro',
          'Março',
          'Abril',
          'Maio',
          'Junho',
          'Agosto',
          'Setembro',
          'Outubro',
          'Novembro',
        ];

        for (String month in months) {
          String grade = grades[month] != null ? grades[month].toString() : '';
          Color color = grade.isNotEmpty
              ? (double.parse(grade) >= 7 ? Colors.blue : Colors.red)
              : Colors.orange;

          // Adiciona o ícone de lápis como ícone de edição
          IconData editIcon = Icons.edit;

          subjectRows.add(_buildSubjectRow(subject, month, grade, editIcon));
        }

        Widget subjectCard =
            _buildExpandableCard(subject, Icons.subject, subjectRows);
        subjectCards.add(subjectCard);
      });
    } else {
      subjectCards.add(
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.only(bottom: 20),
          color: Colors.grey[100],
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
      color: Colors.grey[100],
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Matéria: $subject',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            //Icon(iconData),
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

  Widget _buildSubjectRow(
      String subject, String month, String grade, IconData editIcon) {
    Color textColor = grade.isNotEmpty
        ? (double.parse(grade) >= 7 ? Colors.blue : Colors.red)
        : Colors.orange;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                month,
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                grade,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor, // Altera a cor do texto aqui
                  fontSize: 20,
                ),
              ),
              if (widget.userType == 'Coordenacao')
                IconButton(
                  icon: Icon(
                    editIcon,
                    size: 20,
                  ),
                  onPressed: () {
                    _showEditDialog(subject, month);
                  },
                )
            ],
          ),
        ],
      ),
    );
  }

  void _showEditDialog(String subject, String month) {
    TextEditingController _noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Nota - $subject - $month'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Insira a nova nota:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _noteController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Nota',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fecha o diálogo
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                String newNote = _noteController.text;
                _updateNoteInFirestore(subject, month, newNote);
                Navigator.pop(context); // Fecha o diálogo
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
              ),
              child: Text(
                'Enviar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateNoteInFirestore(String subject, String month, String newNote) {
    FirebaseFirestore.instance
        .collection('alunos')
        .doc(_aluno.serie)
        .collection('alunos')
        .doc(_aluno.documentId)
        .update({
      'materias.$subject.$month': newNote,
    }).then((value) {
      print('Nota atualizada com sucesso!');
      // Você pode atualizar localmente a estrutura de dados se necessário
      setState(() {
        _materias[subject][month] = newNote;
      });
    }).catchError((error) {
      print('Erro ao atualizar nota: $error');
    });
  }
}
