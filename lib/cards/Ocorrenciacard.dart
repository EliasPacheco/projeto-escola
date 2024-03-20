import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OcorrenciaCard extends StatefulWidget {
  @override
  _OcorrenciaCardState createState() => _OcorrenciaCardState();
}

class _OcorrenciaCardState extends State<OcorrenciaCard> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  TextEditingController _dataController = TextEditingController();
  TextEditingController _alunoController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedOption;
  List<String> _alunosDaOpcao = [];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dataController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  List<Map<String, dynamic>> _alunosDaSerieWithUid = [];

  Future<void> _carregarAlunosDaSerie() async {
    try {
      if (_selectedOption != null && _selectedOption != 'Aluno') {
        // Limpar a lista antes de carregar os novos alunos
        setState(() {
          _alunosDaSerieWithUid = [];
        });

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
      String dataAtual = DateFormat('dd/MM/yyyy').format(DateTime.now());
      if (_selectedOption != null) {
        String alunoUid = _alunosDaSerieWithUid.firstWhere(
            (aluno) => aluno['nome'] == _alunoController.text)['uid'];

        Map<String, dynamic> ocorrencia = {
          'titulo': _tituloController.text,
          'descricao': _descricaoController.text,
          'data': _dataController.text,
        };

        DocumentReference alunoRef = FirebaseFirestore.instance
            .collection('alunos')
            .doc(_selectedOption)
            .collection('alunos')
            .doc(alunoUid); // Usando o UID do aluno

        await alunoRef.update({
          'ocorrencias': FieldValue.arrayUnion([ocorrencia]),
        });

        await alunoRef.update({
          'notificacoes': FieldValue.arrayUnion([
            {'mensagem': 'Você recebeu uma ocorrência', 'data': dataAtual}
          ]),
        });

        _tituloController.clear();
        _descricaoController.clear();
        _dataController.clear();
        _alunoController.clear();
        _selectedOption = 'Selecione a opção';

        await Future.delayed(Duration(days: 15), () async {
          await alunoRef.update({
            'notificacoes': FieldValue.arrayRemove([
              {'mensagem': 'Você recebeu uma ocorrência', 'data': dataAtual}
            ]),
          });
        });
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
        title: Text('Adicionar Ocorrências'),
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
                TextFormField(
                  controller: _tituloController,
                  decoration: InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o título';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _descricaoController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a descrição';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                InkWell(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: TextFormField(
                    controller: _dataController,
                    decoration: InputDecoration(
                      labelText: 'Data',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a data';
                      }
                      return null;
                    },
                    onTap: () {
                      _selectDate(context);
                    },
                  ),
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
                  readOnly: true,
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
                                Text('Título: ${_tituloController.text}'),
                                Text('Descrição: ${_descricaoController.text}'),
                                Text('Data: ${_dataController.text}'),
                                Text(
                                    'Turma: ${_selectedOption ?? "Nenhuma opção selecionada"}'),
                                Text('Aluno: ${_alunoController.text}'),
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
                                  _tituloController.clear();
                                  _descricaoController.clear();
                                  _dataController.clear();
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
