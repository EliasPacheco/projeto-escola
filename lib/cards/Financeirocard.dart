import 'package:escola/alunos/AlunoHome.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class FinanceiroCard extends StatefulWidget {
  final Aluno aluno;

  FinanceiroCard({
    Key? key,
    required this.aluno,
  }) : super(key: key);

  @override
  _FinanceiroCardState createState() => _FinanceiroCardState();
}

class _FinanceiroCardState extends State<FinanceiroCard> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _mesAnoController = TextEditingController();
  TextEditingController _vencimentoController = TextEditingController();
  TextEditingController _valorController = TextEditingController();

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller,
      {bool showDay = true}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      String formattedDate = showDay
          ? "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}"
          : "${picked.month.toString().padLeft(2, '0')}/${picked.year}";

      setState(() {
        controller.text = formattedDate;
      });
    }
  }

  Future<void> _enviarParaFirestore() async {
    try {
      Map<String, dynamic> ocorrencia = {
        'mesAno': _mesAnoController.text,
        'vencimento': _vencimentoController.text,
        'valor': _valorController.text,
        'pagou': false,
      };

      DocumentReference alunoRef = FirebaseFirestore.instance
          .collection('alunos')
          .doc(widget.aluno.serie)
          .collection('alunos')
          .doc(widget.aluno.documentId);

      await alunoRef.update({
        'financeiro': FieldValue.arrayUnion([ocorrencia]),
      });

      _mesAnoController.clear();
      _vencimentoController.clear();
      _valorController.clear();
    } catch (e) {
      print('Erro ao enviar dados para o Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Finanças'),
        flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlue],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    _selectDate(context, _mesAnoController, showDay: false);
                  },
                  child: TextFormField(
                    controller: _mesAnoController,
                    decoration: InputDecoration(
                      labelText: 'Mês/Ano',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o Mês/Ano';
                      }
                      return null;
                    },
                    onTap: () {
                      _selectDate(context, _mesAnoController, showDay: false);
                    },
                  ),
                ),
                SizedBox(height: 16.0),
                InkWell(
                  onTap: () {
                    _selectDate(context, _vencimentoController);
                  },
                  child: TextFormField(
                    controller: _vencimentoController,
                    decoration: InputDecoration(
                      labelText: 'Vencimento',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a data de Vencimento';
                      }
                      return null;
                    },
                    onTap: () {
                      _selectDate(context, _vencimentoController);
                    },
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _valorController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}$')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Valor',
                    border: OutlineInputBorder(),
                    prefixText: 'R\$ ',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o valor';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(text: widget.aluno.nome),
                  decoration: InputDecoration(
                    labelText: 'Aluno',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Dados do Formulário'),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Mês/Ano: ${_mesAnoController.text}'),
                                Text(
                                    'Vencimento: ${_vencimentoController.text}'),
                                Text('Valor: R\$ ${_valorController.text}'),
                                Text('Aluno: ${widget.aluno.nome}'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _enviarParaFirestore();
                                  _mesAnoController.clear();
                                  _vencimentoController.clear();
                                  _valorController.clear();
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text('Enviar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
