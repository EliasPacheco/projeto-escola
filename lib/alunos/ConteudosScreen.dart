import 'package:flutter/material.dart';

class ConteudosScreen extends StatefulWidget {
  @override
  _ConteudosScreenState createState() => _ConteudosScreenState();
}

class _ConteudosScreenState extends State<ConteudosScreen> {
  // Simulando dados de conteúdo
  String dataPublicacao = "14 de dezembro de 2023";
  String nomeArquivo1 = "Documento 1";
  String nomeArquivo2 = "Documento 2";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Conteúdos"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Data de Publicação:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                dataPublicacao,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                "Documentos para Baixar:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              buildDocumentoWidget(nomeArquivo1),
              buildDocumentoWidget(nomeArquivo2),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDocumentoWidget(String nomeArquivo) {
    return Row(
      children: [
        Icon(Icons.file_download),
        SizedBox(width: 8),
        Text(
          nomeArquivo,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: ConteudosScreen(),
    ),
  );
}
