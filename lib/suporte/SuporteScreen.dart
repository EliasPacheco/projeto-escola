import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SuporteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suporte'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              // Adicione alguma lógica para exibir informações adicionais, se necessário.
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Caso tenha alguma dúvida,',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Entre em contato por meio do WhatsApp',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => _launchWhatsApp(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              '(86) 98892-7030',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Nicolle Martins',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Direção',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchWhatsApp() async {
    final whatsappUrl = "https://wa.me/5586988927030";
    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      // Caso não seja possível abrir o WhatsApp, você pode lidar com isso aqui.
      print('Não foi possível abrir o WhatsApp.');
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: SuporteScreen(),
  ));
}
