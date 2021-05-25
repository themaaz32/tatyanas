import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tatyanas_app/screens/home/components/components.dart';
import 'package:tatyanas_app/screens/home/state/home_state.dart';


class HomeWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final state = Provider.of<HomeState>(context, listen: true);

    return Scaffold(
      key: state.scaffoldKey,
      body: state.isInitializing
          ? getLoadingWidget()
          : getBodyContent(context)
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeState(context),
      child: HomeWidget(),
    );
  }
}
