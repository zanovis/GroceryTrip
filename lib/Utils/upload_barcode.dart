import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

Future uploadBarcode(productName, String code, selectedStore) async {
  if (code.length >= 8 || code.length <= 12) {
    final dataBaseReference = FirebaseDatabase.instance.ref();
    final traderJoesProducts = dataBaseReference.child('stores/$selectedStore');
    await traderJoesProducts
        .update({
          code: '$productName',
        })
        .then((_) => debugPrint('Barcode sent to server!'))
        .catchError((error) {
          debugPrint('Error: $error');
        });
  }
}
