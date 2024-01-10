import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escola/cards/Formacard.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comunicados Escolares'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('comunicados').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<DocumentSnapshot> documentos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documentos.length,
            itemBuilder: (context, index) {
              var aviso = documentos[index];
              return Dismissible(
                key: UniqueKey(),
                onDismissed: (direction) {
                  // Implemente a lógica de exclusão aqui, se necessário
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
                      aviso['titulo'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(aviso['descricao']),
                        SizedBox(height: 8.0),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16.0),
                            SizedBox(width: 4.0),
                            Text(
                              aviso['data'],
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => FormaCard()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
