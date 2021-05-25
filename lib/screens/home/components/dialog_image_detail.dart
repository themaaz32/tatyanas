import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tatyanas_app/model/image_model.dart';
import 'package:tatyanas_app/state/app_state.dart';

import '../../../model/icon_model.dart';

class ImageDetailDialog extends StatelessWidget {
  final ImageModel _image;

  ImageDetailDialog(this._image);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.all(0),
      insetPadding: const EdgeInsets.all(0),
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [

              SizedBox(
                width: double.infinity,
                child: !ifSourceIsFile(_image.source)
                    ? Image.asset(
                  _image.imageLink,
                )
                    : Image.file(
              File(_image.imageLink),
      fit: BoxFit.cover,
    ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.close),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
