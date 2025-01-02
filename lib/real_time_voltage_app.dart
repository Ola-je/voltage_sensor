import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:voltage/storedreadingscreen.dart';
import 'package:voltage/voltagedatabasehelper.dart';
import 'package:google_fonts/google_fonts.dart';

class RealTimeVoltageApp extends StatefulWidget {
  final CameraDescription camera;

  RealTimeVoltageApp({required this.camera});

  @override
  _RealTimeVoltageAppState createState() => _RealTimeVoltageAppState();
}

class _RealTimeVoltageAppState extends State<RealTimeVoltageApp> {
  late CameraController _controller;
  late Timer _timer;
  List<double> _voltageReadings = [];
  double _averageVoltage = 0.0;
  double _maxVoltage = 0.0;
  double _minVoltage = double.infinity;
  double _stabilityIndex = 0.0;
  double _rateOfChange = 0.0;
  String _trend = 'Stable';
  double? _predictedVoltage;

  final double _maxThreshold = 240.0;
  final double _minThreshold = 180.0;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });

    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => captureAndProcessImage());
  }

  Future<void> captureAndProcessImage() async {
    try {
      final image = await _controller.takePicture();
      await processImage(image.path);
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  Future<void> processImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer();
    final dbHelper = VoltageDatabaseHelper();

    try {
      final recognizedText = await textRecognizer.processImage(inputImage);

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final voltage = RegExp(r'\d+(\.\d+)?').firstMatch(line.text)?.group(0);
          if (voltage != null) {
            final voltageValue = double.parse(voltage);

            // Store the reading in the database
            await dbHelper.insertReading(voltageValue);

            setState(() {
              // Update voltage readings
              _voltageReadings.add(voltageValue);
              if (_voltageReadings.length > 10) _voltageReadings.removeAt(0);

              // Update metrics
              _averageVoltage = _voltageReadings.reduce((a, b) => a + b) / _voltageReadings.length;
              _maxVoltage = _voltageReadings.reduce(max);
              _minVoltage = _voltageReadings.reduce(min);
              _stabilityIndex = _calculateStabilityIndex(_voltageReadings);

              // Calculate trend and prediction
              if (_voltageReadings.length > 1) {
                _rateOfChange = _voltageReadings.last - _voltageReadings[_voltageReadings.length - 2];
                _trend = _rateOfChange > 0
                    ? 'Increasing'
                    : _rateOfChange < 0
                    ? 'Decreasing'
                    : 'Stable';
              }
              _predictedVoltage = _predictNextVoltage(_voltageReadings);
            });
          }
        }
      }
    } catch (e) {
      print("Error processing image: $e");
    } finally {
      textRecognizer.close();
    }
  }


  double _calculateStabilityIndex(List<double> readings) {
    if (readings.isEmpty) return 0.0;
    double mean = readings.reduce((a, b) => a + b) / readings.length;
    double variance = readings.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) / readings.length;
    return sqrt(variance); // Standard deviation as stability index
  }

  double _predictNextVoltage(List<double> readings) {
    if (readings.length < 2) return readings.isNotEmpty ? readings.last : 0.0;

    // Use simple linear regression to predict the next voltage
    double n = readings.length.toDouble();
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

    for (int i = 0; i < readings.length; i++) {
      double x = i.toDouble();
      double y = readings[i];
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }

    double slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    double intercept = (sumY - slope * sumX) / n;

    return slope * n + intercept; // Predict the next value
  }

  void _showAlert(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) return Center(child: CircularProgressIndicator());

    return Scaffold(
appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
            icon: Icon(Icons.arrow_back_ios, color:  Color.fromARGB(255, 114, 174, 67),),
            onPressed: () {
              Navigator.pop(context);
            }
            ),
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
      ),      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: 0.5,
                child: CameraPreview(_controller),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: VoltageGraph(readings: _voltageReadings),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text('Average Voltage: ${_averageVoltage.toStringAsFixed(2)} V'),
                Text('Max Voltage: ${_maxVoltage.toStringAsFixed(2)} V'),
                Text('Min Voltage: ${_minVoltage.toStringAsFixed(2)} V'),
                Text('Stability Index: ${_stabilityIndex.toStringAsFixed(2)}'),
                Text('Rate of Change: ${_rateOfChange.toStringAsFixed(2)} V/sec'),
                Text('Trend: $_trend', style: TextStyle(fontSize: 16)),
                if (_predictedVoltage != null)
                  Text(
                    'Predicted Next Voltage: ${_predictedVoltage!.toStringAsFixed(2)} V',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: HistogramChart(readings: _voltageReadings),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }
}

class VoltageGraph extends StatelessWidget {
  final List<double> readings;

  VoltageGraph({required this.readings});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: readings.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
            isCurved: true,
            color: Colors.blue,
            dotData: FlDotData(show: false),
          )
        ],
      ),
    );
  }
}

class HistogramChart extends StatelessWidget {
  final List<double> readings;

  HistogramChart({required this.readings});

  @override
  Widget build(BuildContext context) {
    final bins = readings.fold<Map<int, int>>({}, (acc, v) {
      int bin = (v / 10).floor() * 10; // Group into bins of size 10
      acc[bin] = (acc[bin] ?? 0) + 1;
      return acc;
    });

    return BarChart(
      BarChartData(
        barGroups: bins.entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [BarChartRodData(toY: e.value.toDouble(), color: Colors.blue)],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) => Text('${value.toInt()}'),
            ),
          ),
        ),
      ),

    );
  }
}
