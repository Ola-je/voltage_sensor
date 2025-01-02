import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:voltage/voltagedatabasehelper.dart';
import 'package:google_fonts/google_fonts.dart';

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
      if (_readings.isNotEmpty) {
        _averageVoltage = _readings.map((e) => e['voltage'] as double).reduce((a, b) => a + b) / _readings.length;
        _maxVoltage = _readings.map((e) => e['voltage'] as double).reduce((a, b) => a > b ? a : b);
        _minVoltage = _readings.map((e) => e['voltage'] as double).reduce((a, b) => a < b ? a : b);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen height to set the graph container height to half the screen height
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Stored Voltage Readings'),
      //   actions: [
      //     IconButton(
      //       icon: Icon(_showGraph ? Icons.list : Icons.show_chart),
      //       onPressed: () {
      //         setState(() {
      //           _showGraph = !_showGraph; // Toggle between graph and list
      //         });
      //       },
      //     ),
      //     IconButton(
      //       icon: Icon(Icons.delete),
      //       onPressed: () async {
      //         await _dbHelper.deleteAllReadings();
      //         setState(() => _readings.clear());
      //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('All readings deleted')));
      //       },
      //     ),
      //   ],
      // ),

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
            icon: Icon(_showGraph ? Icons.list : Icons.show_chart, color:  Color.fromARGB(255, 114, 174, 67)),
            onPressed: () {
              setState(() {
                _showGraph = !_showGraph; // Toggle between graph and list
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.delete, color:  Color.fromARGB(255, 114, 174, 67)),
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
          SizedBox(height: 20,),

          Text(
            'Stored Voltage Readings', 
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.start, // Use TextAlign.start for left alignment
          ),
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
          // Toggle between Graph and Readings List
          Expanded(
            child: _showGraph
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
                : ListView.builder(
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
