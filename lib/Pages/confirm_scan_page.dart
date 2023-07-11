import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:grocerytrip/Utils/grocerylist_model.dart';
import 'package:grocerytrip/Utils/product_model.dart';
import 'package:grocerytrip/Utils/store_notifier.dart';
import 'package:provider/provider.dart';

import '/Pages/results_page.dart';

class ConfirmScanPage extends StatefulWidget {
  final String? path;
  const ConfirmScanPage({Key? key, this.path}) : super(key: key);

  @override
  State<ConfirmScanPage> createState() => _ConfirmScanPageState();
}

class _ConfirmScanPageState extends State<ConfirmScanPage> {
  final myChangeNotifier = ChangeNotifier();
  bool _isBusy = false;
  List<dynamic> rawGroceryList = [];
  List<Product> products = [];
  List<Product> productList = [];

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.path != null) {
      final InputImage inputImage = InputImage.fromFilePath(widget.path!);
      processImage(inputImage);
    } else {
      // Handle the case when the widget.path is null
      // For example, show a message, or do nothing
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Confirm scan")),
        body: _isBusy
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                padding: const EdgeInsets.all(20),
                child: TextFormField(
                  onChanged: (text) {},
                  maxLines: null,
                  controller: _controller,
                  decoration:
                      const InputDecoration(hintText: "Text goes here..."),
                ),
              ),
        floatingActionButton: _isBusy
            ? null
            : _controller.text.isEmpty
                ? null
                : FloatingActionButton(
                    child: const Icon(
                      Icons.check,
                    ),
                    onPressed: () {
                      setState(() {
                        _isBusy = true;
                      });
                      submitText(GroceryListModel(), StoreNotifier()).then((_) {
                        setState(() {
                          _isBusy = false;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ResultsPage(),
                          ),
                        );
                      }).catchError((error) {
                        debugPrint('There was an error: $error');
                      });
                    },
                  ));
  }

  void processImage(InputImage? image) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    if (image == null) {
      // Handle the situation when the image is null
      return;
    }
    setState(() {
      _isBusy = true;
    });

    try {
      log(image.filePath!);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(image);
      List<String> lines = recognizedText.text.split('\n');
      List<String> longNumbers = [];
      bool hasLongNumbers = false;
      for (String line in lines) {
        List<String> items = line.split(RegExp(r'\s+'));

        for (String item in items) {
          if (RegExp(r'^\d{8,}$').hasMatch(item)) {
            longNumbers.add(item);
            hasLongNumbers = true;
          }
        }
      }
      String correctedText;

      if (hasLongNumbers) {
        correctedText = longNumbers.join('\n');
      } else {
        List<String> stringLines = [];

        for (String line in lines) {
          if (!(RegExp(r'^\d+').hasMatch(line) &&
              !RegExp(r'^\d+$').hasMatch(line))) {
            stringLines.add(line);
          }
        }

        correctedText = stringLines.join('\n');
      }
      _controller.text = correctedText;
    } catch (e) {
      debugPrint('Error processing image: $e');
      Navigator.of(context).pop();
    } finally {
      setState(() {
        _isBusy = false;
      });
    }
  }

  Future<void> submitText(
      GroceryListModel groceryListModel, StoreNotifier storeNotifier) async {
    String items = _controller.text;
    _controller.clear();
    List<dynamic> rawGroceryList =
        items.split('\n').map((item) => item.trim()).toSet().toList();
    final groceryListModel =
        Provider.of<GroceryListModel>(context, listen: false);
    groceryListModel.reset();
    groceryListModel.rawGroceryList = rawGroceryList;
    final storeNotifier = Provider.of<StoreNotifier>(context, listen: false);

    await groceryListModel.findBarcodes(storeNotifier);
    final matchingBarcodes = groceryListModel.matchingBarcodes;
    await groceryListModel.callOffApi(matchingBarcodes);
  }
}
