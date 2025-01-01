import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:voltage/voltagedatabasehelper.dart';

class StoredReadingsScreen extends StatefulWidget {
  @override
  _StoredReadingsScreenState createState() => _StoredReadingsScreenState();
}

class _StoredReadingsScreenState extends State<StoredReadingsScreen> {
  final VoltageDatabaseHelper _dbHelper = VoltageDatabaseHelper();
  List<Map<String, dynamic>> _readings = [];
  double _averageVoltage = 0.0;
  double _maxVoltage = 0.0;
  double _minVoltage = double.infinity;

  @override
  void initState() {
    super.initState();
    _loadReadings();
  }

  Future<void> _loadReadings() async {
    final readings = await _dbHelper.getAllReadings();
    setState(() {
      _readings = readings;
      if (_readings.isNotEmpty) {
        _averageVoltage = _readings.map((e) => e['voltage'] as double).reduce((a, b) => a + b) / _readings.length;
        _maxVoltage = _readings.map((e) => e['voltage'] as double).reduce((a, b) => a > b ? a : b);
        _minVoltage = _readings.map((e) => e['voltage'] as double).reduce((a, b) => a < b ? a : b);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stored Voltage Readings'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await _dbHelper.deleteAllReadings();
              setState(() => _readings.clear());
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('All readings deleted')));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Display Summary Statistics
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text('Average Voltage: ${_averageVoltage.toStringAsFixed(2)} V'),
                Text('Max Voltage: ${_maxVoltage.toStringAsFixed(2)} V'),
                Text('Min Voltage: ${_minVoltage.toStringAsFixed(2)} V'),
              ],
            ),
          ),
          // Graphical Representation of Readings
          Expanded(
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
                    color: Colors.blue,
                    barWidth: 2,
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
          // List of Readings
          Expanded(
            child: ListView.builder(
              itemCount: _readings.length,
              itemBuilder: (context, index) {
                final reading = _readings[index];
                return Card(
                  child: ListTile(
                    title: Text('${reading['voltage']} V'),
                    subtitle: Text('Timestamp: ${reading['timestamp']}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
