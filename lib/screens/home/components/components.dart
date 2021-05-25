import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:tatyanas_app/model/icon_model.dart';
import 'package:tatyanas_app/screens/home/components/image_grid.dart';
import 'package:tatyanas_app/screens/home/state/home_state.dart';
import 'package:tatyanas_app/state/app_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget getLoadingWidget() {
  return const Center(
    child: CircularProgressIndicator(),
  );
}

Widget _getSettingIcon(BuildContext context) {
  final state = Provider.of<HomeState>(context, listen: true);
  final appState = Provider.of<AppState>(context, listen: true);
  return Align(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            child: Text(!appState.pastPurchasesFetched ? "" : appState.isAvailable && !appState.isPro ? "Upgrade to Pro" : "Pro Enabled", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w700),),
            onTap: () {
              if(!appState.isPro)
                appState.upgradeToProVersion();
            },
          ),
          const Spacer(),
          GestureDetector(
            child: Icon(Icons.settings),
            onTap: () {
              state.handleConfigurationNavigation();
            },
          ),
        ],
      ),
    ),
    alignment: Alignment.centerRight,
  );
}

Widget _getImagesGrid(BuildContext context) {
  final state = Provider.of<HomeState>(context, listen: true);
  final appState = Provider.of<AppState>(context, listen: true);
  return Expanded(
    child: SizedBox(
      child: appState.imageGroups.any((element) => element.images.isNotEmpty)
          ? ScrollablePositionedList.separated(
              itemScrollController: state.controller,
              itemPositionsListener: state.listener,
              itemBuilder: (context, index) {
                final listOfGroupedImages = appState.imageGroups[index].images;

                return listOfGroupedImages.isEmpty
                    ? SizedBox()
                    : ImagesGrid(listOfGroupedImages);
              },
              separatorBuilder: (context, index) => SizedBox(
                height: appState.imageGroups[index].images.isEmpty ? 0 : 16,
              ),
              itemCount: appState.imageGroups.length,
            )
          : Text(AppLocalizations.of(context).goToConfigurationsToAddImages),
    ),
  );
}

Widget _getIconItem(BuildContext context, int index){
  final appState = Provider.of<AppState>(context, listen: true);
  final state = Provider.of<HomeState>(context, listen: true);
  return AspectRatio(
    aspectRatio: 1,
    child: GestureDetector(
      onTap: () {
        state.handleIconTap(index);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: index == 0 ? Colors.blue[300] : Colors.blue,
              width: index == 0
                  ? 4
                  : index == state.currentActiveGroup
                  ? 4
                  : 0,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: !ifSourceIsFile(appState.imageGroups[index].source)
                ? Image.asset(appState.imageGroups[index].iconLink)
                : Image.file(
              File(appState.imageGroups[index].iconLink),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _getIconsList(BuildContext context) {
  final appState = Provider.of<AppState>(context, listen: true);
  return Container(
    color: Colors.grey[200],
    height: appState.appSize.height * 0.12,
    child: ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return _getIconItem(context, index);
      },
      scrollDirection: Axis.horizontal,
      separatorBuilder: (context, index) => SizedBox(
        width: 16,
      ),
      itemCount: appState.imageGroups.length,
    ),
  );
}

Widget getBodyContent(BuildContext context) {
  return SafeArea(
    child: Container(
      child: Column(
        children: [
          const SizedBox(
            height: 16,
          ),
          _getSettingIcon(context),
          _getImagesGrid(context),
          _getIconsList(context),
        ],
      ),
    ),
  );
}
