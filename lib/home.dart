import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escola/Login.dart';
import 'package:escola/alunos/AgendaScreen.dart';
import 'package:escola/alunos/AlunoHome.dart';
import 'package:escola/alunos/ChatHome.dart';
import 'package:escola/alunos/ChatScreen.dart';
import 'package:escola/alunos/ConteudosScreen.dart';
import 'package:escola/alunos/Horarioprofessor.dart';
import 'package:escola/alunos/HorariosScreen.dart';
import 'package:escola/alunos/MatriculaScreen.dart';
import 'package:escola/alunos/AvisosScreen.dart';
import 'package:escola/alunos/OcorrenciasScreen.dart';
import 'package:escola/alunos/StudentScreen.dart';
import 'package:escola/cards/Ocorrenciacard.dart';
import 'package:escola/financeiro/FinanceiroHome.dart';
import 'package:escola/financeiro/FinanceiroScreen.dart';
import 'package:escola/funcionarios/Cadastrarfuncionario.dart';
import 'package:escola/my_card.dart';
import 'package:escola/suporte/SuporteScreen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:escola/alunos/AlunoHome.dart' as AlunoHomePackage;
import 'package:google_fonts/google_fonts.dart';

class MySchoolApp extends StatefulWidget {
  final String matriculaCpf;
  final Map<String, dynamic>? alunoData;
  final Map<String, dynamic>? professorData;
  final String userType;

  const MySchoolApp({
    Key? key,
    required this.matriculaCpf,
    this.alunoData,
    required this.userType,
    this.professorData,
  }) : super(key: key);

  @override
  State<MySchoolApp> createState() => _MySchoolAppState();
}

