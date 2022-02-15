import 'package:flutter/material.dart';

import 'home.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();

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
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}
