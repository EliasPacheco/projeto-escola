import 'package:escola/cards/Ocorrenciacard.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Escolar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: OcorrenciasScreen(),
    );
  }
}

class OcorrenciasScreen extends StatefulWidget {
  @override
  _OcorrenciasScreenState createState() => _OcorrenciasScreenState();
}

class _OcorrenciasScreenState extends State<OcorrenciasScreen> {
  final List<Aviso> avisos = [
    Aviso(
      titulo: 'Mal comportamento',
      conteudo: 'Aluno foi expulso da sala de aula.',
      data: '06/12/2023',
    ),
    // Adicione mais avisos conforme necessário
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ocorrencias Escolares'),
      ),
      body: ListView.builder(
        itemCount: avisos.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: UniqueKey(),
            onDismissed: (direction) {
              setState(() {
                avisos.removeAt(index);
              });
            },
            background: Container(
              color: Colors.red,
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
            child: Card(
              elevation: 2.0,
              margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: ListTile(
                contentPadding: EdgeInsets.all(8.0),
                title: Text(
                  avisos[index].titulo,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(avisos[index].conteudo),
                    SizedBox(height: 8.0),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16.0),
                        SizedBox(width: 4.0),
                        Text(
                          avisos[index].data,
                          style: TextStyle(
                              color: Color.fromARGB(255, 116, 115, 115)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => OcorrenciaCard()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class Aviso {
  final String titulo;
  final String conteudo;
  final String data;

  Aviso({
    required this.titulo,
    required this.conteudo,
    required this.data,
  });
}
