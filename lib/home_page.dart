import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voltage/storedreadingscreen.dart';
import 'package:voltage/voltagedatabasehelper.dart';
import 'package:voltage/real_time_voltage_app.dart'; // Ensure this is correctly imported

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final VoltageDatabaseHelper _dbHelper = VoltageDatabaseHelper();
  List<Map<String, dynamic>> _readings = [];
  bool _showGraph = true; // To control whether the graph or the list is shown

  @override
  void initState() {
    super.initState();
    _loadReadings();
  }

  Future<void> _loadReadings() async {
    final readings = await _dbHelper.getAllReadings();
    setState(() {
      _readings = readings;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset('assets/images/ecospark_logo.png', width: 70),
            Expanded(
              child: Text(
                "EcoSpark",
                style: GoogleFonts.anton(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color:  Color.fromARGB(255, 114, 174, 67),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color:  Color.fromARGB(255, 114, 174, 67),),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StoredReadingsScreen()), // Navigate to history screen
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16),
            // Graph display
            Expanded(
              child: _readings.isNotEmpty
                  ? Container(
                      height: screenHeight / 2, // Set the height to half the screen height
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: _readings
                                  .asMap()
                                  .entries
                                  .map((e) => FlSpot(
                                        e.key.toDouble(),
                                        e.value['voltage'] as double,
                                      ))
                                  .toList(),
                              isCurved: true,
                              color:  Color.fromARGB(255, 114, 174, 67),
                              barWidth: 2,
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Center(child: CircularProgressIndicator()),
            ), // Show loading indicator if no data

            SizedBox(height: 50,)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final cameras = await availableCameras();
          if (cameras.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RealTimeVoltageApp(camera: cameras.first),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No camera available')),
            );
          }
        },
        label: Text("Create"),
        icon: Icon(Icons.add_a_photo),
        backgroundColor:  Color.fromARGB(255, 114, 174, 67),
      ),
    );
  }
}
