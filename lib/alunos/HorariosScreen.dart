import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HorariosScreen(),
    );
  }
}

class HorariosScreen extends StatefulWidget {
  @override
  _HorariosScreenState createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
      } else {
        print('Nenhuma imagem selecionada.');
      }
    });
  }

  void _openImage() {
    if (_selectedImage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoViewGallery(
            pageController: PageController(),
            backgroundDecoration: BoxDecoration(
              color: Colors.black,
            ),
            pageOptions: [
              PhotoViewGalleryPageOptions(
                imageProvider: FileImage(_selectedImage!),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Horários'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: _openImage,
              child: _selectedImage == null
                  ? Text('Nenhuma imagem selecionada.')
                  : Image.file(
                      _selectedImage!,
                      height: 350.0,
                      width: 350.0,
                      fit: BoxFit.cover,
                    ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Escolher Foto'),
            ),
          ],
        ),
      ),
    );
  }
}
