import 'package:flutter/foundation.dart';

class StoreNotifier extends ChangeNotifier {
  String? _selectedStore;

  String? get selectedStore => _selectedStore;

  set selectedStore(String? value) {
    _selectedStore = value;
    notifyListeners();
  }
}
