import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocerytrip/Pages/submit_barcode_page.dart';
import 'package:grocerytrip/Utils/grocerylist_model.dart';
import 'package:provider/provider.dart';

class MissingItemCard extends StatelessWidget {
  final MapEntry<String, bool> missingBarcodeEntry;
  const MissingItemCard({
    super.key,
    required this.missingBarcodeEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GroceryListModel>(
        builder: (context, groceryListModel, child) {
      return Card(
        elevation: 2,
        child: ListTile(
          leading: const Icon(Icons.warning_rounded),
          title: Text(missingBarcodeEntry.key),
          trailing: IconButton(
            icon: missingBarcodeEntry.value
                ? const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  )
                : const Icon(Icons.add_circle_outline_rounded),
            onPressed: () {
              if (missingBarcodeEntry.value) {
              } else {
                HapticFeedback.heavyImpact();
                showDialog(
                  context: context,
                  builder: (context) => SubmitBarcodePage(
                    productName: missingBarcodeEntry.key,
                    onBarcodeScanned: () {
                      groceryListModel
                          .missingBarcodesMap[missingBarcodeEntry.key] = true;
                      // groceryListModel.notifyListeners();
                    },
                  ),
                );
              }
            },
          ),
        ),
      );
    });
  }
}
