import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  TextEditingController dataNascimentoController = TextEditingController();
  TextEditingController valorMensalidadeController = TextEditingController();
  TextEditingController dataMatriculaController = TextEditingController();

  List<String> anexos = [];

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
              ),
              _buildTextField(
                valorMensalidadeController,
                'Valor da Mensalidade',
                keyboardType: TextInputType.number,
              ),
              _buildTextField(dataMatriculaController, 'Data da Matrícula'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _anexarDocumento(context);
                },
                child: Text('Anexar Documentos'),
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

  Widget _buildTextField(
    TextEditingController controller,
    String labelText, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      children: [
        TextField(
          controller: controller,
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

  Future<void> _anexarDocumento(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Anexar Documentos'),
          content: Column(
            children: [
              _buildAnexoButton('RG do Aluno'),
              _buildAnexoButton('RG do Responsável'),
              _buildAnexoButton('Comprovante de Residência'),
              _buildAnexoButton('Histórico Escolar'),
            ],
          ),
        );
      },
    );
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
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        anexos.add('$tipoDocumento: ${pickedFile.path}');
      });

      Navigator.of(context).pop();
    }
  }

  void _realizarMatricula() {
    // Adicione aqui a lógica para processar os dados da matrícula
    // Exemplo: imprimir os dados no console
    print('Nome: ${nomeController.text}');
    print('Nome do Pai: ${nomePaiController.text}');
    print('Nome da Mãe: ${nomeMaeController.text}');
    print('Série: ${serieController.text}');
    print('Data de Nascimento: ${dataNascimentoController.text}');
    print('Valor da Mensalidade: ${valorMensalidadeController.text}');
    print('Data da Matrícula: ${dataMatriculaController.text}');
    print('Documentos Anexados: $anexos');
  }
}
