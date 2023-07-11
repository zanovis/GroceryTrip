import 'dart:developer';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';

Future<String> imageCropperView(String? path, BuildContext context) async {
  CroppedFile? croppedFile = await ImageCropper().cropImage(
    sourcePath: path!,
    aspectRatioPresets: [
      CropAspectRatioPreset.original,
    ],
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Select Barcodes\nIf no barcodes, select names',
        toolbarColor: Brightness.light == Theme.of(context).brightness
            ? Theme.of(context).primaryColor
            : Theme.of(context).primaryColorDark,
        toolbarWidgetColor: Brightness.light == Theme.of(context).brightness
            ? Colors.white
            : const Color.fromARGB(255, 100, 235, 171),
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
        hideBottomControls: true,
      ),
      IOSUiSettings(
        title: 'Crop Image',
      ),
      WebUiSettings(
        context: context,
      ),
    ],
  );
  if (croppedFile != null) {
    log("Imaged cropped");
    return croppedFile.path;
  } else {
    log("Do nothing");
    return '';
  }
}
