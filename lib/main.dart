import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
>>>>>>> parent of 33b8be2 (Restore deleted files)
    );
  }
}
