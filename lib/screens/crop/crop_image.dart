import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';
import 'package:provider/provider.dart';
import 'package:tatyanas_app/state/app_state.dart';

class CropImageScreen extends StatelessWidget {
  final path;

  CropImageScreen(this.path);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: true);

    return WillPopScope(
      onWillPop: () async{
        return false;
      },
      child: Scaffold(
        body: Crop(
          key: appState.cropKey,
          aspectRatio: 1,
          image: FileImage(File(path)),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final area = appState.cropKey.currentState.area;
            final scale = appState.cropKey.currentState.scale;

            final croppedImage = await ImageCrop.cropImage(
              file: File(path),
              area: area,
              scale: scale
            );

            Navigator.pop(context, croppedImage);
          },
          child: Icon(Icons.check),
        ),
      ),
    );
  }
}
