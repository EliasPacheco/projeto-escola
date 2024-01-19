import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escola/alunos/AlunoHome.dart';
import 'package:escola/cards/Financeirocard.dart';
import 'package:flutter/material.dart';

class FinanceiroScreen extends StatelessWidget {
  final String userType;
  final Aluno aluno;

  FinanceiroScreen({
    Key? key,
    required this.userType,
    required this.aluno,
  }) : super(key: key);

  Stream<List<Map<String, dynamic>>> buscarInformacoesFinanceirasAluno() {
    return FirebaseFirestore.instance
        .collection('alunos')
        .doc(aluno.serie)
        .collection('alunos')
        .doc(aluno.documentId)
        .snapshots()
        .map<List<Map<String, dynamic>>>((documentSnapshot) {
      if (documentSnapshot.exists && documentSnapshot.data() != null) {
        Map<String, dynamic>? data = documentSnapshot.data();
        if (data != null && data.containsKey('financeiro')) {
          List<Map<String, dynamic>> dadosFinanceiros =
              List<Map<String, dynamic>>.from(data['financeiro'] ?? []);

          return dadosFinanceiros;
        }
      }
      return []; // Retorna uma lista vazia se os dados não estiverem presentes ou não tiverem a estrutura correta
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Financeiro'),
      ),
      body: StreamBuilder(
        stream: buscarInformacoesFinanceirasAluno(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Sem pagamentos a realizar'),
            );
          } else {
            List<Map<String, dynamic>> dadosFinanceiros =
                snapshot.data as List<Map<String, dynamic>>;

            return ListView.builder(
              itemCount: dadosFinanceiros.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> infoFinanceira = dadosFinanceiros[index];

                return Card(
                  elevation: 2.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    title: Text(infoFinanceira['mesAno']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8.0),
                        Text('Vencimento: ${infoFinanceira['vencimento']}'),
                        Text('Valor: R\$ ${infoFinanceira['valor']}'),
                        SizedBox(height: 8.0),
                        Row(
                          children: [
                            Icon(
                              infoFinanceira['pagou']
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: infoFinanceira['pagou']
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            SizedBox(width: 8.0),
                            Text(
                              infoFinanceira['pagou']
                                  ? 'Mensalidade Paga'
                                  : 'Mensalidade Não Paga',
                              style: TextStyle(
                                color: infoFinanceira['pagou']
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      if (userType == 'Coordenacao') {
                        _mostrarDialogo(context, infoFinanceira);
                      }
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: userType == 'Coordenacao'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FinanceiroCard(),
                  ),
                );
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  _mostrarDialogo(BuildContext context, Map<String, dynamic> infoFinanceira) {
    if (userType != 'Coordenacao') {
      return;
    }
    TextEditingController mesAnoController =
        TextEditingController(text: infoFinanceira['mesAno']);
    TextEditingController vencimentoController =
        TextEditingController(text: infoFinanceira['vencimento']);
    TextEditingController valorController =
        TextEditingController(text: infoFinanceira['valor'].toString());
    bool pagou = infoFinanceira['pagou'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Editar Informações Financeiras'),
              contentPadding: EdgeInsets.all(16.0),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: mesAnoController,
                    decoration: InputDecoration(labelText: 'Mês/Ano'),
                  ),
                  TextField(
                    controller: vencimentoController,
                    decoration: InputDecoration(labelText: 'Vencimento'),
                  ),
                  TextField(
                    controller: valorController,
                    decoration: InputDecoration(labelText: 'Valor'),
                  ),
                  Row(
                    children: [
                      Text('Pagou:'),
                      Checkbox(
                        value: pagou,
                        onChanged: (value) {
                          setState(() {
                            // Atualiza o estado da variável 'pagou' quando o usuário marca/desmarca a caixa de seleção
                            pagou = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Lógica para salvar as alterações
                    String novoMesAno = mesAnoController.text;
                    String novoVencimento = vencimentoController.text;
                    double novoValor = double.parse(valorController.text);

                    // Remove a entrada antiga do array
                    FirebaseFirestore.instance
                        .collection('alunos')
                        .doc(aluno.serie)
                        .collection('alunos')
                        .doc(aluno.documentId)
                        .update({
                      'financeiro': FieldValue.arrayRemove([infoFinanceira]),
                    });

                    // Adiciona a entrada atualizada ao array
                    FirebaseFirestore.instance
                        .collection('alunos')
                        .doc(aluno.serie)
                        .collection('alunos')
                        .doc(aluno.documentId)
                        .update({
                      'financeiro': FieldValue.arrayUnion([
                        {
                          'mesAno': novoMesAno,
                          'vencimento': novoVencimento,
                          'valor': novoValor,
                          'pagou': pagou,
                        }
                      ]),
                    });

                    Navigator.of(context).pop();
                  },
                  child: Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
