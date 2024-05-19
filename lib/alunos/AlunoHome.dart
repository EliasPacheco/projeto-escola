import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:escola/editar/EditAluno.dart';
import 'package:flutter/material.dart';
import 'package:escola/alunos/BoletimScreen.dart';
import 'package:escola/alunos/MatriculaScreen.dart';

class Aluno {
  final String documentId;
  final String nome;
  final String serie;

  Aluno({
    required this.documentId,
    required this.nome,
    required this.serie,
  });

  Map<String, dynamic> toMap() {
    return {
      'documentId': documentId,
      'nome': nome,
      'serie': serie,
    };
  }
}

class AlunoHome extends StatefulWidget {
  final String userType;
  final Map<String, dynamic>? professorData;
  final Map<String, dynamic>? alunoData;

  const AlunoHome({
    Key? key,
    required this.userType,
    this.professorData,
    this.alunoData,
  }) : super(key: key);

  @override
  _AlunoHomeState createState() => _AlunoHomeState();
}

class _AlunoHomeState extends State<AlunoHome> {
  late List<Aluno> alunos;
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
  List<Aluno> alunosFiltrados = [];

  late Stream<List<Aluno>> alunosStream;

  bool _temConexaoInternet = true;
  Connectivity _connectivity = Connectivity();
  late String selectedAno;

  @override
  void initState() {
    super.initState();
    _verificarConexaoInternet();
    _monitorarConexao();
    _inicializarAnoSelecionado();
    alunosStream = buscarAlunosStream(selectedAno);
  }

  void _inicializarAnoSelecionado() {
    if (widget.userType == 'Professor' && widget.professorData != null) {
      selectedAno = widget.professorData!['series']?.isNotEmpty ?? false
          ? widget.professorData!['series'][0]
          : anos[0];
    } else if (widget.userType == 'Coordenacao') {
      selectedAno = anos[0];
    }
  }

