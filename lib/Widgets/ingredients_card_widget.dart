import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class IngredientsCard extends StatelessWidget {
  final Map ingredientsMap;

  const IngredientsCard({
    super.key,
    required this.ingredientsMap,
  });

  Future<void> searchSimpleWikipedia(String ingredient) async {
    final query = Uri.encodeComponent(ingredient);
    final url = 'https://wikipedia.org/w/index.php?search=$query';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalNonBrowserApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: ingredientsMap.keys.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: Text('${index + 1}', style: const TextStyle(fontSize: 14)),
          visualDensity: const VisualDensity(vertical: -4),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                      child: Text(
                    '${ingredientsMap.keys.elementAt(index)}',
                  ))),
              Text('${ingredientsMap.values.elementAt(index)['count']} ',
                  style: TextStyle(
                    color: Colors.grey[500],
                  )),
            ],
          ),
          trailing: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(
                      '${ingredientsMap.keys.elementAt(index)}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: [
                          const Text(
                            'Products that contain this:',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...ingredientsMap[ingredientsMap.keys
                                  .elementAt(index)]['products']
                              .map<Widget>((product) => Text(
                                    product,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ))
                              .toList(),
                        ],
                      ),
                    ),
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MaterialButton(
                            onPressed: () async {
                              final ingredient =
                                  ingredientsMap.keys.elementAt(index);
                              await searchSimpleWikipedia(ingredient);
                            },
                            child: const Text(
                              'Search Wikipedia',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          MaterialButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'OK',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
            child: const SizedBox(
              child: Icon(
                Icons.info_outline_rounded,
                size: 20,
              ),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          // when the user taps on the info icon, a dialog box will appear that displays the products that contain this ingredient
        );
      },
    );
  }
}
