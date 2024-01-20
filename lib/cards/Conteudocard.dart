import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ConteudoCard extends StatefulWidget {
  @override
  _ConteudoCardState createState() => _ConteudoCardState();
}

class _ConteudoCardState extends State<ConteudoCard> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _dataController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedOption;
  List<PlatformFile>? _files;

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

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          'docx',
          'doc',
          'pdf',
          'ppt',
          'pptx',
          'xls',
          'xlsx',
        ],
      );

      if (result != null) {
        setState(() {
          if (_files == null) {
            _files = [];
          }
          _files!.addAll(result.files);
        });
      }
    } catch (e) {
      print('Erro ao selecionar arquivos: $e');
    }
  }

  Future<void> _enviarParaFirestore() async {
    try {
      String data = _dataController.text;

      if (_selectedOption != null) {
        if (_selectedOption == 'Todas as turmas') {
          for (String turma in [
            'Maternal',
            'Infantil I',
            'Infantil II',
            '1º Ano',
            '2º Ano',
            '3º Ano',
            '4º Ano',
            '5º Ano',
            '6º Ano',
          ]) {
            await _enviarDocumentoParaFirestore(turma);
          }
        } else {
          await _enviarDocumentoParaFirestore(_selectedOption!);
        }
      } else {
        print('Nenhuma opção selecionada.');
      }

      // Limpa a lista de arquivos após o envio bem-sucedido
      setState(() {
        _files = null;
        _dataController.clear(); // Limpa o campo de data
      });
    } catch (e) {
      print('Erro ao enviar dados para o Firestore: $e');
    }
  }

  Future<String?> _uploadArquivo(
      PlatformFile? file, String turma, String data) async {
    try {
      if (file == null || file.path == null) {
        print('Arquivo ou caminho do arquivo nulo. O arquivo será ignorado.');
        return null;
      }

      File localFile = File(file.path!);

      if (!localFile.existsSync()) {
        print(
            'Arquivo não encontrado para ${file.name}. O arquivo será ignorado.');
        return null;
      }

      List<int> bytes = await localFile.readAsBytes();

      if (bytes.isEmpty) {
        print(
            'Bytes do arquivo são vazios para ${file.name}. O arquivo será ignorado.');
        return null;
      }

      firebase_storage.Reference storageReference =
          firebase_storage.FirebaseStorage.instance
              .ref()
              .child('arquivos')
              .child('$turma') // Substitua 'turma' pelo valor desejado
              .child('${DateTime.now().millisecondsSinceEpoch}_${file.name}');

      firebase_storage.UploadTask uploadTask =
          storageReference.putData(Uint8List.fromList(bytes));

      await uploadTask;

      String downloadUrl = await storageReference.getDownloadURL();

      if (downloadUrl != null) {
        return downloadUrl;
      } else {
        print('URL de download nula após o upload do arquivo.');
        return null;
      }
    } catch (e) {
      print('Erro ao fazer upload do arquivo: $e');
      return null;
    }
  }

  Future<void> _enviarDocumentoParaFirestore(String turma) async {
    try {
      List<String?> urls = [];

      // Adiciona os detalhes do documento no Firestore, incluindo a lista de arquivos
      for (var file in _files ?? []) {
        var url = await _uploadArquivo(file, turma, _dataController.text);
        if (url != null) {
          urls.add(url);
        }
      }

      await FirebaseFirestore.instance
          .collection('conteudos')
          .doc(turma)
          .collection('conteudos')
          .add({
        'data': _dataController.text,
        'arquivos': _files?.map((file) => file.name).toList() ?? [],
        'urls': urls,
      });

      // Limpa a lista de arquivos após o envio bem-sucedido
      setState(() {
        _files = null;
      });
    } catch (e) {
      print('Erro ao enviar dados para o Firestore: $e');
    }
  }

  List<Widget> _buildFileList() {
    if (_files?.isNotEmpty ?? false) {
      return _files!.map<Widget>((file) {
        return Row(
          children: [
            Expanded(
              child: Text(file.name ?? ''),
            ),
            IconButton(
              icon: Icon(Icons.clear),
              color: Colors.red,
              onPressed: () {
                setState(() {
                  _files!.remove(file);
                });
              },
            ),
          ],
        );
      }).toList();
    }

    return [Container()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Conteúdos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              ElevatedButton(
                onPressed: () {
                  _pickFiles();
                },
                child: Text('Adicionar Arquivos'),
              ),
              SizedBox(height: 16.0),
              // Exibição dinâmica dos arquivos selecionados
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildFileList(),
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
                  'Todas as turmas',
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
                              Text('Data: ${_dataController.text}'),
                              Text(
                                  'Opção: ${_selectedOption ?? "Nenhuma opção selecionada"}'),
                              if (_files != null)
                                Text(
                                    'Arquivos: ${_files!.map((file) => file.name).join(", ")}'),
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
                                // Limpa os controladores após chamar _enviarParaFirestore
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
