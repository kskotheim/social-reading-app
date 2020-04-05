import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_read/src/logic/style_logic.dart';

class BorderContainer extends StatelessWidget {
  final Widget child;
  BorderContainer({this.child});

  @override
  Widget build(BuildContext context) {
    bool dark = Provider.of<StyleLogic>(context).darkModeEnabled;
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: dark ? Colors.white70 : Colors.black87),
          borderRadius: BorderRadius.circular(14.0)),
      child: child,
    );
  }
}

class WeReadCard extends StatelessWidget {
  final Widget child;
  WeReadCard({this.child});
  @override
  Widget build(BuildContext context) {
    bool dark = Provider.of<StyleLogic>(context).darkModeEnabled;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: dark ? Colors.blueGrey.shade900 : Colors.blueGrey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: child,
        ),
      ),
    );
  }
}

class WeReadDialog extends StatelessWidget {
  final Widget child;

  WeReadDialog({this.child});

  @override
  Widget build(BuildContext context) {
    bool dark = Provider.of<StyleLogic>(context, listen: false).darkModeEnabled;
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: child,
        ),
      ),
      backgroundColor:
          dark ? Colors.blueGrey.shade800 : Colors.blueGrey.shade200,
    );
  }
}

class ContainerProportionalWidth extends StatelessWidget {
  final double proportion;
  final Widget child;
  ContainerProportionalWidth({this.proportion, this.child}) : assert(proportion != null);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * proportion,
      child: child,
    );
  }
}