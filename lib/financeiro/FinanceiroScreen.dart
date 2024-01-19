import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escola/alunos/AlunoHome.dart';
import 'package:escola/cards/Financeirocard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/services.dart';

class FinanceiroScreen extends StatefulWidget {
  final String userType;
  final Aluno aluno;

  FinanceiroScreen({
    Key? key,
    required this.userType,
    required this.aluno,
  }) : super(key: key);

  @override
  State<FinanceiroScreen> createState() => _FinanceiroScreenState();
}

class _FinanceiroScreenState extends State<FinanceiroScreen> {
  Stream<List<Map<String, dynamic>>> buscarInformacoesFinanceirasAluno() {
    return FirebaseFirestore.instance
        .collection('alunos')
        .doc(widget.aluno.serie)
        .collection('alunos')
        .doc(widget.aluno.documentId)
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

  String obterDataAtualFormatada() {
    var agora = DateTime.now();
    var formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(agora);
  }

  String selectedPaymentOption = 'Dinheiro';

  Map<String, IconData> formaPagamentoIcons = {
    'Dinheiro': Icons.attach_money,
    'Pix': Icons.qr_code,
    'Cartão de Crédito': Icons.credit_card,
    'Cartão de Débito': Icons.credit_card,
    'Transferência Bancária': Icons.account_balance,
    'Boleto': Icons.receipt,
  };

  String _formatMonthYear(String text) {
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1 && text.length > 2) {
        buffer.write('/');
      }
    }
    return buffer.toString();
  }

  bool _isVencimentoHoje(DateTime dataVencimento) {
    DateTime hoje = DateTime.now();
    hoje = DateTime(
        hoje.year, hoje.month, hoje.day); // Zerando horas, minutos e segundos

    print('Data de Vencimento: $dataVencimento');
    print('Data de Hoje: $hoje');

    return dataVencimento.year == hoje.year &&
        dataVencimento.month == hoje.month &&
        dataVencimento.day == hoje.day;
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

            // Ordena os dadosFinanceiros pela chave 'mesAno'
            dadosFinanceiros.sort((a, b) {
              DateTime dataA = DateFormat('MM/yyyy').parse(a['mesAno']);
              DateTime dataB = DateFormat('MM/yyyy').parse(b['mesAno']);
              return dataA.compareTo(dataB);
            });

            return ListView.builder(
              itemCount: dadosFinanceiros.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> infoFinanceira = dadosFinanceiros[index];

                DateTime dataVencimento = DateFormat('dd/MM/yyyy')
                    .parse(infoFinanceira['vencimento']);

                bool mesmoDiaDoVencimento = _isVencimentoHoje(dataVencimento);

                bool vencimentoAtrasado =
                    dataVencimento.isBefore(DateTime.now());

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
                        if (infoFinanceira['pagou'])
                          Text(
                              'Data de pagamento: ${obterDataAtualFormatada()}'),
                        if (infoFinanceira['pagou'])
                          Text(
                              'Forma de pagamento: ${infoFinanceira['formaPagamento']}'),
                        SizedBox(height: 8.0),
                        Row(
                          children: [
                            Icon(
                              infoFinanceira['pagou']
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: infoFinanceira['pagou']
                                  ? Colors.green
                                  : (mesmoDiaDoVencimento
                                      ? Colors.orange
                                      : (vencimentoAtrasado
                                          ? Colors.red
                                          : Colors.orange)),
                            ),
                            SizedBox(width: 8.0),
                            Text(
                              infoFinanceira['pagou']
                                  ? 'Mensalidade Paga'
                                  : (_isVencimentoHoje(dataVencimento)
                                      ? 'Aguardando pagamento (Vence Hoje)'
                                      : (vencimentoAtrasado
                                          ? 'Mensalidade em atraso'
                                          : 'Aguardando pagamento')),
                              style: TextStyle(
                                color: infoFinanceira['pagou']
                                    ? Colors.green
                                    : (_isVencimentoHoje(dataVencimento)
                                        ? Colors.orange
                                        : (vencimentoAtrasado
                                            ? Colors.red
                                            : Colors.orange)),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      if (widget.userType == 'Coordenacao') {
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
      floatingActionButton: widget.userType == 'Coordenacao'
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
    if (widget.userType != 'Coordenacao') {
      return;
    }
    TextEditingController mesAnoController =
        TextEditingController(text: infoFinanceira['mesAno']);
    TextEditingController vencimentoController =
        TextEditingController(text: infoFinanceira['vencimento']);
    TextEditingController valorController =
        TextEditingController(text: infoFinanceira['valor'].toString());
    bool pagou = infoFinanceira['pagou'];
    String selectedPaymentOption =
        infoFinanceira['formaPagamento'] ?? 'Dinheiro';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Editar Informações'),
              contentPadding: EdgeInsets.all(16.0),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: mesAnoController,
                    decoration: InputDecoration(labelText: 'Mês/Ano'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                      TextInputFormatter.withFunction(
                        (oldValue, newValue) {
                          final newText = newValue.text;
                          final formattedDate = _formatMonthYear(newText);
                          return newValue.copyWith(
                            text: formattedDate,
                            selection: TextSelection.collapsed(
                                offset: formattedDate.length),
                          );
                        },
                      ),
                    ],
                  ),
                  TextField(
                    controller: vencimentoController,
                    decoration: InputDecoration(labelText: 'Vencimento'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      DataInputFormatter(),
                    ],
                  ),
                  TextField(
                    controller: valorController,
                    decoration: InputDecoration(labelText: 'Valor'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    child: Text('Forma de Pagamento:'),
                  ),
                  DropdownButton<String>(
                    value: selectedPaymentOption,
                    items: formaPagamentoIcons.keys.map((forma) {
                      return DropdownMenuItem<String>(
                        value: forma,
                        child: Row(
                          children: [
                            Icon(
                              formaPagamentoIcons[forma],
                              color: Colors.blue,
                            ),
                            SizedBox(width: 8.0),
                            Text(forma),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentOption = value!;
                      });
                    },
                    hint: Text('Forma de Pagamento'),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                    icon: Icon(Icons.arrow_downward, color: Colors.blue),
                    elevation: 2,
                    isExpanded: true,
                    underline: Container(
                      height: 2,
                      color: Colors.blue,
                    ),
                  ),
                  Row(
                    children: [
                      Text('Pagou:'),
                      Checkbox(
                        value: pagou,
                        onChanged: (value) {
                          setState(() {
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
                    Navigator.of(context).pop();
                  },
                  child: Text('Voltar'),
                ),
                TextButton(
                  onPressed: () {
                    // Lógica para salvar as alterações
                    String novoMesAno = mesAnoController.text;
                    String novoVencimento = vencimentoController.text;
                    double novoValor = double.parse(valorController.text);

                    String novaFormaPagamento = selectedPaymentOption;

                    // Armazena a data de pagamento atual se Pagou for true
                    DateTime dataPagamento = infoFinanceira['pagou']
                        ? DateTime.now()
                        : (infoFinanceira['dataPagamento'] != null
                            ? DateTime.parse(infoFinanceira['dataPagamento'])
                            : DateTime.now());

                    // Remove a entrada antiga do array
                    FirebaseFirestore.instance
                        .collection('alunos')
                        .doc(widget.aluno.serie)
                        .collection('alunos')
                        .doc(widget.aluno.documentId)
                        .update({
                      'financeiro': FieldValue.arrayRemove([infoFinanceira]),
                    });

                    // Adiciona a entrada atualizada ao array
                    FirebaseFirestore.instance
                        .collection('alunos')
                        .doc(widget.aluno.serie)
                        .collection('alunos')
                        .doc(widget.aluno.documentId)
                        .update({
                      'financeiro': FieldValue.arrayUnion([
                        {
                          'mesAno': novoMesAno,
                          'vencimento': novoVencimento,
                          'valor': novoValor,
                          'pagou': pagou,
                          'dataPagamento': pagou
                              ? DateFormat('dd/MM/yyyy').format(dataPagamento)
                              : null,
                          'formaPagamento': novaFormaPagamento,
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
