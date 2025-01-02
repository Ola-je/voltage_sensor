import 'package:flutter/material.dart';
import 'package:voltage/home_page.dart'; // Make sure to import your HomeScreen

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay for 2 seconds before navigating to the HomeScreen
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set a background color
      body: Center(
        child: Image.asset(
          'assets/images/ecospark_logo.png', // Update with your logo path
          width: 500, // Adjust the size of your logo
          height: 500, // Adjust the size of your logo
        ),
      ),
    );
  }
}
