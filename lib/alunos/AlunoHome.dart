import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escola/alunos/MatriculaScreen.dart';
import 'package:escola/financeiro/FinanceiroScreen.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class Aluno {
  final String documentId;
  final String nome;
  final String serie;

  Aluno({
    required this.documentId,
    required this.nome,
    required this.serie,
  });
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

    // Adiciona a lógica para inicializar selectedAno com a primeira turma do professor
    if (widget.userType == 'Professor' && widget.professorData != null) {
      // Verifica se 'series' não é nulo e não está vazio
      if (widget.professorData!['series'] != null &&
          (widget.professorData!['series'] as List).isNotEmpty) {
        selectedAno = widget.professorData!['series'][0];
      } else {
        // Defina um valor padrão caso não haja turmas disponíveis
        selectedAno = anos[0];
      }
    }

    // Inicializa o stream ao selecionar o ano
    alunosStream = buscarAlunosStream(selectedAno);
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

  // Função para buscar os dados da coleção "alunos" no Firestore em forma de Stream
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

      // Ordenar a lista de alunos por nome
      ordenarAlunosPorNome(alunos);

      return alunos;
    });
  }

  void filtrarAlunos(String query) {
    setState(() {
      alunosFiltrados = alunos
          .where((aluno) =>
              aluno.nome.toLowerCase().contains(query.toLowerCase()) &&
              aluno.serie == selectedAno)
          .toList();
    });
  }

  void resetFiltro() {
    setState(() {
      alunosFiltrados =
          alunos.where((aluno) => aluno.serie == selectedAno).toList();
    });
  }

  void filtrarPorAno(String selectedAno) {
    setState(() {
      this.selectedAno = selectedAno;
      // Atualiza o stream com o novo ano selecionado
      alunosStream = buscarAlunosStream(selectedAno);
    });
  }

  void exibirModalPresencaFalta(String aluno) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String dataAtual = _getDataAtual();
        return AlertDialog(
          title: Text('Presença/Falta $dataAtual'),
          content: Text('$aluno está presente na aula?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Falta'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Adicione lógica para tratar a presença do aluno aqui
              },
              child: Text('Presente'),
            ),
          ],
        );
      },
    );
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

      // Atualiza a lista de alunos após a exclusão
      alunosStream = buscarAlunosStream(selectedAno);
    } catch (error) {
      print('Erro ao excluir aluno: $error');
    }
  }

  String _getDataAtual() {
    DateTime dataAtual = DateTime.now();
    String formattedDate =
        "${dataAtual.day.toString().padLeft(2, '0')}/${dataAtual.month.toString().padLeft(2, '0')}";
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    print(
        'Professor Data: ${widget.professorData ?? "Nenhum dado de professor"}');
    print('Tipo de usuário: ${widget.userType ?? "Nenhum tipo de usuário"}');

    print('Series: ${widget.professorData!['series']}');
    print('Anos: $anos');

    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Alunos'),
        actions: [
          if (widget.userType == 'Coordenacao' ||
              widget.userType == 'Professor')
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: selectedAno,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedAno = newValue;
                    });

                    // Chama a função para filtrar os alunos com base no novo ano selecionado
                    filtrarPorAno(selectedAno);
                  }
                },
                items: (widget.userType == 'Professor')
                    ? [
                        ...widget.professorData!['series']
                            .map<DropdownMenuItem<String>>((serie) {
                          return DropdownMenuItem<String>(
                            value: serie as String,
                            child: Text(serie),
                          );
                        }),
                      ]
                    : (widget.userType == 'Coordenacao')
                        ? anos.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList()
                        : [],
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
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
          ),
          Expanded(
            child: Card(
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

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  alunos = snapshot.data ?? [];
                  ordenarAlunosPorNome(alunos);
                  alunosFiltrados = alunos
                      .where((aluno) => aluno.serie == selectedAno)
                      .toList();

                  if (alunosFiltrados.isEmpty) {
                    return Center(
                      child: Text('Sem alunos nessa turma'),
                    );
                  }

                  return ListView.builder(
                    itemCount: alunosFiltrados.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('${alunosFiltrados[index].nome}'),
                        trailing: PopupMenuButton<String>(
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem<String>(
                                value: 'opcao1',
                                child: Text('Presença/Falta'),
                              ),
                              if (widget.userType == 'Coordenacao')
                                PopupMenuItem<String>(
                                  value: 'opcao2',
                                  child: Text('Boletim'),
                                ),
                              if (widget.userType == 'Coordenacao')
                                PopupMenuItem<String>(
                                  value: 'opcao3',
                                  child: Text('Financeiro'),
                                ),
                              if (widget.userType == 'Coordenacao')
                                PopupMenuItem<String>(
                                  value: 'opcao4',
                                  child: Text('Excluir aluno'),
                                ),
                            ];
                          },
                          onSelected: (String value) {
                            if (value == 'opcao1') {
                              exibirModalPresencaFalta(
                                  alunosFiltrados[index].nome);
                            } else if (value == 'opcao2') {
                              // Adicione lógica para a opção Boletim
                            } else if (value == 'opcao3') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FinanceiroScreen(
                                    userType: widget.userType,
                                    aluno: alunosFiltrados[index],
                                  ),
                                ),
                              );
                            } else if (value == 'opcao4') {
                              exibirModalExcluirAluno(
                                  alunosFiltrados[index].documentId);
                            }
                            ;
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: widget.userType == 'Coordenacao'
          ? FloatingActionButton(
              onPressed: () {
                // Adicione a lógica para adicionar novos avisos aqui
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MatriculaScreen(),
                  ),
                );
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}
