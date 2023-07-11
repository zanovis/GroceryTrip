import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:grocerytrip/Utils/product_model.dart';
import 'package:grocerytrip/Utils/store_notifier.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_functions/cloud_functions.dart';
//todo add rest of attributes to detail page
//todo translate joules to calories, normalize with 100g value

class GroceryListModel extends ChangeNotifier {
  List<dynamic> _rawGroceryList = [];
  List<dynamic> _productList = [];
  List<dynamic> _matchingBarcodes = [];
  List<dynamic> _missingBarcodes = [];
  Map<String, bool> _missingBarcodesMap = {};
  List<dynamic> _products = [];
  List<String> _ingredientsList = [];
  Map<String, Map<String, dynamic>> _ingredientsMap = {};

  void reset() {
    _rawGroceryList = [];
    _productList = [];
    _matchingBarcodes = [];
    _missingBarcodes = [];
    _missingBarcodesMap = {};
    _products = [];
    _ingredientsList = [];
    _ingredientsMap = {};
    products = [];
    productList = [];
  }

  // list of grocery items
  List<dynamic> get rawGroceryList => _rawGroceryList;
  List<dynamic> get matchingBarcodes => _matchingBarcodes;
  List<dynamic> get missingBarcodes => _missingBarcodes;
  Map<String, bool> get missingBarcodesMap => _missingBarcodesMap;
  List<dynamic> get products => _products;
  List<dynamic> get productList => _productList;
  List<dynamic> get ingredientsList => _ingredientsList;
  Map<String, Map<String, dynamic>> get ingredientsMap => _ingredientsMap;

  set rawGroceryList(List<dynamic> newList) {
    _rawGroceryList = newList;
    notifyListeners();
  }

  set matchingBarcodes(dynamic newMatchingBarcodes) {
    _matchingBarcodes = newMatchingBarcodes;
    notifyListeners();
  }

  set missingBarcodesMap(dynamic newMissingBarcodes) {
    _missingBarcodesMap = newMissingBarcodes;
    notifyListeners();
  }

  set products(dynamic newProducts) {
    _products = newProducts;
    notifyListeners();
  }

  set productList(dynamic newProducts) {
    _productList = newProducts;
    notifyListeners();
  }

  set ingredientsList(dynamic newResult) {
    _ingredientsList = newResult;
    notifyListeners();
  }

  set ingredientsMap(dynamic newResult) {
    _ingredientsMap = newResult;
    notifyListeners();
  }

  bool isPrimarilyNumbers(List<dynamic> list) {
    int numCount = 0;
    int wordCount = 0;
    for (var item in list) {
      if (RegExp(r'^\d+$').hasMatch(item)) {
        numCount++;
      } else {
        wordCount++;
      }
    }
    return numCount > wordCount;
  }

  List<String> processBarcodes(List<dynamic> rawGroceryList) {
    //todo: check for text, and skip this step if there is text
    List<String> processedBarcodes = [];
    for (String item in rawGroceryList) {
      // Check if the item starts with a 0 or 7
      if (!item.startsWith('0') && !item.startsWith('7')) {
        item = '0$item';
      }

      // If the item is less than 11 digits, add another 0 to the beginning
      while (item.length < 11) {
        item = '0$item';
      }

      // 1. Add the digits in the odd positions
      int sumOddPositions = 0;
      for (int i = 0; i < item.length; i += 2) {
        sumOddPositions += int.parse(item[i]);
      }

      // 2. Multiply this value by 3
      int step2Result = sumOddPositions * 3;

      // 3. Add the digits in the even positions
      int sumEvenPositions = 0;
      for (int i = 1; i < item.length; i += 2) {
        sumEvenPositions += int.parse(item[i]);
      }

      // 4. Add the values from step 2 and 3
      int step4Result = step2Result + sumEvenPositions;

      // 5. Determine the value needed to add to this number to reach the next multiple of 10
      int remainder = step4Result % 10;
      int lastDigit = remainder == 0 ? 0 : 10 - remainder;

      // Append the last digit to the item
      item = item + lastDigit.toString();

      processedBarcodes.add(item);
    }

    return processedBarcodes;
  }

