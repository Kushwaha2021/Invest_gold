import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_model/gold_rate_view_model.dart';

class ChartTab extends StatelessWidget {
  const ChartTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GoldRateViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Gold Price Trends',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots:
                            viewModel.goldRates
                                .asMap()
                                .entries
                                .map(
                                  (e) =>
                                      FlSpot(e.key.toDouble(), e.value.buyRate),
                                )
                                .toList(),
                        isCurved: true,
                        dotData: const FlDotData(show: false),
                        barWidth: 2,
                        // Apply gradient to the buy rate line
                        gradient: const LinearGradient(
                          colors: [
                            Colors.amberAccent,
                            Colors.amber,
                            Colors.orange,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      LineChartBarData(
                        spots:
                            viewModel.goldRates
                                .asMap()
                                .entries
                                .map(
                                  (e) => FlSpot(
                                    e.key.toDouble(),
                                    e.value.sellRate,
                                  ),
                                )
                                .toList(),
                        isCurved: true,
                        dotData: const FlDotData(show: false),
                        barWidth: 2,
                        // Apply gradient to the sell rate line
                        gradient: const LinearGradient(
                          colors: [
                            Colors.blueAccent,
                            Colors.blue,
                            Colors.indigo,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((LineBarSpot spot) {
                            final index = spot.x.toInt();
                            if (index < 0 ||
                                index >= viewModel.goldRates.length) {
                              return null;
                            }
                            final rate = viewModel.goldRates[index];
                            final date = _formatDate(rate.date);
                            final value = spot.y.toStringAsFixed(2);
                            final text =
                                spot.barIndex == 0
                                    ? 'Buy: ₹$value/g\n$date'
                                    : 'Sell: ₹$value/g\n$date';
                            return LineTooltipItem(
                              text,
                              const TextStyle(color: Colors.white),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.circle, color: Colors.amber, size: 16),
                  const SizedBox(width: 8),
                  const Text('Buy Rate'),
                  const SizedBox(width: 16),
                  const Icon(Icons.circle, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  const Text('Sell Rate'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[parsedDate.month - 1]} ${parsedDate.day}, ${parsedDate.year}';
  }
}
