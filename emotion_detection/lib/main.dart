import 'dart:io';

import 'package:flutter/material.dart';

import 'home.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

List<CameraDescription> cameras = [];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Detect My Emotions!',
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 29, 29, 82),
          foregroundColor: Color.fromARGB(255, 255, 255, 255),
        ),
      ),
      home: ImageDetect(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// void main() => runApp(MaterialApp(
//       home: ImageDetect(),
//     ));

class ImageDetect extends StatefulWidget {
  const ImageDetect({Key? key}) : super(key: key);

  @override
  _ImageDetectState createState() => _ImageDetectState();
}

class _ImageDetectState extends State<ImageDetect> {
  List? _listResult;
  var _printList = {'0': 0, "1": 0, '2': 0};
  PickedFile? _imageFile;
  String? label_text = '';
  String prediction_index = '';
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
    print("------------------------------------------------------");
    print(output);
    setState(() {
      _loading = false;
      _listResult = output;
      print(_listResult![0]['label']);
      final splitted = output![0]['label'].toString().split(' ');
      label_text = splitted[1];
      prediction_index = splitted[0];
      _printList[prediction_index] = _printList[prediction_index]! + 1;

      print(_printList);
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

  void _imageSelection_camera() async {
    var imageFile = await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      _loading = true;
      _imageFile = imageFile;
      img_path = File(imageFile!.path);
    });
    _imageClasification(imageFile!);
  }

  void _pushSaved() {
    Navigator.of(context).push(
      // Add lines from here...
      MaterialPageRoute<void>(
        builder: (context) {
          return Scaffold(
              appBar: AppBar(
                title: const Text('Autori'),
              ),
              body: ListView(children: [
                Padding(
                  padding: EdgeInsets.all(10.0),
                ),
                Text("Vaman Teodora", style: TextStyle(fontSize: 20)),
                Divider(),
                Text("Enache Cristian", style: TextStyle(fontSize: 20)),
                Divider(),
                Text("TAID - curs ASWTM 2022", style: TextStyle(fontSize: 15)),
              ]));
        },
      ), // ...to here.
    );
  }

  @override
  Widget build(BuildContext context) {
    Color mainColor = Color.fromARGB(255, 255, 255, 255);
    switch (prediction_index) {
      case '0':
        mainColor = Color.fromARGB(255, 212, 255, 199);
        break;
      case '1':
        mainColor = Color.fromARGB(255, 135, 186, 245);
        break;
      case '2':
        mainColor = Color.fromARGB(255, 255, 181, 218);
        break;
      default:
    }
    return Scaffold(
        appBar: AppBar(
          title: Text("Emotion Detection"),
          actions: [
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: _pushSaved,
              tooltip: 'Saved Suggestions',
            ),
          ],
        ),
        body: Container(
            color: (_listResult == null
                ? Color.fromARGB(255, 255, 255, 255)
                : mainColor),
            child: _imageFile == null
                ? Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Detect my Emotion!",
                            style: TextStyle(
                                color: Color.fromARGB(255, 29, 29, 82),
                                fontSize: 50,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),

                        Padding(
                          padding: EdgeInsets.all(30.0),
                        ),

                        //GALLERY
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            textStyle: TextStyle(color: Colors.white),
                            backgroundColor: Color.fromARGB(255, 29, 29, 82),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                          ),
                          onPressed: () => {_imageSelection()},
                          icon: const Icon(
                            Icons.photo,
                            color: Colors.white,
                          ),
                          label: const Text('Choose from Gallery',
                              style: TextStyle(
                                color: Colors.white,
                              )),
                        ),

                        //CAMERA
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            textStyle: TextStyle(color: Colors.blue),
                            backgroundColor: Color.fromARGB(255, 29, 29, 82),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                          ),
                          onPressed: () => {_imageSelection_camera()},
                          icon: const Icon(
                            Icons.photo_camera,
                            color: Colors.white,
                          ),
                          label: const Text('Choose from Camera',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  )
                //ELSE
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

                    Padding(
                      padding: EdgeInsets.all(15.0),
                    ),

                    Text(
                      _listResult == null ? "eh" : label_text.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 29, 29, 82),
                          fontSize: 70,
                          fontWeight: FontWeight.bold),
                    ),

                    Padding(
                      padding: EdgeInsets.all(40.0),
                    ),
                    //GALLERY
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        textStyle: TextStyle(color: Colors.white),
                        backgroundColor: Color.fromARGB(255, 29, 29, 82),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                      ),
                      onPressed: () => {_imageSelection()},
                      icon: const Icon(
                        Icons.photo,
                        color: Colors.white,
                      ),
                      label: const Text('Choose from Gallery',
                          style: TextStyle(
                            color: Colors.white,
                          )),
                    ),
                    //CAMERA
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        textStyle: TextStyle(color: Colors.blue),
                        backgroundColor: Color.fromARGB(255, 29, 29, 82),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                      ),
                      onPressed: () => {_imageSelection_camera()},
                      icon: const Icon(
                        Icons.photo_camera,
                        color: Colors.white,
                      ),
                      label: const Text('Choose from Camera',
                          style: TextStyle(color: Colors.white)),
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
}

class OpenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Size rectSize = Size(500, 500);
    var paint1 = Paint()
      ..color = Color(0xff995588)
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Offset(0, 0) & rectSize, paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

/// The base class for the different types of items the list can contain.
abstract class ListItem {
  /// The title line to show in a list item.
  Widget buildTitle(BuildContext context);

  /// The subtitle line, if any, to show in a list item.
  Widget buildSubtitle(BuildContext context);
}

/// A ListItem that contains data to display a heading.
class HeadingItem implements ListItem {
  final String heading;

  HeadingItem(this.heading);

  @override
  Widget buildTitle(BuildContext context) {
    return Text(
      heading,
      style: Theme.of(context).textTheme.headline5,
    );
  }

  @override
  Widget buildSubtitle(BuildContext context) => const SizedBox.shrink();
}

/// A ListItem that contains data to display a message.
class MessageItem implements ListItem {
  final String sender;
  final String body;

  MessageItem(this.sender, this.body);

  @override
  Widget buildTitle(BuildContext context) => Text(sender);

  @override
  Widget buildSubtitle(BuildContext context) => Text(body);
}
