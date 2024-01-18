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

  @override
  Widget build(BuildContext context) {
    Stream<List<Map<String, dynamic>>> buscarInformacoesFinanceirasAluno() {
      return FirebaseFirestore.instance
          .collection('alunos')
          .doc(aluno.serie)
          .collection('alunos')
          .doc(aluno.documentId)
          .snapshots()
          .map<List<Map<String, dynamic>>>((documentSnapshot) {
        // Obtenha os dados financeiros do aluno do documentSnapshot
        return List<Map<String, dynamic>>.from(
            documentSnapshot['financeiro'] ?? []);
      });
    }

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
                        Text('Valor: R\$ ${infoFinanceira['valor']},00'),
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
                // Adicione a lógica para adicionar novos avisos aqui
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
}
