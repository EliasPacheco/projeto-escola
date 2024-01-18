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
  // Dados fictícios para exemplo
  final List<String> meses = [
    'Janeiro/2023',
    'Fevereiro/2023',
    'Março/2023',
    'Abril/2023',
    'Maio/2023',
    'Junho/2023',
    'Jul/2023',
    'Ago/2023',
    'Set/2023',
    'Out/2023',
    'Nov/2023',
    'Dezembro/2023',
  ];

  final List<String> vencimentos = [
    '15/01',
    '15/02',
    '15/03',
    '15/04',
    '15/05',
    '15/06',
    '15/07',
    '15/08',
    '15/09',
    '15/10',
    '15/11',
    '15/12',
  ];

  final List<String> valores = [
    'R\$ 300,00',
    'R\$ 300,00',
    'R\$ 300,00',
    'R\$ 300,00',
    'R\$ 300,00',
    'R\$ 300,00',
    'R\$ 300,00',
    'R\$ 300,00',
    'R\$ 300,00',
    'R\$ 300,00',
    'R\$ 300,00',
    'R\$ 300,00',
  ];

  final List<bool> pagas = [
    true,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  @override
  Widget build(BuildContext context) {

    print('Tipo: ${userType ?? "Nenhum dado de aluno"}');
    print('Informações do Aluno: ${aluno.nome}, ${aluno.serie}, ${aluno.documentId},');

    return Scaffold(
      appBar: AppBar(
        title: Text('Financeiro'),
      ),
      body: ListView.builder(
        itemCount: meses.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2.0,
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              contentPadding: EdgeInsets.all(16.0),
              title: Text(meses[index]),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.0),
                  Text('Vencimento: ${vencimentos[index]}'),
                  Text('Valor: ${valores[index]}'),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(
                        pagas[index] ? Icons.check_circle : Icons.error,
                        color: pagas[index] ? Colors.green : Colors.red,
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        pagas[index] ? 'Mensalidade Paga' : 'Mensalidade Não Paga',
                        style: TextStyle(
                          color: pagas[index] ? Colors.green : Colors.red,
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

