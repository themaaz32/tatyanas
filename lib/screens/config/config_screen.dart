import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tatyanas_app/screens/config/components/components.dart';
import 'package:tatyanas_app/screens/config/state/config_state.dart';

class ConfigWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ConfigState>(context, listen: true);

    return Scaffold(
      key: state.scaffoldKey,
      body: getConfigBody(context),
    );
  }
}

class ConfigScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConfigState(context),
      child: ConfigWidget(),
    );
  }
}
