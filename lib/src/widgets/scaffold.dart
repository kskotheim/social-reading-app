

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_read/src/logic/style_logic.dart';

class WeReadScaffold extends StatelessWidget {
  final Widget body;
  Color backgroundColor;

  WeReadScaffold({this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      backgroundColor: Provider.of<StyleLogic>(context).backgroundColor,
    );
  }
}