import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class SummaryCard extends StatelessWidget {
  final int totalItems;
  final double totalEnergy;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalSugars;
  final double totalSodium;
  final double totalFiber;

  const SummaryCard({
    super.key,
    required this.totalItems,
    required this.totalEnergy,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalSugars,
    required this.totalSodium,
    required this.totalFiber,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, top: 12),
      child: Column(
        children: [
          PieChart(
            animationDuration: const Duration(milliseconds: 850),
            dataMap: {
              'Protein (g)': totalProtein,
              'Fat (g)': totalFat,
              'Sodium (g)': totalSodium,
              'Carbs (g)': totalCarbs,
              'Fiber (g)': totalFiber,
              'Sugars (g)': totalSugars,
            },
            chartRadius: 135,
            chartLegendSpacing: 25,
            chartType: ChartType.ring,
            colorList: const [
              Color(0xFF55efc4),
              Color(0xFF74b9ff),
              Color(0xFFff7675),
              Color(0xFFffeaa7),
              Color(0xFFa29bfe),
              Color(0xFFfd79a8),
            ],
            legendOptions: const LegendOptions(
              legendPosition: LegendPosition.left,
              legendShape: BoxShape.circle,
              showLegendsInRow: false,
              legendTextStyle: TextStyle(
                fontSize: 10,
              ),
            ),
            chartValuesOptions: const ChartValuesOptions(
              decimalPlaces: 0,
              showChartValuesOutside: true,
              showChartValuesInPercentage: false,
              chartValueStyle: TextStyle(
                fontSize: 12,
                color: Colors.blueGrey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
