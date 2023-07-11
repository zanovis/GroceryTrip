import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocerytrip/Utils/grocerylist_model.dart';
import 'package:grocerytrip/Widgets/ingredients_card_widget.dart';
import 'package:grocerytrip/Widgets/macro_per_gram_chart.dart';
import 'package:grocerytrip/Widgets/summary_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  bool _isTotalView = true;

  void _toggleView() {
    setState(() {
      _isTotalView = !_isTotalView;
    });
  }

  Future<void> clearSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    //Display totals here, don't do calculations
    return Consumer<GroceryListModel>(
      builder: (context, totalsModel, child) {
        double getTotal(String property, bool isTotalView) {
          return totalsModel.products.fold(
            0,
            (previousValue, element) {
              var value = element.getProperty(property);
              if (value == 'null' || value.isNaN) {
                return previousValue;
              }
              return previousValue + (isTotalView ? value : (value / 7));
            },
          );
        }

        return Column(
          children: [
            // Development only: Clear SharedPreferences
            // ElevatedButton(
            //   onPressed: () async {
            //     await clearSharedPreferences();
            //     print("SharedPreferences cleared");
            //   },
            //   child: Text("Clear SharedPreferences"),
            // ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Energy: ${NumberFormat('#,###').format(getTotal('energy', _isTotalView))} cal',
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.right,
                  ),
                  Text(
                    '${totalsModel.products.length} items recognized',
                  ),
                ],
              ),
            ),
            Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: SummaryCard(
                        totalItems: totalsModel.products.length,
                        totalEnergy: getTotal('energy', _isTotalView),
                        totalProtein: getTotal('protein', _isTotalView),
                        totalCarbs: getTotal('carbs', _isTotalView),
                        totalFat: getTotal('fat', _isTotalView),
                        totalSugars: getTotal('sugars', _isTotalView),
                        totalSodium: getTotal('sodium', _isTotalView),
                        totalFiber: getTotal('fiber', _isTotalView),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        children: [
                          const Text('total '),
                          RotatedBox(
                            quarterTurns: 1,
                            child: Switch(
                              value: !_isTotalView,
                              onChanged: (value) {
                                HapticFeedback.selectionClick();
                                _toggleView();
                              },
                            ),
                          ),
                          const Text(' per day'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Flexible(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: MacroPerGramChart(),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Popular Ingredients',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    height: 2,
                    width: MediaQuery.of(context).size.width * 0.5,
                    color: const Color.fromARGB(190, 71, 94, 110),
                  ),
                ],
              ),
            ),

            Expanded(
              child: IngredientsCard(
                ingredientsMap: totalsModel.ingredientsMap,
              ),
            ),
          ],
        );
      },
    );
  }
}
