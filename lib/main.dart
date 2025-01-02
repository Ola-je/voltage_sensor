import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:voltage/home_page.dart';  // Updated import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(camera: cameras.first));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  MyApp({required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),  // HomeScreen as the initial screen
      debugShowCheckedModeBanner: false,
    );
  }
}
