import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Utils/store_notifier.dart';

void imagePickerModal(BuildContext context,
    {VoidCallback? onCameraTap,
    VoidCallback? onGalleryTap,
    VoidCallback? onDemoTap}) {
  // Add store list and selected store variable
  final List<String> storeList = [
    'Trader Joes',
    'Albertsons',
    'Aldi',
    'Costco',
    'HEB',
    'Kroger',
    'Natural Grocers',
    'Publix',
    'Raleys',
    'Smiths',
    'Sprouts',
    'Target',
    'Walmart',
    'Whole Foods',
  ];
  String? selectedStore;
  bool storeSelected = false;

  showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Consumer<StoreNotifier>(
              builder: (context, storeNotifier, child) {
                return Stack(children: [
                  SizedBox(
                    height: 300,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 3,
                            width: 25,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 185, 185, 185),
                              borderRadius: BorderRadius.all(
                                Radius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          // Add DropdownButton for store selection
                          DropdownButton<String>(
                            value: selectedStore,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedStore = newValue!;
                                storeSelected =
                                    newValue != 'Please select a store';
                              });
                              Provider.of<StoreNotifier>(context, listen: false)
                                  .selectedStore = newValue;
                            },
                            hint: const Text('Please select a store'),
                            icon: const Icon(Icons.arrow_drop_down),
                            borderRadius: BorderRadius.circular(10),
                            alignment: Alignment.center,
                            underline: Container(
                                height: 1,
                                color: storeSelected
                                    ? const Color.fromARGB(255, 100, 235, 171)
                                    : const Color.fromARGB(255, 185, 185, 185)),
                            elevation: 6,
                            items: storeList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                alignment: Alignment.center,
                                value: value,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child:
                                      Text(value, textAlign: TextAlign.center),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            child: Container(
                              alignment: Alignment.center,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(elevation: 4),
                                onPressed: storeSelected ? onCameraTap : null,
                                icon: const Icon(
                                  Icons.photo_camera,
                                ),
                                label: const Text(
                                  "Camera",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            child: Container(
                              alignment: Alignment.center,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(elevation: 4),
                                onPressed: storeSelected ? onGalleryTap : null,
                                icon: const Icon(
                                  Icons.image,
                                ),
                                label: const Text(
                                  "Gallery",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            child: Container(
                              alignment: Alignment.center,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(elevation: 4),
                                onPressed: () {
                                  onDemoTap!();
                                  selectedStore = 'Trader Joes';
                                  Provider.of<StoreNotifier>(context,
                                          listen: false)
                                      .selectedStore = selectedStore;
                                },
                                icon: const Icon(
                                  Icons.fast_forward_rounded,
                                ),
                                label: const Text(
                                  "Demo",
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]);
              },
            );
          },
        );
      });
}
