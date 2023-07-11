import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DetailCard extends StatelessWidget {
  final String productName;
  final dynamic productMass;
  final dynamic productEnergy;
  final dynamic productProtein;
  final dynamic productCarbs;
  final dynamic productFat;
  final dynamic productSugars;
  final dynamic productSodium;
  final dynamic productFiber;
  final String productUrl;
  // final num productSodium;

  const DetailCard({
    super.key,
    required this.productName,
    required this.productMass,
    required this.productEnergy,
    required this.productProtein,
    required this.productCarbs,
    required this.productFat,
    required this.productSugars,
    required this.productSodium,
    required this.productFiber,
    required this.productUrl,
  });

  Future<ImageProvider> _loadImage(String productUrl) {
    final Completer<ImageProvider> completer = Completer();
    final image = NetworkImage(productUrl);
    image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((_, __) {
        completer.complete(image);
      }),
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final List macroList = [
      productProtein,
      productFat,
      productSodium,
      productCarbs,
      productFiber,
      productSugars
    ];
    final List nameList = [
      'Protein',
      'Fat',
      'Sodium',
      'Carbs',
      'Fiber',
      'Sugars'
    ];

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (productUrl == 'null' || productUrl.isEmpty)
            const SizedBox(width: 70)
          else
            SizedBox(
              width: 70,
              height: 100,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FutureBuilder<ImageProvider>(
                    future: _loadImage(productUrl),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Image(
                          image: snapshot.data!,
                          fit: BoxFit.cover,
                        );
                      } else {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 70,
                            height: 100,
                            color: Colors.grey[300],
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    padding: const EdgeInsets.only(left: 4, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: Text(productName,
                                style: const TextStyle(
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                )),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              // productEnergy.isNaN
                              //     ? 'NaN'
                              //     :
                              '${productEnergy.toStringAsFixed(0)}cal',
                              style: TextStyle(
                                color: productEnergy.isNaN
                                    ? Colors.red[300]
                                    : null,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              // productMass.isNaN
                              //     ? 'NaN'
                              //     :
                              '${productMass.toStringAsFixed(0)}g',
                              style: TextStyle(
                                color:
                                    productMass.isNaN ? Colors.red[300] : null,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 55,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(macroList.length, (index) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width / 8,
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          // macro cards
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                macroList[index].isNaN
                                    ? 'NaN'
                                    : '${macroList[index].toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: macroList[index].isNaN
                                      ? Colors.red[300]
                                      : (productMass.isNaN
                                          ? Colors.yellow[700]
                                          : null),
                                ),
                              ),
                              Text(
                                '${nameList[index]}',
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 126, 126, 126),
                                  fontSize: 12,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
