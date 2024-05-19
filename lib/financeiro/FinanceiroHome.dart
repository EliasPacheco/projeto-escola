import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import 'package:escola/alunos/AlunoHome.dart' as AlunoHomePackage;
import 'package:escola/financeiro/FinanceiroScreen.dart';

class Aluno {
  final String documentId;
  final String nome;
  final String serie;
  final String vencimento;
  final bool pagou;
  List<Notificacao>? notificacoes;

  Aluno({
    required this.documentId,
    required this.nome,
    required this.serie,
    required this.vencimento,
    required this.pagou,
    this.notificacoes,
  });
}

class Notificacao {
  final String mensagem;
  final String data;

  Notificacao({
    required this.mensagem,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'mensagem': mensagem,
      'data': data,
    };
  }
}

class FinanceiroHome extends StatefulWidget {
  final String userType;
  final Map<String, dynamic>? professorData;

  const FinanceiroHome({
    Key? key,
    required this.userType,
    this.professorData,
  }) : super(key: key);

  @override
  _FinanceiroHomeState createState() => _FinanceiroHomeState();
}

class _FinanceiroHomeState extends State<FinanceiroHome> {
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
  String selectedAno = 'Maternal';
  List<Aluno> alunosFiltrados = [];
  bool _temConexaoInternet = true;
  Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    mesAno = _getDataAtual();
    mesAno = _getDataAtual2();
    buscarAlunos();
    _verificarConexaoInternet();
    _monitorarConexao();
  }

  void _monitorarConexao() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (mounted) {
        setState(() {
          _temConexaoInternet = result != ConnectivityResult.none;
          if (_temConexaoInternet) {
            // Add additional logic if needed
          }
        });
      }
    });
  }

  void _adicionarNotificacao(String alunoNome, String mensagem) {
    String dataAtual = DateFormat('dd/MM/yyyy').format(DateTime.now());

    // Encontrar o aluno na lista filtrada
    var aluno = alunosFiltrados.firstWhere((aluno) => aluno.nome == alunoNome);

    // Inicializar a lista de notificações se for nula
    aluno.notificacoes ??= [];

    // Criar uma nova instância de Notificacao com ID único
    Notificacao notificacao = Notificacao(
      mensagem: mensagem,
      data: dataAtual,
    );

    // Adicionar a notificação à lista de notificações
    aluno.notificacoes!.add(notificacao);

    // Atualizar a lista de alunosFiltrados com o aluno modificado
    alunosFiltrados = List.from(alunos);
  }

  void _enviarMensagem(String alunoNome) async {
    // Verificar se o aluno tem mensalidade em atraso no mês atual
    bool mensalidadeEmAtraso = alunosFiltrados
            .firstWhere((aluno) => aluno.nome == alunoNome)
            .notificacoes
            ?.any((notificacao) =>
                notificacao.data == mesAno &&
                notificacao.mensagem == "Sua mensalidade está atrasada.") ??
        false;

    if (mensalidadeEmAtraso) {
      // Aluno já recebeu mensagem para o mês atual
      print('Mensagem já enviada para este mês.');
      // Adicionar lógica para mostrar mensagem, se necessário
    } else {
      String mensagem = "Sua mensalidade está atrasada.";

      // Adicionar notificação ao aluno
      _adicionarNotificacao(alunoNome, mensagem);

      // Atualizar o documento no Firestore
      try {
        var aluno =
            alunosFiltrados.firstWhere((aluno) => aluno.nome == alunoNome);

        await FirebaseFirestore.instance
            .collection('alunos')
            .doc(selectedAno)
            .collection('alunos')
            .doc(aluno.documentId)
            .update({
          'notificacoes':
              FieldValue.arrayUnion([aluno.notificacoes!.last.toMap()]),
        });

        _agendarExclusaoMensagem(aluno.documentId, aluno.notificacoes!.last);
      } catch (e) {
        print('Erro ao enviar mensagem: $e');
        // Adicionar lógica para mostrar mensagem de erro, se necessário
      }
    }
  }

  void _agendarExclusaoMensagem(String alunoId, Notificacao notificacao) {
    Future.delayed(Duration(days: 15), () async {
      try {
        await FirebaseFirestore.instance
            .collection('alunos')
            .doc(selectedAno)
            .collection('alunos')
            .doc(alunoId)
            .update({
          'notificacoes': FieldValue.arrayRemove([notificacao.toMap()]),
        });
      } catch (e) {
        print('Erro ao excluir mensagem: $e');
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel(); // Cancel the subscription
    super.dispose();
  }

  Future<void> _verificarConexaoInternet() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    if (mounted) {
      setState(() {
        _temConexaoInternet = connectivityResult != ConnectivityResult.none;
      });
    }
  }

  void exibirModalPresencaFalta(String aluno) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enviar mensagem'),
          content: Text(
              'Deseja enviar uma mensagem para o $aluno para notificar atraso na mensalidade?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _enviarMensagem(aluno);
                // Add logic for sending the message
              },
              child: Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  late String mesAno;

  Future<void> buscarAlunos() async {
    mesAno = _getDataAtual();
    mesAno = _getDataAtual2();

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('alunos')
          .doc(selectedAno)
          .collection('alunos')
          .snapshots();

      querySnapshot.listen((snapshot) {
        if (mounted) {
          setState(() {
            alunos = snapshot.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;

              if (data.containsKey('financeiro')) {
                List<Map<String, dynamic>> financeiroData =
                    List<Map<String, dynamic>>.from(data['financeiro']);

                bool pagouAluno = financeiroData.any((element) {
                  String mesAnoAluno = element['mesAno'] ?? '';
                  print("O vencimento é " + mesAnoAluno);
                  return mesAnoAluno == mesAno && (element['pagou'] ?? false);
                });

                String vencimentoAluno = financeiroData.firstWhere(
                        (element) => element['mesAno'] == mesAno,
                        orElse: () => {'vencimento': ''})['vencimento'] ??
                    '';

                return Aluno(
                    documentId: document.id,
                    nome: (data['nome'] ?? '').toString(),
                    serie: (data['serie'] ?? '').toString(),
                    pagou: pagouAluno,
                    vencimento:
                        vencimentoAluno); // Usar a data de vencimento do aluno
              } else {
                return Aluno(
                    documentId: document.id,
                    nome: (data['nome'] ?? '').toString(),
                    serie: (data['serie'] ?? '').toString(),
                    pagou: false,
                    vencimento: mesAno);
              }
            }).toList();

            alunosFiltrados = List.from(alunos);
          });
        }
      });
    } catch (e) {
      print('Erro ao buscar alunos: $e');
    }
  }

  String _getDataAtual() {
    DateTime dataAtual = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(dataAtual);
    print(formattedDate);
    return formattedDate;
  }

  String _getDataAtual2() {
    DateTime dataAtual = DateTime.now();
    String formattedDate =
        "${dataAtual.month.toString().padLeft(2, '0')}/${dataAtual.year.toString()}";
    return formattedDate;
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

  void filtrarPorAno(String selectedAno) async {
    setState(() {
      this.selectedAno = selectedAno;
    });

    await buscarAlunos();

    setState(() {
      alunosFiltrados =
          alunos.where((aluno) => aluno.serie == selectedAno).toList();
    });
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

  Color _getAvatarColor(Map<String, dynamic> infoFinanceira) {
    String vencimentoString = infoFinanceira['vencimento'];

    try {
      DateTime dataVencimento =
          DateFormat('dd/MM/yyyy').parse(vencimentoString);

      bool pagou = infoFinanceira['pagou'] ?? false;

      // Verifica se o vencimento é hoje
      bool vencimentoHoje = _isVencimentoHoje(dataVencimento);

      // Verifica se o vencimento está atrasado
      bool vencimentoAtrasado = dataVencimento.isBefore(DateTime.now());

      // Define a cor com base no estado do pagamento e do vencimento
      if (pagou) {
        return Colors.green; // Verde se o pagamento foi feito
      } else {
        if (vencimentoHoje) {
          return Colors
              .orange; // Laranja se o vencimento é hoje e o pagamento não foi feito
        } else if (vencimentoAtrasado) {
          return Colors
              .red; // Vermelho se o vencimento passou e o pagamento não foi feito
        } else {
          return Colors
              .orange; // Laranja se o vencimento ainda não passou e o pagamento não foi feito
        }
      }
    } catch (e) {
      // Se ocorrer uma exceção ao tentar analisar a data, imprima o erro e retorne uma cor padrão
      print('Erro ao analisar a data: $e');
      return Colors.blue; // Cor padrão para datas inválidas
    }
  }

  Widget _buildAvatarContent(Color avatarColor, bool pagou) {
    if (avatarColor == Colors.blue) {
      // Se a cor for cinza, exibir "SF"
      return Text(
        'SF',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (avatarColor == Colors.orange){
      return Text(
        'AP',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }else {
      // Caso contrário, exibir o ícone de check se o pagamento foi feito, senão, exibir o ícone de erro
      return Icon(
        pagou ? Icons.check_circle : Icons.error,
        color: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    alunosFiltrados.sort((a, b) => a.nome.compareTo(b.nome));
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista Financeiro'),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: selectedAno,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedAno = newValue!;
                  });

                  filtrarPorAno(selectedAno);
                },
                items: (widget.userType == 'Professor')
                    ? widget.professorData!['series']
                        .map<DropdownMenuItem<String>>((serie) {
                        return DropdownMenuItem<String>(
                          value: serie as String,
                          child: Text(serie),
                        );
                      }).toList()
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
              child: _temConexaoInternet
                  ? alunosFiltrados.isEmpty
                      ? Center(
                          child: Text('Sem financeiro para essa turma'),
                        )
                      : ListView.builder(
                          itemCount: alunosFiltrados.length,
                          itemBuilder: (context, index) {
                            Color avatarColor = _getAvatarColor({
                              'pagou': alunosFiltrados[index].pagou,
                              'vencimento': alunosFiltrados[index].vencimento,
                            });

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              elevation: 4.0,
                              margin: EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: avatarColor,
                                      child: _buildAvatarContent(avatarColor,
                                          alunosFiltrados[index].pagou),
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Text(
                                      '${alunosFiltrados[index].nome}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            avatarColor, // Cor do texto igual à cor do CircleAvatar
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: widget.userType == 'Coordenacao'
                                    ? PopupMenuButton<String>(
                                        itemBuilder: (context) {
                                          return [
                                            PopupMenuItem<String>(
                                              value: 'opcao1',
                                              child: Text('Enviar mensagem'),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'opcao2',
                                              child: Text('Financeiro'),
                                            ),
                                          ];
                                        },
                                        onSelected: (String value) {
                                          if (value == 'opcao1') {
                                            exibirModalPresencaFalta(
                                                alunosFiltrados[index].nome);
                                          } else if (value == 'opcao2') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    FinanceiroScreen(
                                                  userType: widget.userType,
                                                  aluno: AlunoHomePackage.Aluno(
                                                    nome: alunosFiltrados[index]
                                                        .nome,
                                                    serie:
                                                        alunosFiltrados[index]
                                                            .serie,
                                                    documentId:
                                                        alunosFiltrados[index]
                                                            .documentId,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      )
                                    : null,
                              ),
                            );
                          },
                        )
                  : Center(
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
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
