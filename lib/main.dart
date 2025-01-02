import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
<<<<<<< HEAD
import 'package:voltage/real_time_voltage_app.dart';

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
      home: RealTimeVoltageApp(camera: camera),
=======
import 'package:voltage/screens/home_screen.dart';
=======
import 'package:voltage/real_time_voltage_app.dart';
>>>>>>> parent of 839ebd4 ( Update UI for Home Page)

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
<<<<<<< HEAD
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
>>>>>>> parent of 33b8be2 (Restore deleted files)
=======
      home: RealTimeVoltageApp(camera: camera),
>>>>>>> parent of 839ebd4 ( Update UI for Home Page)
    );
  }
}
