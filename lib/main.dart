import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
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
    );
  }
}