  Future findBarcodes(StoreNotifier storeNotifier) async {
    if (rawGroceryList.isNotEmpty) {
      if (isPrimarilyNumbers(rawGroceryList)) {
        _matchingBarcodes = processBarcodes(rawGroceryList);
        return _matchingBarcodes;
      } else {
        debugPrint(
            'Sent the following items to server: ${rawGroceryList.join(', ')}');

        try {
          final result = await FirebaseFunctions.instance
              .httpsCallable('fuzzySearch')
              .call({
            'itemNames': rawGroceryList,
            'selectedStore': storeNotifier.selectedStore,
          });

          // Process the result.data here
          if (result.data is Map<String, dynamic>) {
            _matchingBarcodes = result.data['found'];

            // Clear the missingBarcodes list and map
            _missingBarcodes.clear();
            _missingBarcodesMap.clear();

            // Add items to missingBarcodes if not found in result.data
            for (String item in result.data['notFound']) {
              _missingBarcodes.add(item);
              _missingBarcodesMap[item] = false;
            }
          } else {
            debugPrint(
                'Unexpected response format from fuzzySearch Cloud Function');
          }
        } catch (e) {
          debugPrint('Error calling fuzzySearch Cloud Function: $e');
          // Handle error here
        }
      }
    }
    notifyListeners();
  }

  Future callOffApi(List<dynamic> codes) async {
    // Concatenate the matching keys into a single string, separated by a comma.
    final barcodesString = codes.where((code) => code.isNotEmpty).join(',');
    final offApiUrl = Uri.parse(
        'https://off:off@world.openfoodfacts.org/api/v2/search?code=$barcodesString&fields=code,product_name,energy_100g,fat_100g,proteins_100g,carbohydrates_100g,sodium_100g,sugars_100g,fiber_100g,product_quantity,ingredients_text,image_small_url&no_cache=1');
    // Make an HTTP request to the API using the concatenated string of barcodes.
    var response = await http.get(
      offApiUrl,
      headers: {
        'User-Agent': 'GroceryTrip - Android - v0.1.0-beta - zanovis@gmail.com',
      },
    );

    if (response.statusCode == 200) {
      // debugPrint(barcodesString);
      // Success! Parse the response body as a JSON object.
      Map<String, dynamic> offApiResponse = json.decode(response.body);
      List<dynamic> productList = offApiResponse['products'];
      for (var eachProduct in productList) {
        final product = Product(
          name: eachProduct['product_name'] ?? 'null',
          code: eachProduct['code'] ?? 'null',
          mass: eachProduct['product_quantity'] ?? 'null',
          energy: eachProduct['energy_100g'] ?? 'null',
          protein: eachProduct['proteins_100g'] ?? 'null',
          carbs: eachProduct['carbohydrates_100g'] ?? 'null',
          sugars: eachProduct['sugars_100g'] ?? 'null',
          fat: eachProduct['fat_100g'] ?? 'null',
          sodium: eachProduct['sodium_100g'] ?? 'null',
          fiber: eachProduct['fiber_100g'] ?? 'null',
          ingredients:
              eachProduct['ingredients_text'] ?? 'Missing ingredients!',
          imageUrl: eachProduct['image_small_url'] ?? 'null',
        );
        _ingredientsList = product.ingredients
            .toLowerCase()
            .replaceAll('contains', '')
            .split(RegExp(r'[.,;:()]+'))
            .map((ingredient) => ingredient.trim())
            .where((ingredient) => ingredient.isNotEmpty)
            .map((ingredient) =>
                ingredient.substring(0, 1).toUpperCase() +
                ingredient.substring(1))
            .toSet()
            .toList();

        debugPrint(
            '${product.code}, ${product.name}, ${product.mass}, ${product.energy}, ${product.protein}, ${product.carbs}, ${product.sugars}, ${product.fat}');

        _products.add(product);

// get ingredients from all found products in receipt
        for (String ingredient in ingredientsList) {
          if (!_ingredientsMap.containsKey(ingredient)) {
            _ingredientsMap[ingredient] = {
              'count': 1,
              'products': [product.name],
            };
          } else {
            if (!_ingredientsMap[ingredient]?['products']
                .contains(product.name)) {
              _ingredientsMap[ingredient]?['products'].add(product.name);
              _ingredientsMap[ingredient]?['count'] += 1;
            }
          }
        }
      }

      // sort ingredients list for summary page
      _ingredientsMap = Map.fromEntries(_ingredientsMap.entries.toList()
        ..sort(
          (a, b) => b.value['count'].compareTo(a.value['count']),
        ));

      notifyListeners();
    } else {
      // Error!
      debugPrint('error!');
    }
  }
}
