import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:grocerytrip/Utils/grocerylist_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../Utils/product_model.dart';

class MacroPerGramChart extends StatefulWidget {
  const MacroPerGramChart({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MacroPerGramState();
}

class MacroPerGramState extends State<MacroPerGramChart>
    with TickerProviderStateMixin {
  late List<dynamic> products;

  int touchedIndex = -1;
  int nextTouchedIndex = -1;

  static const appColors = [
    Color(0xFF55efc4),
    Color(0xFF74b9ff),
    Color(0xFFff7675),
    Color(0xFFffeaa7),
    Color(0xFFa29bfe),
    Color(0xFFfd79a8),
  ];

  double sumMacros(List<double> macros) {
    return macros.fold(0, (sum, value) => sum + value);
  }

  double sumPrevMacros(List<double> macros, int index) {
    return macros.sublist(0, index).fold(0, (sum, value) => sum + value);
  }

  BarGroupsAndFilteredProducts generateBarGroups(List<dynamic> products) {
    final filteredProducts = products.where((product) {
      final List<double> macros = [
        product.protein,
        product.fat,
        product.sodium,
        product.carbs,
        product.fiber,
        product.sugars,
      ];
      // Check if at least one macro is not NaN
      return !product.mass.isNaN &&
          product.mass != 0 &&
          macros.any((macro) => !macro.isNaN);
    }).toList();

    debugPrint('Filtered products count: ${filteredProducts.length}');
// Calculate the bar width based on the number of filtered products
    final chartWidth = MediaQuery.of(context).size.width;
    const barSpacing = 5.0;
    const minBarWidth = 9.0;
    const maxBarWidth = 20.0;
    final calculatedBarWidth =
        (chartWidth - (filteredProducts.length * barSpacing)) /
            filteredProducts.length;
    final barWidth = calculatedBarWidth.clamp(minBarWidth, maxBarWidth);

    final barGroups = filteredProducts.toList().asMap().entries.map((entry) {
      final int index = entry.key;
      final Product product = entry.value;
      // todo: convert from macro to macro per gram
      final List<double> macros = [
        product.protein.isNaN ? 0 : product.protein / product.mass,
        product.fat.isNaN ? 0 : product.fat / product.mass,
        product.sodium.isNaN ? 0 : product.sodium / product.mass,
        product.carbs.isNaN ? 0 : product.carbs / product.mass,
        product.fiber.isNaN ? 0 : product.fiber / product.mass,
        product.sugars.isNaN ? 0 : product.sugars / product.mass,
      ];

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
              toY: sumMacros(macros) * animation.value,
              width: barWidth,
              borderRadius: BorderRadius.circular(6),
              rodStackItems: macros
                  .asMap()
                  .entries
                  .map((e) => BarChartRodStackItem(
                        sumPrevMacros(macros, e.key) * animation.value,
                        (sumPrevMacros(macros, e.key) + e.value) *
                            animation.value,
                        appColors[e.key],
                      ))
                  .toList(),
              borderSide: touchedIndex == index
                  ? const BorderSide(width: 3, color: Colors.white)
                  : null),
        ],
      );
    }).toList();
    // Calculate the maximum sum of macros for all products
    double maxY = filteredProducts.fold(0, (prevMax, product) {
      final List<double> macros = [
        product.protein / product.mass,
        product.fat / product.mass,
        product.sodium / product.mass,
        product.carbs / product.mass,
        product.fiber / product.mass,
        product.sugars / product.mass,
      ];
      final sum = sumMacros(macros);
      return sum > prevMax ? sum : prevMax;
    });

    return BarGroupsAndFilteredProducts(
        barGroups: barGroups,
        maxY: maxY,
        filteredProducts: filteredProducts.toList());
  }

  late Animation<double> animation;
  final animationDuration = const Duration(milliseconds: 600);

  @override
  void initState() {
    super.initState();
    AnimationController controller = AnimationController(
      duration: animationDuration,
      vsync: this,
    );

    animation = Tween<double>(begin: 0, end: 1).animate(controller)
      ..addListener(() {
        setState(() {});
      });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GroceryListModel>(
        builder: (context, groceryListModel, child) {
      products = groceryListModel.products;
      final barGroupsAndFilteredProducts = generateBarGroups(products);
      final filteredProducts = barGroupsAndFilteredProducts.filteredProducts;
      final maxY = barGroupsAndFilteredProducts.maxY;
      return Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              'Macronutrient Density',
              style: TextStyle(fontSize: 16),
            ),
          ),
          Container(
            height: 2,
            width: MediaQuery.of(context).size.width * 0.5,
            color: const Color.fromARGB(190, 71, 94, 110),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 4),
              child: AnimatedBuilder(
                  animation: animation,
                  builder: (BuildContext context, Widget? child) {
                    return BarChart(
                      BarChartData(
                        titlesData: FlTitlesData(
                          show: false,
                        ),
                        alignment: BarChartAlignment.spaceBetween,
                        minY: -.001,
                        maxY: maxY,
                        // groupsSpace: 16,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                        ),
                        barTouchData: BarTouchData(
                          touchExtraThreshold: const EdgeInsets.all(6),
                          handleBuiltInTouches: true,
                          touchTooltipData: BarTouchTooltipData(
                            fitInsideHorizontally: true,
                            tooltipPadding: const EdgeInsets.all(6),
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final product = filteredProducts[group.x.toInt()];
                              final List<double> macros = [
                                product.protein / product.mass,
                                product.fat / product.mass,
                                product.sodium / product.mass,
                                product.carbs / product.mass,
                                product.fiber / product.mass,
                                product.sugars / product.mass,
                              ];
                              return BarTooltipItem(
                                '${product.name}\n'
                                'Protein: ${macros[0].toStringAsFixed(2)}\n'
                                'Fat: ${macros[1].toStringAsFixed(2)}\n'
                                'Sodium: ${macros[2].toStringAsFixed(2)}\n'
                                'Carbs: ${macros[3].toStringAsFixed(2)}\n'
                                'Fiber: ${macros[4].toStringAsFixed(2)}\n'
                                'Sugars: ${macros[5].toStringAsFixed(2)}',
                                const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              );
                            },
                          ),
                          touchCallback:
                              (FlTouchEvent event, barTouchResponse) {
                            if (barTouchResponse == null ||
                                !event.isInterestedForInteractions) {
                              if (touchedIndex != -1) {
                                setState(() {
                                  touchedIndex = -1;
                                });
                              }
                              return;
                            }

                            setState(() {
                              if (barTouchResponse.spot != null) {
                                int newTouchedIndex =
                                    barTouchResponse.spot!.touchedBarGroupIndex;
                                if (event is! PointerMoveEvent &&
                                    newTouchedIndex != touchedIndex) {
                                  touchedIndex = newTouchedIndex;
                                  HapticFeedback.mediumImpact();
                                } else if (event is PointerUpEvent ||
                                    event is PointerCancelEvent) {
                                  touchedIndex = -1;
                                }
                              } else {
                                touchedIndex = -1;
                              }
                            });
                          },
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        barGroups: barGroupsAndFilteredProducts.barGroups,
                      ),
                    );
                  }),
            ),
          ),
        ],
      );
    });
  }
}

class BarGroupsAndFilteredProducts {
  final List<BarChartGroupData> barGroups;
  final double maxY;
  final List<dynamic> filteredProducts;

  BarGroupsAndFilteredProducts(
      {required this.barGroups,
      required this.maxY,
      required this.filteredProducts});
}
