import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocerytrip/Utils/grocerylist_model.dart';
import 'package:grocerytrip/Widgets/detail_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({
    super.key,
  });
  Future<void> _launchURL(String barcode) async {
    final String appUrl = 'com.openfoodfacts://product/$barcode';
    final String webUrl = 'https://world.openfoodfacts.org/product/$barcode';
    if (await canLaunchUrl(Uri.parse(appUrl))) {
      await launchUrl(Uri.parse(appUrl),
          mode: LaunchMode.externalNonBrowserApplication);
    } else if (await canLaunchUrl(Uri.parse(webUrl))) {
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $webUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GroceryListModel>(
      builder: (context, groceryListModel, child) {
        return Scrollbar(
          radius: const Radius.circular(4),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            itemCount: groceryListModel.products.length,
            itemBuilder: (context, index) {
              final product = groceryListModel.products[index];
              if (product != null) {
                //todo:improve button and actions to go to page, favorites maybe?
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 2,
                  child: InkWell(
                    splashColor: const Color.fromARGB(255, 100, 235, 171)
                        .withOpacity(.6),
                    borderRadius: BorderRadius.circular(10),
                    splashFactory: InkRipple.splashFactory,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text(
                            'Edit Product',
                          ),
                          content: Text(
                            'Edit ${product.name} on OpenFoodFacts.com?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Close'),
                            ),
                            TextButton(
                              onPressed: () {
                                _launchURL(product.code);
                              },
                              child: const Text('Open'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: product.name == 'null'
                        ? Container()
                        : DetailCard(
                            productName: product.name,
                            productMass: product.mass,
                            productEnergy: product.energy,
                            productProtein: product.protein,
                            productCarbs: product.carbs,
                            productFat: product.fat,
                            productSugars: product.sugars,
                            productSodium: product.sodium,
                            productFiber: product.fiber,
                            productUrl: product.imageUrl,
                          ),
                  ),
                );
              } else {
                return const Card();
              }
            },
          ),
        );
      },
    );
  }
}
