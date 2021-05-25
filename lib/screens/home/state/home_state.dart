import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:tatyanas_app/globals/routes/routes.dart';
import 'package:tatyanas_app/model/image_model.dart';
import 'package:tatyanas_app/screens/home/components/dialog_image_detail.dart';
import 'package:tatyanas_app/services/audio_player.dart';
import 'package:tatyanas_app/state/app_state.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeState extends ChangeNotifier {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final controller = ItemScrollController();
  final listener = ItemPositionsListener.create();

  final SoundPlayerService _soundPlayerService = SoundPlayerService();

  List<int> visibleIndexes = [];

  int currentActiveGroup = -1;

  BuildContext _context;

  bool isInitializing = false;

  void initializingStart() {
    isInitializing = true;
    notifyListeners();
  }

  void initializingComplete() {
    isInitializing = false;
    notifyListeners();
  }

  printTest() {
    listener.itemPositions.value.forEach((element) {
      print(
          "${element.index} leading : ${element.itemLeadingEdge} | trailing : ${element.itemTrailingEdge} Diff = ${(element.itemTrailingEdge > 1 ? 1 : element.itemTrailingEdge)  - (element.itemLeadingEdge < 0 ? 0 : element.itemLeadingEdge)}");
    });
  }

  double getAreaOfGroup(ItemPosition element){
    return (element.itemTrailingEdge > 1 ? 1 : element.itemTrailingEdge)  - (element.itemLeadingEdge < 0 ? 0 : element.itemLeadingEdge);
  }

  void attachScrollListener() {
    listener.itemPositions.addListener(() {
     /* visibleIndexes =
          listener.itemPositions.value.map((e) => e.index).toList();
      currentActiveGroup = visibleIndexes.isEmpty ? -1 : visibleIndexes.first;*/


      final List<ItemPosition> listOfItems = listener.itemPositions.value.toList();
      listOfItems.sort((a, b) => getAreaOfGroup(b).compareTo(getAreaOfGroup(a)));

      final int maxAreaGroupIndex = listOfItems.first.index;
      // print(maxAreaGroupIndex);
      currentActiveGroup = maxAreaGroupIndex;

      notifyListeners();
    });
  }

  Future initialize() async {
    initializingStart();
    final appState = Provider.of<AppState>(_context, listen: false);
    await appState.loadImagesDataFromCache();
    attachScrollListener();
    initializingComplete();
  }

  HomeState(this._context) {
    initialize();
  }

  navigateToConfigurationScreen() {
    final appState = Provider.of<AppState>(_context, listen: false);
    appState.navigatorKey.currentState.pushNamed(AppRoutes.config);
  }

  DateTime _lastTapTime;
  int _tapCounter;

  void handleConfigurationNavigation() {
    final _currentTapTime = DateTime.now();
    const TAP_AMOUNT = 3;

    ///When new tap
    if (_lastTapTime == null ||
        _currentTapTime.difference(_lastTapTime) > Duration(seconds: 2)) {
      _tapCounter = 1;
      _lastTapTime = _currentTapTime;

      ///REQUIREMENT | Change the position to top
      ScaffoldMessenger.of(_context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(_context)
              .tap3TimesToGoToConfigurationScreen)));
    } else {
      if (++_tapCounter == TAP_AMOUNT) {
        ///To hide the existing Snack bar on the screen from previous screen
        ScaffoldMessenger.of(_context).hideCurrentSnackBar();
        navigateToConfigurationScreen();
      }
    }
  }

  bool isGroupEmpty(int index){
    final appState = Provider.of<AppState>(_context, listen: false);
    return appState.imageGroups[index].images.isEmpty;
  }

  void handleIconTap(int index) {
    // currentActiveGroup = index;
    if(isGroupEmpty(index)){
      ScaffoldMessenger.of(_context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(_context)
              .noImagesExistInThisGroup)));
      return;
    }


    controller.scrollTo(
      index: index,
      duration: Duration(milliseconds: 300),
    );

    // notifyListeners();
  }

  Future handleStartPlayAudio(String audioPath) async {
    await _soundPlayerService.playAudio(audioPath);
  }

  Future handleStopAudio() async {
    Key k;
    await _soundPlayerService.stopAudio();
  }

  Future handleOpenImageAndPlayAudio(ImageModel image) async {
    handleStartPlayAudio(image.audioLink);
    await showDialog(
      barrierDismissible: false,
      context: _context,
      builder: (context) => ImageDetailDialog(image),
    );
    handleStopAudio();
  }
}
