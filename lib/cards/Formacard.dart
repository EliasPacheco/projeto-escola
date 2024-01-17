import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adicionar Comunicados',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FormaCard(),
    );
  }
}

class FormaCard extends StatefulWidget {
  @override
  _FormaCardState createState() => _FormaCardState();
}

class _FormaCardState extends State<FormaCard> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  TextEditingController _dataController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedOption;

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
        _dataController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _enviarParaFirestore() async {
    try {
      if (_selectedOption != null) {
        // Criar um documento com data e hora dentro da subcoleção correspondente à opção
        await FirebaseFirestore.instance
            .collection('comunicados')
            .doc(_selectedOption)
            .collection('comunicados')
            .add({
          'titulo': _tituloController.text,
          'descricao': _descricaoController.text,
          'data': _dataController.text,
        });
      } else {
        print('Nenhuma opção selecionada.');
      }
    } catch (e) {
      print('Erro ao enviar dados para o Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Comunicados'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
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
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedOption = newValue;
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
                              Text('Título: ${_tituloController.text}'),
                              Text('Descrição: ${_descricaoController.text}'),
                              Text('Data: ${_dataController.text}'),
                              Text('Opção: ${_selectedOption ?? "Nenhuma opção selecionada"}'),
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
    );
  }
}
