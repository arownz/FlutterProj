import 'package:flutter/material.dart';

class ProgressChartWidget extends StatelessWidget {
  final Map<String, double> progressData;
  final String title;
  final Color color;
  final double height;

  const ProgressChartWidget({
    super.key,
    required this.progressData,
    required this.title,
    this.color = Colors.blue,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: progressData.isEmpty
                    ? Center(
                        child: Text(
                          'No data available',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      )
                    : _buildProgressBars(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBars() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: progressData.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text('${entry.value.toStringAsFixed(1)}%'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: entry.value / 100,
                    backgroundColor: Colors.grey.shade200,
                    color: color,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
