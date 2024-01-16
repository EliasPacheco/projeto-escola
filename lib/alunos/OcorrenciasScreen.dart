import 'package:flutter/material.dart';
import 'package:escola/cards/Ocorrenciacard.dart';

class OcorrenciasScreen extends StatefulWidget {
  final String matriculaCpf;
  final Map<String, dynamic>? alunoData;

  OcorrenciasScreen({Key? key, required this.matriculaCpf, this.alunoData})
      : super(key: key);

  @override
  _OcorrenciasScreenState createState() => _OcorrenciasScreenState();
}

class _OcorrenciasScreenState extends State<OcorrenciasScreen> {
  final List<Aviso> avisos = [];
  String nomeAluno = '';

  @override
  void initState() {
    super.initState();
    if (widget.alunoData != null) {
      nomeAluno = widget.alunoData!['nome'] ?? '';
      _getOcorrenciasFromAlunoData();
    } else {
      print('Aluno não encontrado com CPF/Matrícula: ${widget.matriculaCpf}');
    }
  }

  void _getOcorrenciasFromAlunoData() {
    List<dynamic> ocorrencias =
        widget.alunoData!['ocorrencias'] ?? []; // Acessa o array de ocorrências

    setState(() {
      avisos.clear();
      avisos.addAll(ocorrencias.map((ocorrencia) {
        return Aviso(
          titulo: ocorrencia['titulo'] ?? '',
          descricao: ocorrencia['descricao'] ?? '',
          data: ocorrencia['data'] ?? '',
        );
      }).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ocorrências de $nomeAluno'),
      ),
      body: avisos.isEmpty
          ? Center(
              child: Text('Sem ocorrências'),
            )
          : ListView.builder(
              itemCount: avisos.length,
              itemBuilder: (context, index) {
                return Card(
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
                        Text('$nomeAluno ' + avisos[index].descricao),
                        SizedBox(height: 8.0),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16.0),
                            SizedBox(width: 4.0),
                            Text(
                              avisos[index].data,
                              style: TextStyle(
                                color: Color.fromARGB(255, 116, 115, 115),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OcorrenciaCard()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class Aviso {
  final String titulo;
  final String descricao;
  final String data;

  Aviso({
    required this.titulo,
    required this.descricao,
    required this.data,
  });
}
