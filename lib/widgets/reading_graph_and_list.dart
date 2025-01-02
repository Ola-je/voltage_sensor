import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:voltage/voltagedatabasehelper.dart';

class ReadingsGraphAndList extends StatelessWidget {
  final List<Map<String, dynamic>> readings;
  final double averageVoltage;
  final double maxVoltage;
  final double minVoltage;
  final bool showGraph;
  final Function toggleView;

  ReadingsGraphAndList({
    required this.readings,
    required this.averageVoltage,
    required this.maxVoltage,
    required this.minVoltage,
    required this.showGraph,
    required this.toggleView,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text('Average Voltage: ${averageVoltage.toStringAsFixed(2)} V'),
              Text('Max Voltage: ${maxVoltage.toStringAsFixed(2)} V'),
              Text('Min Voltage: ${minVoltage.toStringAsFixed(2)} V'),
            ],
          ),
        ),
        // Toggle between Graph and Readings List
        Expanded(
          child: showGraph
              ? Container(
                  height: screenHeight / 2, // Set the height to half the screen height
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: readings
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
                )
              : ListView.builder(
                  itemCount: readings.length,
                  itemBuilder: (context, index) {
                    final reading = readings[index];
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
    );
  }
}
