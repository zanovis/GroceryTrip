import 'package:flutter/material.dart';
import 'package:grocerytrip/Utils/store_notifier.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:grocerytrip/Utils/grocerylist_model.dart';
import 'package:grocerytrip/Utils/upload_barcode.dart';

class SubmitBarcodePage extends StatelessWidget {
  final String productName;
  final Function onBarcodeScanned;

  const SubmitBarcodePage({
    super.key,
    required this.productName,
    required this.onBarcodeScanned,
  });

  @override
  Widget build(BuildContext context) {
    final controller =
        MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: Column(
        children: [
          Flexible(
            flex: 1,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Adding barcode for:\n'$productName'",
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: SizedBox(
              height: 200,
              width: 400,
              child: Consumer2<GroceryListModel, StoreNotifier>(
                builder: (context, groceryListModel, selectedStore, child) {
                  final selectedStore =
                      Provider.of<StoreNotifier>(context).selectedStore;

                  return MobileScanner(
                    controller: controller,
                    onDetect: (barcode) async {
                      final String barcodeString =
                          barcode.barcodes[0].displayValue.toString();
                      if (barcodeString == '') {
                        debugPrint('Failed to scan Barcode');
                      } else {
                        debugPrint('Barcode found! $barcodeString');
                        controller.stop();
                        final bool confirm = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirm Barcode'),
                                  content: Text(
                                      'Please verify the barcode:\n$productName :  $barcodeString'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, false);
                                        controller.start();
                                      },
                                      child: const Text('Retry'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Confirm'),
                                    ),
                                  ],
                                );
                              },
                            ) ??
                            false;

                        if (confirm) {
                          uploadBarcode(
                                  productName, barcodeString, selectedStore)
                              .then(
                            (_) {
                              Vibration.vibrate(duration: 300);
                              Navigator.pop(context);
                            },
                          ).then(
                            (_) {
                              //todo: maybe update method for state of add icon
                              // groceryListModel.missingBarcodes.remove(
                              //     productName); // remove barcode from current missingBarcodes list
                              onBarcodeScanned();
                              //todo: figure out how to fix this warning below
                              groceryListModel.callOffApi(barcodeString
                                  .split(',')); // this adds to products list
                            },
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