  void _monitorarConexao() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _temConexaoInternet = result != ConnectivityResult.none;
        if (_temConexaoInternet) {
          alunosStream = buscarAlunosStream(selectedAno);
        }
      });
    });
  }

  Future<void> _verificarConexaoInternet() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    setState(() {
      _temConexaoInternet = connectivityResult != ConnectivityResult.none;
    });
  }

  void ordenarAlunosPorNome(List<Aluno> listaAlunos) {
    listaAlunos.sort((a, b) => a.nome.compareTo(b.nome));
  }

  Stream<List<Aluno>> buscarAlunosStream(String selectedAno) {
    return FirebaseFirestore.instance
        .collection('alunos')
        .doc(selectedAno)
        .collection('alunos')
        .snapshots()
        .map((QuerySnapshot querySnapshot) {
      List<Aluno> alunos = querySnapshot.docs.map((DocumentSnapshot document) {
        return Aluno(
          documentId: document.id,
          nome: (document['nome'] ?? '').toString(),
          serie: (document['serie'] ?? '').toString(),
        );
      }).toList();

      ordenarAlunosPorNome(alunos);

      return alunos;
    });
  }

  void filtrarAlunos(String query) {
    setState(() {
      if (query.isEmpty) {
        alunosStream = buscarAlunosStream(selectedAno);
      } else {
        alunosStream = buscarAlunosStream(selectedAno).map((alunos) {
          return alunos
              .where((aluno) =>
                  aluno.nome.toLowerCase().contains(query.toLowerCase()) &&
                  aluno.serie == selectedAno)
              .toList();
        });
      }
    });
  }

  void resetFiltro() {
    setState(() {
      alunosFiltrados =
          alunos.where((aluno) => aluno.serie == selectedAno).toList();
      alunosStream = buscarAlunosStream(selectedAno);
    });
  }

  void filtrarPorAno(String selectedAno) {
    setState(() {
      this.selectedAno = selectedAno;
      alunosStream = buscarAlunosStream(selectedAno);
    });
  }

  void exibirModalExcluirAluno(String alunoId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Excluir Aluno'),
          content: Text('Deseja excluir o aluno?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await excluirAluno(alunoId);
              },
              child: Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  Future<void> excluirAluno(String alunoId) async {
    try {
      print('Excluindo aluno com ID: $alunoId');
      await FirebaseFirestore.instance
          .collection('alunos')
          .doc(selectedAno)
          .collection('alunos')
          .doc(alunoId)
          .delete();

      print('Aluno excluído com sucesso');

      alunosStream = buscarAlunosStream(selectedAno);
    } catch (error) {
      print('Erro ao excluir aluno: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Alunos'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          if (widget.userType == 'Coordenacao' ||
              widget.userType == 'Professor')
            _buildAnoDropdown(),
        ],
      ),
      body: Column(
        children: [
          _buildSearchTextField(),
          Expanded(
            child: _buildAlunosList(),
          ),
        ],
      ),
      floatingActionButton: widget.userType == 'Coordenacao'
          ? _buildFloatingActionButton()
          : null,
    );
  }

  Widget _buildAnoDropdown() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<String>(
        value: selectedAno,
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              selectedAno = newValue;
            });

            filtrarPorAno(selectedAno);
          }
        },
        items: (widget.userType == 'Professor')
            ? widget.professorData!['series']
                .map<DropdownMenuItem<String>>(
                  (serie) => DropdownMenuItem<String>(
                    value: serie as String,
                    child: Text(serie),
                  ),
                )
                .toList()
            : (widget.userType == 'Coordenacao')
                ? anos
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList()
                : [],
      ),
    );
  }

  Widget _buildSearchTextField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            onChanged: (query) {
              if (query.isEmpty) {
                resetFiltro();
              } else {
                filtrarAlunos(query);
              }
            },
            decoration: InputDecoration(
              hintText: 'Pesquisar Alunos',
              prefixIcon: Icon(Icons.search),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlunosList() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      elevation: 4.0,
      margin: EdgeInsets.zero,
      child: StreamBuilder<List<Aluno>>(
        stream: alunosStream,
        builder: (context, snapshot) {
          if (!_temConexaoInternet) {
            return _buildNoInternetWidget();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.blue,));
          }

          alunos = snapshot.data ?? [];
          ordenarAlunosPorNome(alunos);
          alunosFiltrados =
              alunos.where((aluno) => aluno.serie == selectedAno).toList();

          if (alunosFiltrados.isEmpty) {
            return Center(
              child: Text('Sem alunos nessa turma'),
            );
          }

          return _buildAlunosListView();
        },
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: Color(0xff2E71E8),
      foregroundColor: Colors.white,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatriculaScreen(),
          ),
        );
      },
      child: Icon(Icons.add),
    );
  }

  Widget _buildNoInternetWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.signal_wifi_off,
            size: 50,
            color: Colors.red,
          ),
          SizedBox(height: 10),
          Text(
            'Sem conexão com a Internet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildAlunosListView() {
    return ListView.builder(
      itemCount: alunosFiltrados.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2.0,
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            title: Text(
              '${alunosFiltrados[index].nome}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Série: ${alunosFiltrados[index].serie}'),
            trailing: PopupMenuButton<String>(
              itemBuilder: (context) {
                return [
                  if (widget.userType == 'Coordenacao')
                    PopupMenuItem<String>(
                      value: 'opcao',
                      child: Text('Boletim'),
                    ),
                  if (widget.userType == 'Coordenacao')
                    PopupMenuItem<String>(
                      value: 'opcao2',
                      child: Text('Editar'),
                    ),
                  if (widget.userType == 'Coordenacao')
                    PopupMenuItem<String>(
                      value: 'opcao3',
                      child: Text('Excluir aluno'),
                    ),
                ];
              },
              onSelected: (String value) {
                if (value == 'opcao') {
                  if (widget.userType == 'Coordenacao') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BoletimScreen(
                          userType: widget.userType,
                          aluno: alunosFiltrados[index],
                        ),
                      ),
                    );
                  }
                } else if (value == 'opcao2') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditarAlunoScreen(
                          userType: widget.userType,
                          aluno: alunosFiltrados[index],
                        ),
                      ),
                    );
                } else if (value == 'opcao3') {
                  exibirModalExcluirAluno(alunosFiltrados[index].documentId);
                }
              },
            ),
          ),
        );
      },
    );
  }
}