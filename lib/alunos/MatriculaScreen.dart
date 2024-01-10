import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matrícula',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MatriculaScreen(),
    );
  }
}

class MatriculaScreen extends StatefulWidget {
  @override
  _MatriculaScreenState createState() => _MatriculaScreenState();
}

class _MatriculaScreenState extends State<MatriculaScreen> {
  TextEditingController nomeController = TextEditingController();
  TextEditingController nomePaiController = TextEditingController();
  TextEditingController nomeMaeController = TextEditingController();
  TextEditingController serieController = TextEditingController();
  TextEditingController dataMatriculaController = TextEditingController();
  TextEditingController naturalidadeController = TextEditingController();
  TextEditingController enderecoResponsavel1Controller =
      TextEditingController();
  TextEditingController enderecoResponsavel2Controller =
      TextEditingController();
  TextEditingController cpfResponsavel2Controller = TextEditingController();
  TextEditingController telefoneResponsavel2Controller =
      TextEditingController();

  List<String> anexos = [];

  var dataNascimentoController = TextEditingController();
  var cpfResponsavel1Controller = TextEditingController();
  var telefoneResponsavel1Controller = TextEditingController();

  // Adicione os formatadores para os campos específicos
  var dataNascimentoFormatter = MaskTextInputFormatter(
      mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});
  var cpfFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
  var telefoneFormatter = MaskTextInputFormatter(
      mask: '(##) # ####-####', filter: {"#": RegExp(r'[0-9]')});

  bool isDocumentoAnexado = false;

  List<String> documentosAnexados = [];
  List<bool> botoesDesativados = [false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Matrícula'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(nomeController, 'Nome do Aluno'),
              _buildTextField(nomePaiController, 'Nome do Pai'),
              _buildTextField(nomeMaeController, 'Nome da Mãe'),
              _buildTextField(serieController, 'Série'),
              _buildTextField(
                dataNascimentoController,
                'Data de Nascimento',
                maskFormatter: dataNascimentoFormatter,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(naturalidadeController, 'Naturalidade'),
              _buildTextField(
                dataMatriculaController,
                'Data da Matrícula',
                maskFormatter: dataNascimentoFormatter,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              _buildTextField(
                  enderecoResponsavel1Controller, 'Endereço do Responsável 1'),
              _buildTextField(
                cpfResponsavel1Controller,
                'Cpf do responsável 1',
                keyboardType: TextInputType.number,
                maskFormatter: cpfFormatter,
              ),
              _buildTextField(
                telefoneResponsavel1Controller,
                'Telefone',
                keyboardType: TextInputType.phone,
                maskFormatter: telefoneFormatter,
              ),
              _buildTextField(
                  enderecoResponsavel2Controller, 'Endereço do Responsável 2'),
              _buildTextField(
                cpfResponsavel2Controller,
                'Cpf do responsável 2',
                keyboardType: TextInputType.number,
                maskFormatter: cpfFormatter,
              ),
              _buildTextField(
                telefoneResponsavel2Controller,
                'Telefone',
                keyboardType: TextInputType.phone,
                maskFormatter: telefoneFormatter,
              ),
              SizedBox(height: 10),
              if (isDocumentoAnexado)
                Column(
                  children: documentosAnexados
                      .asMap()
                      .entries
                      .map(
                        (entry) => Row(
                          children: [
                            Text(
                              'Documento Anexado: ${entry.value}',
                              style:
                                  TextStyle(color: Colors.green, fontSize: 14),
                            ),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                _removerDocumento(entry.key);
                              },
                              child: Icon(
                                Icons.close,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  _anexarDocumento(context, 'RG do Aluno', 0);
                },
                child: Text('Anexar RG do Aluno'),
                style: _getButtonStyle(0),
              ),
              ElevatedButton(
                onPressed: () {
                  _anexarDocumento(context, 'RG do Responsável', 1);
                },
                child: Text('Anexar RG do Responsável'),
                style: _getButtonStyle(1),
              ),
              ElevatedButton(
                onPressed: () {
                  _anexarDocumento(context, 'Comprovante de Residência', 2);
                },
                child: Text('Anexar Comprovante de Residência'),
                style: _getButtonStyle(2),
              ),
              ElevatedButton(
                onPressed: () {
                  _anexarDocumento(context, 'Histórico Escolar', 3);
                },
                child: Text('Anexar Histórico Escolar'),
                style: _getButtonStyle(3),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _realizarMatricula();
                },
                child: Text('Realizar Matrícula'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ButtonStyle _getButtonStyle(int index) {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.all(
        botoesDesativados[index] ? Colors.grey : Colors.blue,
      ),
      textStyle: MaterialStateProperty.all(
        TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText, {
    TextInputType keyboardType = TextInputType.text,
    MaskTextInputFormatter? maskFormatter,
  }) {
    return Column(
      children: [
        TextField(
          controller: controller,
          inputFormatters: maskFormatter != null ? [maskFormatter] : null,
          decoration: InputDecoration(
            labelText: labelText,
            border: OutlineInputBorder(),
          ),
          keyboardType: keyboardType,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  void _removerDocumento(int index) {
    setState(() {
      documentosAnexados.removeAt(index);
      if (documentosAnexados.isEmpty) {
        isDocumentoAnexado = false;
      }
      for (int i = 0; i < botoesDesativados.length; i++) {
        if (documentosAnexados.contains('RG do Aluno') && i == 0) {
          botoesDesativados[i] = true;
        } else if (documentosAnexados.contains('RG do Responsável') && i == 1) {
          botoesDesativados[i] = true;
        } else if (documentosAnexados.contains('Comprovante de Residência') &&
            i == 2) {
          botoesDesativados[i] = true;
        } else if (documentosAnexados.contains('Histórico Escolar') && i == 3) {
          botoesDesativados[i] = true;
        } else {
          botoesDesativados[i] = false;
        }
      }
    });
  }

  Future<void> _anexarDocumento(
      BuildContext context, String tipoDocumento, int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        documentosAnexados.add(tipoDocumento);
        isDocumentoAnexado = true;
        botoesDesativados[index] = true; // Desativa o botão após anexar
      });
    }
  }

  Widget _buildAnexoButton(String tipoDocumento) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton(
        onPressed: () {
          _selecionarArquivo(tipoDocumento);
        },
        child: Text('Anexar $tipoDocumento'),
      ),
    );
  }

  Future<void> _selecionarArquivo(String tipoDocumento) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        anexos.add('$tipoDocumento: ${pickedFile.path}');
        isDocumentoAnexado = true;
      });
    }
  }

  void _realizarMatricula() {
    print('Data da Matrícula: ${dataMatriculaController.text}');
    print('Série (Ano): ${serieController.text}');
    print('Nome do Aluno: ${nomeController.text}');
    print('Data de Nascimento: ${dataNascimentoController.text}');
    print('Naturalidade: ${naturalidadeController.text}');
    print('Nome do pai: ${nomePaiController.text}');
    print('Nome da mãe: ${nomeMaeController.text}');
    print('Endereço do Responsável 1: ${enderecoResponsavel1Controller.text}');
    print('Cpf do responsável 1: ${cpfResponsavel1Controller.text}');
    print('Telefone: ${telefoneResponsavel1Controller.text}');
    print('Endereço do Responsável 2: ${enderecoResponsavel2Controller.text}');
    print('Cpf do responsável 2: ${cpfResponsavel2Controller.text}');
    print('Telefone: ${telefoneResponsavel2Controller.text}');
    print('Documentos Anexados: $anexos');
  }
}
