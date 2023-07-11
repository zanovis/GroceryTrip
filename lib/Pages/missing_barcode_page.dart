import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grocerytrip/Utils/grocerylist_model.dart';
import 'package:grocerytrip/Widgets/missing_item_widget.dart';
import '/Pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MissingBarcodePage extends StatefulWidget {
  const MissingBarcodePage({
    super.key,
  });

  @override
  State<MissingBarcodePage> createState() => _MissingBarcodePageState();
}

class _MissingBarcodePageState extends State<MissingBarcodePage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            if (snapshot.hasData) {
              User? user = FirebaseAuth.instance.currentUser;
              user?.reload();
              if (user != null && user.emailVerified) {
                return Consumer<GroceryListModel>(
                    builder: (context, groceryListModel, child) {
                  final missingBarcodesMap =
                      groceryListModel.missingBarcodesMap;
                  return missingBarcodesMap.isEmpty
                      ? const Center(
                          child: Text(
                            'Hooray! \nThere are no missing barcodes on your receipt!',
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount: missingBarcodesMap.entries.length,
                          itemBuilder: (context, index) {
                            final product = groceryListModel.missingBarcodesMap;
                            List<MapEntry<String, bool>> missingBarcodesList =
                                product.entries.toList();
                            MapEntry<String, bool> missingBarcodeEntry =
                                missingBarcodesList[index];
                            if (missingBarcodeEntry.key != '') {
                              return MissingItemCard(
                                missingBarcodeEntry: missingBarcodeEntry,
                              );
                            } else {
                              return const Card();
                            }
                          },
                        );
                });
              } else if (user == null) {
                setState(() {});
              }
            }
            return LoginPage(
              onLoginSuccess: () {
                setState(() {});
              },
              onVerifiedEmailLogin: (User user) {},
              onSignUp: (BuildContext context) {
                _showEmailVerificationSnackBar(context);
              },
            );
          }
        });
  }
}

void _showEmailVerificationSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Email verification sent. Please verify your account before logging in.',
      ),
    ),
  );
}
