import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final ImageProvider image;
  final Color borderColor;
  final Function()? onTap;
  final double widthW;
  final double heightH;

  MyCard({
    required this.title,
    required this.icon,
    required this.borderColor,
    required this.onTap,
    required this.image,
    required this.widthW,
    required this.heightH,
  });

  @override
  _MyCardState createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Defina um pequeno atraso para iniciar a animação de fade
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: Duration(milliseconds: 500), // Defina a duração da animação
        curve: Curves.easeIn, // Adicione uma curva para a animação
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xff2E71E8),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xff2E71E8).withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 15,
                    offset: Offset(0, 7), // changes position of shadow
                  ),
                ],
              ),
              child: SizedBox(
                width: 150,
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: widget.widthW,
                      height: widget.heightH,
                      decoration:
                          BoxDecoration(image: DecorationImage(image: widget.image)),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      widget.title,
                      style: GoogleFonts.nunito(
                        textStyle: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
