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
      home: AvisosHome(),
    );
  }
}

class AvisosHome extends StatefulWidget {
  @override
  _AvisosHomeState createState() => _AvisosHomeState();
}

class _AvisosHomeState extends State<AvisosHome> {
  final List<Aviso> avisos = [
    Aviso(
      titulo: 'Prova de Matemática',
      conteudo: 'Não se esqueça da prova de Matemática amanhã na sala 203.',
      data: '06/12/2023',
    ),
    Aviso(
      titulo: 'Reunião de Pais e Professores',
      conteudo: 'Lembrete: Reunião marcada para sexta-feira às 18:00 no auditório.',
      data: '08/12/2023',
    ),
    // Adicione mais avisos conforme necessário
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comunicados Escolares'),
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
                          style: TextStyle(color: Color.fromARGB(255, 116, 115, 115)),
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
          // Adicione a lógica para adicionar novos avisos aqui
          // Exemplo: Navigator.push(context, MaterialPageRoute(builder: (context) => AdicionarAvisoScreen()));
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
