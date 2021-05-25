import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tatyanas_app/globals/widgets.dart';
import 'package:tatyanas_app/model/image_model.dart';
import 'package:tatyanas_app/state/app_state.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConfigState extends ChangeNotifier {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _context;

  ConfigState(this._context);

  int currentActiveGroup = 0;

  void setCurrentActiveGroup(int index) {
    this.currentActiveGroup = index;
    notifyListeners();
  }

  Future confirmImageDeletion() async {
    return await AppWidgets.confirm(
      _context,
      AppLocalizations.of(_context).doYouWantToDeleteThisImage,
    );
  }

  Future confirmGroupDeletion() async {
    final iconDeletion = await AppWidgets.confirm(
          _context,
          AppLocalizations.of(_context).doYouWantToDeleteThisIcon,
        ) ??
        false;

    if (iconDeletion) {
      return await AppWidgets.confirm(
          _context,
          AppLocalizations.of(_context)
              .areYouSureBecauseThisWillDeleteAllTheImagesAssociated);
    } else {
      return false;
    }
  }

  Future handleDeleteImage(ImageModel image) async {
    if (!(await confirmImageDeletion())) return;

    final appState = Provider.of<AppState>(_context, listen: false);

    final imageIndex =
        appState.imageGroups[currentActiveGroup].images.indexOf(image);

    appState.deleteImage(currentActiveGroup, imageIndex);
    print("Group Index $currentActiveGroup");
    print("image Index $imageIndex");
  }

  Future handleDeleteGroup(int groupId) async {
    if (!(await confirmGroupDeletion())) return;

    final appState = Provider.of<AppState>(_context, listen: false);

    print("Group Index $groupId");

    if (currentActiveGroup == groupId) currentActiveGroup = 0;

    notifyListeners();

    appState.deleteImageGroup(groupId);
  }
}
