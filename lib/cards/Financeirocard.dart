import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adicionar Finanças',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FinanceiroCard(),
    );
  }
}

class FinanceiroCard extends StatefulWidget {
  @override
  _FinanceiroCardState createState() => _FinanceiroCardState();
}

class _FinanceiroCardState extends State<FinanceiroCard> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _mesAnoController = TextEditingController();
  TextEditingController _vencimentoController = TextEditingController();
  TextEditingController _valorController = TextEditingController();
  TextEditingController _alunoController = TextEditingController();
  DateTime? _selectedMesAno;
  DateTime? _selectedVencimento;
  String? _selectedOption;
  List<String> _alunosDaOpcao = [];

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

  List<Map<String, dynamic>> _alunosDaSerieWithUid = [];

  Future<void> _carregarAlunosDaSerie() async {
    try {
      if (_selectedOption != null && _selectedOption != 'Aluno') {
        final QuerySnapshot<Map<String, dynamic>> querySnapshot =
            await FirebaseFirestore.instance
                .collection('alunos')
                .doc(_selectedOption)
                .collection('alunos')
                .get();

        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            _alunosDaSerieWithUid = querySnapshot.docs
                .map((doc) => {
                      'nome': doc['nome'] as String,
                      'uid': doc.id,
                    })
                .toList();
            print('Alunos da série ($_selectedOption): $_alunosDaSerieWithUid');
          });

          if (_alunosDaSerieWithUid.isEmpty) {
            print('Não há alunos na série: $_selectedOption');
          }
        }
      }
    } catch (e) {
      print('Erro ao carregar alunos da série: $e');
    }
  }

  Future<void> _enviarParaFirestore() async {
    try {
      if (_selectedOption != null) {
        String alunoUid = _alunosDaSerieWithUid.firstWhere(
            (aluno) => aluno['nome'] == _alunoController.text)['uid'];

        Map<String, dynamic> ocorrencia = {
          'mesAno': _mesAnoController.text,
          'vencimento': _vencimentoController.text,
          'valor': _valorController.text,
          'pagou': false,  // Adicionando a informação "pagou" como false
        };

        DocumentReference alunoRef = FirebaseFirestore.instance
            .collection('alunos')
            .doc(_selectedOption)
            .collection('alunos')
            .doc(alunoUid); // Usando o UID do aluno

        await alunoRef.update({
          'financeiro': FieldValue.arrayUnion([ocorrencia]),
        });

        _mesAnoController.clear();
        _vencimentoController.clear();
        _valorController.clear();
        _alunoController.clear();
        _selectedOption = null;
      } else {
        print('Nenhuma opção selecionada.');
      }
    } catch (e) {
      print('Erro ao enviar dados para o Firestore: $e');
    }
  }

  Future<void> _recuperarAlunosDaOpcao() async {
    try {
      if (_selectedOption != null) {
        final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
            await FirebaseFirestore.instance
                .collection('$_selectedOption')
                .doc('$_selectedOption')
                .get();

        if (documentSnapshot.exists) {
          final data = documentSnapshot.data();
          if (data != null && data.containsKey('alunos')) {
            setState(() {
              _alunosDaOpcao = List<String>.from(data['alunos']);
              print('Alunos da opção: $_alunosDaOpcao');
            });
          } else {
            print('Campo "alunos" não encontrado no documento.');
          }
        } else {
          print('Documento não encontrado.');
        }
      }
    } catch (e) {
      print('Erro ao recuperar alunos da opção: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Finanças'),
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
                DropdownButton<String>(
                  value: _selectedOption,
                  onChanged: (String? newValue) async {
                    setState(() {
                      _selectedOption = newValue;
                      // Ao selecionar uma nova série, carregue os alunos dessa série
                      _carregarAlunosDaSerie();
                    });
                  },
                  items: [
                    'Maternal',
                    'Infantil I',
                    'Infantil II',
                    '1º Ano',
                    '2º Ano',
                    '3º Ano',
                    '4º Ano',
                    '5º Ano',
                    '6º Ano',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  hint: Text('Selecione a opção'),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _alunoController,
                  decoration: InputDecoration(
                    labelText: 'Aluno',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome do aluno';
                    }
                    return null;
                  },
                  onTap: () async {
                    await _carregarAlunosDaSerie();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Alunos do $_selectedOption'),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _alunosDaSerieWithUid
                                  .map((aluno) => ListTile(
                                        title: Text(aluno['nome']),
                                        onTap: () {
                                          _alunoController.text = aluno[
                                              'nome']; // Exibe o nome no TextFormField
                                          Navigator.of(context).pop();
                                        },
                                      ))
                                  .toList(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Fechar'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _recuperarAlunosDaOpcao();
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
                                Text('Aluno: ${_alunoController.text}'),
                                Text(
                                    'Opção: ${_selectedOption ?? "Nenhuma opção selecionada"}'),
                                if (_selectedOption != null)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Alunos da opção:'),
                                      for (String aluno in _alunosDaOpcao)
                                        Text('- $aluno'),
                                    ],
                                  ),
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
                                  _alunoController.clear();
                                  _selectedOption = null;
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
