import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Finanças',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: FinanceiroHome(),
    );
  }
}

class FinanceiroHome extends StatefulWidget {
  @override
  _FinanceiroHomeState createState() => _FinanceiroHomeState();
}

class _FinanceiroHomeState extends State<FinanceiroHome> {
  List<Transacao> transacoes = [
    Transacao('Pagamento mensalidade Elias', Icons.attach_money, Colors.green),
    Transacao('Pagamento do veaco José', Icons.attach_money, Colors.green),
    Transacao('Pagamento do fi da minha janta', Icons.attach_money, Colors.green),
    Transacao('Pagamento do fi da minha marmita', Icons.attach_money, Colors.green),
    Transacao('Pagamento da vea do salgado', Icons.attach_money, Colors.green),
    Transacao('Pagamento do nego Gabriel', Icons.attach_money, Colors.green),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Financeiro'),
      ),
      body: ListView.builder(
        itemCount: transacoes.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2.0,
            margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ListTile(
              contentPadding: EdgeInsets.all(8.0),
              title: Text(
                transacoes[index].descricao,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: CircleAvatar(
                backgroundColor: transacoes[index].cor,
                child: Icon(transacoes[index].icone, color: Colors.white),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Estatísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }
}

class Transacao {
  final String descricao;
  final IconData icone;
  final Color cor;

  Transacao(this.descricao, this.icone, this.cor);
}
