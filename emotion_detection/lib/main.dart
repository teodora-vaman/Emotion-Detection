import 'dart:io';

import 'package:flutter/material.dart';

import 'home.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

List<CameraDescription> cameras = [];

// void main() {
//   //WidgetsFlutterBinding.ensureInitialized();
//   //cameras = await availableCameras();

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Detect My Emotions!',
//       theme: ThemeData(
//         primaryColor: Colors.deepPurple,
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Color.fromARGB(255, 29, 29, 82),
//           foregroundColor: Color.fromARGB(255, 255, 255, 255),
//         ),
//       ),
//       home: ImageDetect(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

void main() => runApp(MaterialApp(
      home: ImageDetect(),
    ));

class ImageDetect extends StatefulWidget {
  const ImageDetect({Key? key}) : super(key: key);

  @override
  _ImageDetectState createState() => _ImageDetectState();
}

class _ImageDetectState extends State<ImageDetect> {
  List? _listResult;
  PickedFile? _imageFile;
  String? label_text = '';
  bool _loading = false;
  File img_path = File('your initial file');

  @override
  void initState() {
    super.initState();
    _loading = true;
    _loadModel();
  }

  void _loadModel() async {
    await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
    ).then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  void _imageClasification(PickedFile image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    print("------------------------------------------------------------");
    print(output);
    setState(() {
      _loading = false;
      _listResult = output;
      print(_listResult![0]['label']);
      label_text = output![0]['label'];
    });
  }

  void _imageSelection() async {
    var imageFile = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _loading = true;
      _imageFile = imageFile;
      img_path = File(imageFile!.path);
    });
    _imageClasification(imageFile!);
  }

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //       title: 'Welcome to Flutter',
  //       home: Scaffold(
  //           floatingActionButton: FloatingActionButton(
  //         onPressed: _imageSelection,
  //         backgroundColor: Colors.blue,
  //         child: Icon(Icons.add_photo_alternate_outlined),
  //       )));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Image Picker"),
        ),
        body: Container(
            child: _imageFile == null
                ? Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                          color: Colors.greenAccent,
                          onPressed: () {
                            _imageSelection();
                          },
                          child: Text("PICK FROM GALLERY"),
                        ),
                        Container(
                          height: 40.0,
                        ),
                        RaisedButton(
                          color: Colors.lightGreenAccent,
                          onPressed: () {
                            _getFromCamera();
                          },
                          child: Text("PICK FROM CAMERA"),
                        )
                      ],
                    ),
                  )
                : ListView(children: [
                    Container(
                      color: Colors.grey,
                      height: 400,
                      width: 100,
                      child: Image.file(
                        img_path,
                        fit: BoxFit.cover,
                      ),
                    ),
                    TextButton(
                      onPressed: nothing,
                      child: Text(
                          _listResult == null ? "eh" : label_text.toString()),
                    ),
                    TextButton(
                      onPressed: _imageSelection,
                      child: Text("Try Again"),
                    ),
                  ])));
  }

  /// Get from gallery
  void _getFromGallery() async {
    PickedFile? pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
        img_path = File(pickedFile.path);
      });
    }
  }

  void _getFromCamera() async {
    PickedFile? pickedFile =
        await ImagePicker().getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
        img_path = File(pickedFile.path);
      });
    }
  }

  void nothing() {}

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     title: 'Welcome to Flutter',
  //     home: Scaffold(
  //         appBar: AppBar(
  //           title: const Text('Welcome to Flutter'),
  //         ),
  //         body: const Center(
  //           child: Text('Hello World'),
  //         ),
  //         floatingActionButton: FloatingActionButton(
  //           onPressed: _imageSelection,
  //           backgroundColor: Colors.blue,
  //           child: Icon(Icons.add_photo_alternate_outlined),
  //         )),
  //   );
  // }
}
