import 'package:flutter/material.dart';

class FinanceiroHome extends StatefulWidget {
  final String userType;

  const FinanceiroHome({
    Key? key,
    required this.userType,
  }) : super(key: key);

  @override
  _FinanceiroHomeState createState() => _FinanceiroHomeState();
}

class _FinanceiroHomeState extends State<FinanceiroHome> {
  List<Transacao> transacoes = [
    Transacao('Pagamento mensalidade Elias', Icons.attach_money, Colors.green),
    Transacao('Pagamento do veaco José', Icons.attach_money, Colors.green),
    Transacao(
        'Pagamento do fi da minha janta', Icons.attach_money, Colors.green),
    Transacao(
        'Pagamento do fi da minha marmita', Icons.attach_money, Colors.green),
    Transacao('Pagamento da vea do salgado', Icons.attach_money, Colors.green),
    Transacao('Pagamento do nego Gabriel', Icons.attach_money, Colors.green),
  ];

  List<String> anos = [
    'Maternal',
    'Infantil I',
    'Infantil II',
    '1º Ano',
    '2º Ano',
    '3º Ano',
    '4º Ano',
    '5º Ano',
    '6º Ano'
  ];
  String selectedAno = 'Maternal';

  void filtrarPorAno(String selectedAno) {
    setState(() {
      // Lógica para filtrar os alunos pelo ano selecionado
      // Aqui você pode adicionar a lógica específica conforme necessário
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Financeiro'),
        actions: [
          if (widget.userType == 'Coordenacao')
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: selectedAno,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedAno = newValue!;
                    filtrarPorAno(selectedAno);
                  });
                },
                items: anos.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
        ],
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
    );
  }
}

class Transacao {
  final String descricao;
  final IconData icone;
  final Color cor;

  Transacao(this.descricao, this.icone, this.cor);
}
