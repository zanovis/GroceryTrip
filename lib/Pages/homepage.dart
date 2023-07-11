import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/Utils/image_picker_class.dart';
import '/Widgets/modal_dialog.dart';
import 'image_cropper_page.dart';
import '/Pages/confirm_scan_page.dart';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// Homepage Widget
class MyHomePage extends StatefulWidget {
  final dynamic icon;

  const MyHomePage({
    super.key,
    required this.title,
    required this.toggleDarkMode,
    required this.icon,
  });
  final String title;
  final VoidCallback toggleDarkMode;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

final List<String> supportedStores = [
  'Store 1',
  'Store 2',
  'Store 3',
  'Store 4',
  'Store 5',
];

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 6,
        shadowColor: Theme.of(context).shadowColor,
        title: const Text('GroceryTrip'),
        actions: [
          IconButton(
              icon: Icon(widget.icon),
              onPressed: () {
                widget.toggleDarkMode();
              })
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.userChanges(),
              builder: (context, snapshot) {
                User? user = snapshot.data;
                return ListTile(
                  leading: user == null ? null : const Icon(Icons.logout),
                  title: user == null
                      ? const Text('Work in progress!')
                      : const Text('Sign out'),
                  onTap: user != null
                      ? () async {
                          await FirebaseAuth.instance.signOut();
                          //alert the user that they have been signed out successfully
                          Future.microtask(() {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'You have been signed out successfully'),
                              ),
                            );
                          });
                        }
                      : null,
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/homepage_icon.png',
              //make black and white and reduce opacity
              color: Theme.of(context).iconTheme.color!.withOpacity(0.06),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Welcome to GroceryTrip!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  'Scan a receipt to get started',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 80),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          imagePickerModal(
            context,
            onCameraTap: () {
              log("Camera");
              pickImage(source: ImageSource.camera).then((path) {
                if (path != '') {
                  imageCropperView(path, context).then((path) {
                    if (path != '') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConfirmScanPage(
                            path: path,
                          ),
                        ),
                      );
                    }
                  });
                }
              });
            },
            onGalleryTap: () {
              log("Gallery");
              pickImage(source: ImageSource.gallery).then(
                (value) {
                  if (value != '') {
                    imageCropperView(value, context).then(
                      (value) {
                        if (value != '') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ConfirmScanPage(
                                path: value,
                              ),
                            ),
                          );
                        }
                      },
                    );
                  }
                },
              );
            },
            onDemoTap: () async {
              log("Demo");
              String assetPath = 'assets/examples/TJ_receipt.jpg';
              // Load image bytes from the asset path
              final byteData = await rootBundle.load(assetPath);

              // Create a temporary file to store the image
              final tempFile = File(
                  '${(await getTemporaryDirectory()).path}/temp_image.jpg');
              await tempFile.writeAsBytes(byteData.buffer
                  .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
              // Pass the temporary file path to imageCropperView
              String imagePath = tempFile.path;
              //todo: fix async gap
              imageCropperView(imagePath, context).then((value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ConfirmScanPage(
                      path: value,
                    ),
                  ),
                );
              });
            },
          );
        },
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}
