import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocerytrip/Pages/detail_page.dart';
import 'dart:core';
import 'package:grocerytrip/Pages/missing_barcode_page.dart';
import 'package:grocerytrip/Pages/summary_page.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({
    super.key,
  });

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  int index = 1;

  final screens = [
    const MissingBarcodePage(),
    const SummaryPage(),
    const DetailPage(),
  ];

  final pageHeaders = [
    'Contribute Barcodes',
    'Your Trip Summary',
    'Detailed List',
  ];

  final pageInfo = [
    'These are the items which need barcodes added to the database. \n\nOnce the barcode is added, it will appear in the Summary and Detail pages.',
    'This is the compilation of all nutrients and ingredients from your grocery trip. \n\nYou can switch between weekly and daily using the toggle. \n\nThe bar chart is the energy density level of each product. ',
    'These are all the items recognized on your receipt. \n\nIf the values are red, this means they are not yet added to the database. \n\nIf the values are yellow, it means they are the per 100g values, not totals. This is caused by a missing Net Weight value. \n\nPlease consider adding the product details by long-pressing on the product and navigating to OpenFoodFacts.com. ',
  ];

  final _controller = PageController(
    initialPage: 1,
  );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                      title: const Text(
                        'Discard receipt and return to the homepage?',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),

                      // content: const Text(
                      //     'This action will clear all receipt data.'),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            MaterialButton(
                              onPressed: () {
                                Navigator.pop(context, false);
                              },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            MaterialButton(
                              onPressed: () {
                                Navigator.pop(context, true);
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              },
                              child: const Text(
                                'OK',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ]);
                }) ??
            false;
        return shouldPop;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(pageHeaders[index]),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(pageHeaders[index]),
                      content: Text(pageInfo[index]),
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: PageView(
          controller: _controller,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              this.index = index;
            });
          },
          children: screens,
        ),
        bottomNavigationBar: NavigationBar(
          elevation: 1,
          selectedIndex: index,
          onDestinationSelected: (index) {
            setState(
              () {
                if ((this.index == 2 && index == 0) ||
                    (this.index == 0 && index == 2)) {
                  _controller.jumpToPage(index);
                } else {
                  _controller.animateToPage(
                    index,
                    curve: Curves.easeInOutCirc,
                    duration: const Duration(milliseconds: 400),
                  );
                }
                this.index = index;
              },
            );
            HapticFeedback.selectionClick();
          },
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.document_scanner_outlined),
              selectedIcon: Icon(Icons.document_scanner),
              label: 'Contribute',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.workspaces_outlined,
              ),
              selectedIcon: Icon(
                Icons.workspaces,
              ),
              label: 'Summary',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.receipt_long_outlined,
              ),
              selectedIcon: Icon(
                Icons.receipt_long,
              ),
              label: 'Detail',
            ),
          ],
        ),
      ),
    );
  }
}
