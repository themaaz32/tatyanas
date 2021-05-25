import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tatyanas_app/model/icon_model.dart';
import 'package:tatyanas_app/model/image_model.dart';
import 'package:tatyanas_app/screens/home/state/home_state.dart';

class ImagesGrid extends StatelessWidget {

  final List<ImageModel> listOfGroupedImages;

  ImagesGrid(this.listOfGroupedImages);

  @override
  Widget build(BuildContext context) {

    final state = Provider.of<HomeState>(context, listen: true);

    return GridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: listOfGroupedImages.map((ImageModel image) {
        return GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: !ifSourceIsFile(image.source)
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                image.imageLink,
              ),
            )
                : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(image.imageLink),
                fit: BoxFit.cover,
              ),
            ),
          ),
          onTap: () async {
            state.handleOpenImageAndPlayAudio(image);
          },
        );
      }).toList(),
    );
  }
}