class _MySchoolAppState extends State<MySchoolApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(
        matriculaCpf: widget.matriculaCpf,
        alunoData: widget.alunoData,
        userType: widget.userType,
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        'alunos/AlunoHome': (context) => AlunoHome(
              userType: widget.userType,
              professorData: widget.professorData,
              alunoData: widget.alunoData,
            ),
        'financeiro/FinanceiroHome': (context) => FinanceiroHome(
              userType: widget.userType,
              professorData: widget.professorData,
            ),
        'financeiro/FinanceiroScreen': (context) => FinanceiroScreen(
              userType: widget.userType,
              aluno: AlunoHomePackage.Aluno(
                nome: widget.alunoData?['nome'],
                serie: widget.alunoData?['serie'],
                documentId: widget.alunoData?['uid'],
              ),
            ),
        'alunos/AvisosScreen': (context) => AvisosHome(
              matriculaCpf: widget.matriculaCpf,
              alunoData: widget.alunoData,
              userType: widget.userType,
              professorData: widget.professorData,
            ),
        'alunos/MatriculaScreen': (context) => MatriculaScreen(),
        'alunos/OcorrenciasScreen': (context) => OcorrenciasScreen(
              matriculaCpf: widget.matriculaCpf,
              alunoData: widget.alunoData,
              userType: widget.userType,
            ),
        'alunos/ConteudosScreen': (context) => ConteudosScreen(
              matriculaCpf: widget.matriculaCpf,
              alunoData: widget.alunoData,
              userType: widget.userType,
              professorData: widget.professorData,
            ),
        'suporte/SuporteScreen': (context) => SuporteScreen(),
        'alunos/ChatScreen': (context) => ChatScreen(
              matriculaCpf: widget.matriculaCpf,
              alunoData: widget.alunoData,
              userType: widget.userType,
            ),
        'alunos/ChatHome': (context) => ChatHome(
              matriculaCpf: widget.matriculaCpf,
              alunoData: widget.alunoData,
              userType: widget.userType,
            ),
        'alunos/HorariosScreen': (context) => HorariosScreen(
              matriculaCpf: widget.matriculaCpf,
              alunoData: widget.alunoData,
              userType: widget.userType,
              professorData: widget.professorData,
            ),
        'Login': (context) => LoginPage(),
        'alunos/StudentScreen': (context) => StudentScreen(
              matriculaCpf: widget.matriculaCpf,
              alunoData: widget.alunoData,
              userType: widget.userType,
            ),
        'alunos/AgendaScreen': (context) => AgendaScreen(
              matriculaCpf: widget.matriculaCpf,
              alunoData: widget.alunoData,
              userType: widget.userType,
              professorData: widget.professorData,
            ),
        'alunos/HorarioProfessor': (context) => HorarioProfessor(
              matriculaCpf: widget.matriculaCpf,
              alunoData: widget.alunoData,
              userType: widget.userType,
              professorData: widget.professorData,
            ),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String matriculaCpf;
  final Map<String, dynamic>? alunoData;
  final String userType;
  final Map<String, dynamic>? professorData;

  MyHomePage({
    Key? key,
    required this.matriculaCpf,
    this.alunoData,
    required this.userType,
    this.professorData,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool get isAluno => widget.alunoData != null;

  bool get isProfessor => widget.alunoData == null && !isAluno;

  bool get isCoordenacao =>
      widget.alunoData == null && !isAluno && !isProfessor;

  void _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(
        context,
        'Login',
        arguments: {
          'professorData': widget.professorData,
        },
      );
    } catch (e) {
      print('Erro ao fazer logout: $e');
      // Trate o erro, mostre uma mensagem, etc.
    }
  }

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    print('Tipo de usuário: ${widget.userType}');
    print('alunoData: ${widget.alunoData?["notificacoes"]}');

    bool isAluno = widget.userType == 'Aluno';
    bool isProfessor = widget.userType == 'Professor';
    bool isCoordenacao = widget.userType == 'Coordenacao';
    Image noti = Image.asset('assets/noti.png');
    Image livros = Image.asset('assets/livros.png');
    Image suporte = Image.asset('assets/suporte.png');
    Image relogio = Image.asset('assets/relogio.png');
    Image chat = Image.asset('assets/chat.png');
    Image aviso = Image.asset('assets/aviso.png');

    print('isAluno: $isAluno');
    print('isProfessor: $isProfessor');
    print('isCoordenacao: $isCoordenacao');

    Stream<DocumentSnapshot<Map<String, dynamic>>> _notificationStream =
        FirebaseFirestore.instance
            .collection('alunos')
            .doc(widget.alunoData?['serie'])
            .collection('alunos')
            .doc(widget.alunoData?['uid'])
            .snapshots();

    void _showNotificationsDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Notificações'),
            content: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('alunos')
                  .doc(widget.alunoData?['serie'])
                  .collection('alunos')
                  .doc(widget.alunoData?['uid'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Wrap CircularProgressIndicator in Container or Center
                  return Container(
                    height: 50,
                    width: 50,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  print("Error: ${snapshot.error}");
                  return Text("Error loading data");
                }

                var data = snapshot.data?.data() ?? {};
                var notificacoes = (data['notificacoes'] as List<dynamic>?)
                        ?.cast<Map<String, dynamic>>() ??
                    [];

                notificacoes.sort((a, b) => b['data'].compareTo(a['data']));

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      for (var notificacao in notificacoes)
                        Card(
                          elevation: 2,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              notificacao['mensagem'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              notificacao['data'],
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: () {
                                // Show confirmation dialog before deleting
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Excluir Notificação'),
                                      content: Text(
                                        'Tem certeza que deseja excluir esta notificação?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            var notificationReference =
                                                FirebaseFirestore.instance
                                                    .collection('alunos')
                                                    .doc(widget
                                                        .alunoData?['serie'])
                                                    .collection('alunos')
                                                    .doc(widget
                                                        .alunoData?['uid']);

                                            // Delete the notification from the array
                                            await notificationReference.update({
                                              'notificacoes':
                                                  FieldValue.arrayRemove(
                                                      [notificacao]),
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Text('Excluir'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Fechar'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 10,
            offset: const Offset(1, 1), // changes position of shadow
          ),
        ]),
        child: BottomNavigationBar(
            selectedLabelStyle: GoogleFonts.nunito(
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            unselectedLabelStyle: GoogleFonts.nunito(
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            fixedColor: Colors.black,
            unselectedItemColor: Colors.black,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              setState(() {
                _selectedIndex = index; // Atualize o índice selecionado
              });
              if (_selectedIndex == 0) {
                Navigator.pushNamed(context, 'alunos/MySchoolApp');
              }
              if (_selectedIndex == 1) {
                Navigator.pushNamed(context, 'alunos/AgendaScreen');
              }
              if (_selectedIndex == 2) {
                if (widget.userType == 'Aluno') {
                  Navigator.pushNamed(context, 'financeiro/FinanceiroScreen');
                } else if (widget.userType == 'Coordenacao') {
                  Navigator.pushNamed(context, 'financeiro/FinanceiroHome');
                } else if (widget.userType == 'Professor') {
                  Navigator.pushNamed(context, 'alunos/AlunoHome');
                }
              }
              if (_selectedIndex == 3) {
                if (widget.userType == 'Aluno') {
                  Navigator.pushNamed(context, 'alunos/StudentScreen');
                } else if (widget.userType == 'Coordenacao' ||
                    widget.userType == 'Professor') {
                  Navigator.pushNamed(context, 'alunos/AlunoHome');
                }
              }
            },
            items: _buildBottomNavigationBarItems()),
      ),
      appBar: AppBar(
        title: Container(
          padding: EdgeInsets.only(
            left: 20,
            top: 15,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Olá,',
                    style: GoogleFonts.nunito(
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    // Utilize o dado da pessoa que faz login e coloque seu nome para ser exibido aqui
                    widget.userType == 'Aluno'
                        ? '${widget.alunoData?['nome'].toString().split(' ')[0]}'
                        : widget.userType == 'Professor'
                            ? 'Professor'
                            : 'Coordenação',
                    style: GoogleFonts.nunito(
                      textStyle: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              widget.userType == 'Coordenacao' || widget.userType == 'Professor'
                  ? IconButton(
                      icon: Icon(Icons.exit_to_app),
                      color: Colors.red,
                      iconSize: 30,
                      onPressed: () {
                        _signOut(context);
                      },
                    )
                  : Stack(
                      children: [
                        IconButton(
                          icon: Icon(Icons.notifications),
                          color: Colors.yellow,
                          iconSize: 48,
                          onPressed: _showNotificationsDialog,
                        ),
                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: _notificationStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(); // Placeholder widget while waiting
                            }

                            if (snapshot.hasError) {
                              return Text("Error loading data");
                            }

                            var data = snapshot.data?.data() ?? {};
                            var notificacoes =
                                (data['notificacoes'] as List<dynamic>?)
                                        ?.cast<Map<String, dynamic>>() ??
                                    [];

                            int _notificationCount = notificacoes.length;

                            return _notificationCount > 0
                                ? Positioned(
                                    right: 12,
                                    top: 8,
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      constraints: BoxConstraints(
                                        minWidth: 16,
                                      ),
                                      child: Center(
                                        child: Text(
                                          _notificationCount.toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(); // If no notifications, show an empty container
                          },
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: GridView.count(
            crossAxisCount: 2,
            padding: EdgeInsets.only(left: 15, right: 15),
            children: [
              MyCard(
                title: 'Comunicados',
                icon: FontAwesomeIcons.bell,
                borderColor: Colors.white,
                image: noti.image,
                widthW: 50,
                heightH: 50,
                onTap: () {
                  Navigator.pushNamed(context, 'alunos/AvisosScreen');
                },
              ),
              if (widget.userType != 'Professor')
                MyCard(
                  title: 'Ocorrências',
                  icon: FontAwesomeIcons.circleExclamation,
                  borderColor: Colors.white,
                  image: aviso.image,
                  widthW: 50,
                  heightH: 50,
                  onTap: () {
                    print('Detalhes do alunoData enviado: ${widget.alunoData}');
                    if (widget.userType == 'Aluno') {
                      Navigator.pushNamed(
                        context,
                        'alunos/OcorrenciasScreen',
                        arguments: {
                          'matriculaCpf': widget.matriculaCpf,
                          'alunoData': widget.alunoData,
                          'userType': widget.userType,
                          'professorData': widget.professorData,
                        },
                      );
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OcorrenciaCard()));
                    }
                  },
                ),
              MyCard(
                title: 'Conteúdos',
                icon: FontAwesomeIcons.book,
                borderColor: Colors.white,
                image: livros.image,
                widthW: 60,
                heightH: 60,
                onTap: () {
                  Navigator.pushNamed(context, 'alunos/ConteudosScreen');
                },
              ),
              if (widget.userType != 'Professor')
                MyCard(
                  title: 'Chat',
                  icon: FontAwesomeIcons.solidCommentDots,
                  borderColor: Colors.white,
                  image: chat.image,
                  widthW: 50,
                  heightH: 50,
                  onTap: () {
                    if (widget.userType == 'Aluno') {
                      Navigator.pushNamed(context, 'alunos/ChatScreen');
                    } else {
                      Navigator.pushNamed(context, 'alunos/ChatHome');
                    }
                  },
                ),
              MyCard(
                title: 'Horários',
                icon: FontAwesomeIcons.calendarAlt,
                borderColor: Colors.white,
                image: relogio.image,
                widthW: 50,
                heightH: 50,
                onTap: () {
                  if (isCoordenacao) {
                    String selectedRoute =
                        ''; // Variável para armazenar a rota escolhida

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Qual horário deseja acessar?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                selectedRoute = 'alunos/HorariosScreen';
                                Navigator.pop(context); // Fecha o AlertDialog
                              },
                              child: Text('Aluno'),
                            ),
                            TextButton(
                              onPressed: () {
                                selectedRoute = 'alunos/HorarioProfessor';
                                Navigator.pop(context); // Fecha o AlertDialog
                              },
                              child: Text('Professor'),
                            ),
                          ],
                        );
                      },
                    ).then((value) {
                      // Faça a navegação fora do AlertDialog
                      if (selectedRoute.isNotEmpty) {
                        Navigator.pushNamed(context, selectedRoute);
                      }
                    });
                  } else if (isProfessor) {
                    Navigator.pushNamed(
                      context,
                      'alunos/HorarioProfessor',
                    );
                  } else {
                    Navigator.pushNamed(context, 'alunos/HorariosScreen');
                  }
                },
              ),
              if (widget.userType != 'Professor')
                MyCard(
                  title: 'Suporte',
                  icon: FontAwesomeIcons.solidCircleUser,
                  borderColor: Colors.white,
                  widthW: 60,
                  heightH: 60,
                  image: suporte.image,
                  onTap: () {
                    Navigator.pushNamed(context, 'suporte/SuporteScreen');
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: widget.userType == 'Coordenacao'
          ? FloatingActionButton(
              backgroundColor: Color(0xff2E71E8),
              foregroundColor: Colors.white,
              onPressed: () {
                // Adicione a lógica para adicionar novos avisos aqui
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CadastroFuncionarioScreen(),
                  ),
                );
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  List<BottomNavigationBarItem> _buildBottomNavigationBarItems() {
    // Define BottomNavigationBarItems excluindo "Financeiro" para Professor
    List<BottomNavigationBarItem> items = [
      BottomNavigationBarItem(
        icon: FaIcon(
          FontAwesomeIcons.house,
          color: Colors.black,
        ),
        label: 'Inicio',
      ),
      BottomNavigationBarItem(
        icon: Icon(
          Icons.calendar_today,
          color: Colors.black,
        ),
        label: 'Agenda',
      ),
      if (widget.userType != 'Professor')
        BottomNavigationBarItem(
          icon: Icon(
            Icons.monetization_on,
            color: Colors.black,
          ),
          label: 'Financeiro',
        ),
      widget.userType == 'Coordenacao'
          ? BottomNavigationBarItem(
              icon: FaIcon(
                FontAwesomeIcons.userGraduate,
                color: Colors.black,
              ),
              label: 'Alunos',
            )
          : BottomNavigationBarItem(
              icon: FaIcon(
                FontAwesomeIcons.userGraduate,
                color: Colors.black,
              ),
              label: 'Perfil',
            )
    ];

    return items;
  }
}
