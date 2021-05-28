import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tatyanas_app/model/icon_model.dart';
import 'package:tatyanas_app/model/image_model.dart';
import 'package:tatyanas_app/screens/config/state/config_state.dart';
import 'package:tatyanas_app/state/app_state.dart';

Widget _getCheckWidget(BuildContext context) {
  final appState = Provider.of<AppState>(context, listen: true);
  return Align(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            child: const Icon(
              Icons.check,
              color: Colors.blue,
            ),
            onTap: () {
              appState.navigatorKey.currentState.pop();
            },
          ),
          const Spacer(),
          GestureDetector(
            child: const Icon(Icons.settings),
            onTap: () {},
          ),
        ],
      ),
    ),
    alignment: Alignment.centerRight,
  );
}

Widget getConfigBody(BuildContext context) {
  return SafeArea(
    child: Container(
      child: Column(
        children: [
          const SizedBox(
            height: 16,
          ),
          _getCheckWidget(context),
          _getEditableImagesGrid(context),
          _getEditableIconList(context),
        ],
      ),
    ),
  );
}

Widget _getAddNewImageItem(BuildContext context) {
  final appState = Provider.of<AppState>(context, listen: true);
  final state = Provider.of<ConfigState>(context, listen: true);

  return AspectRatio(
    aspectRatio: 1,
    child: GestureDetector(
      onTap: () {
        appState.handleAddImageToAGroup(state.currentActiveGroup);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: DottedBorder(
          borderType: BorderType.RRect,
          color: Colors.grey[300],
          strokeWidth: 3,
          dashPattern: [3, 5],
          strokeCap: StrokeCap.round,
          radius: Radius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
            ),
            child: const Center(
              child: Icon(
                Icons.add,
                color: Colors.grey,
                size: 48,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _getEditableImageItem(BuildContext context, ImageModel image, Directory appDirectory) {
  final state = Provider.of<ConfigState>(context, listen: true);

  return Stack(
    clipBehavior: Clip.none,
    children: [
      Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          child: !ifSourceIsFile(image.source)
              ? Image.asset(
                  image.imageLink,
                )
              : Image.file(
            File("${appDirectory.path}/${image.imageLink}",),
                  fit: BoxFit.cover,
                ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      Positioned(
        child: GestureDetector(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
            child: Icon(
              Icons.close,
              color: Colors.white,
              size: 14,
            ),
          ),
          onTap: () {
            state.handleDeleteImage(image);
          },
        ),
        right: -7,
        top: -7,
      )
    ],
  );
}

Widget _getEditableImagesGrid(BuildContext context) {
  final appState = Provider.of<AppState>(context, listen: true);
  final state = Provider.of<ConfigState>(context, listen: true);

  return Expanded(
    child: Container(
      child: FutureBuilder(
        future: appState.getApplicationStoragePath(),
        builder: (context, snapshot) => snapshot.hasData  ?  GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: ([
            ...(appState.imageGroups.isEmpty
                ? []
                : appState.imageGroups[state.currentActiveGroup].images),
            ...[null]
          ]).map(
            (image) {
              return image == null
                  ? _getAddNewImageItem(context)
                  : _getEditableImageItem(context, image, snapshot.data);
            },
          ).toList(),
        ) : const SizedBox(),
      ),
    ),
  );
}

Widget _getEditableIcon(BuildContext context,) {
  final appState = Provider.of<AppState>(context, listen: true);
  return AspectRatio(
    aspectRatio: 1,
    child: GestureDetector(
      onTap: () {
        appState.handleAddIcon();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: DottedBorder(
          borderType: BorderType.RRect,
          color: Colors.grey[300],
          strokeWidth: 3,
          dashPattern: [3, 5],
          strokeCap: StrokeCap.round,
          radius: Radius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
            ),
            child: Center(
              child: Icon(
                Icons.add,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _getAddNewIcon(BuildContext context, int index,  Directory appDirectory) {
  final state = Provider.of<ConfigState>(context, listen: true);
  final appState = Provider.of<AppState>(context, listen: true);

  IconModel _currentIcon;

  if (index == appState.imageGroups.length)
    _currentIcon = null;
  else
    _currentIcon = appState.imageGroups[index];

  return Stack(
    clipBehavior: Clip.none,
    children: [
      AspectRatio(
        aspectRatio: 1,
        child: GestureDetector(
          onTap: () {
            state.setCurrentActiveGroup(index);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.blue,
                    width: index == state.currentActiveGroup ? 4 : 0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: !ifSourceIsFile(_currentIcon.source)
                  ? Image.asset(
                      _currentIcon.iconLink,
                    )
                  : Image.file(
                      File("${appDirectory.path}/${_currentIcon.iconLink}"),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
      ),
      Positioned(
        child: GestureDetector(
          onTap: () {
            state.handleDeleteGroup(index);
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
            child: Icon(
              Icons.close,
              color: Colors.white,
              size: 14,
            ),
          ),
        ),
        right: -7,
        top: -7,
      )
    ],
  );
}

Widget _getEditableIconList(BuildContext context) {
  final appState = Provider.of<AppState>(context, listen: true);

  return Container(
    height: appState.appSize.height * 0.12,
    child: FutureBuilder(
      future: appState.getApplicationStoragePath(),
      builder: (context, snapshot) => snapshot.hasData ?  ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return index == appState.imageGroups.length
              ? _getEditableIcon(context, )
              : _getAddNewIcon(context, index, snapshot.data);
        },
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => SizedBox(
          width: 16,
        ),
        itemCount: appState.imageGroups.length + 1,
      ) : const SizedBox(),
    ),
  );
}
