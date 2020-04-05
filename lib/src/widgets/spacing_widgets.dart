import 'package:flutter/material.dart';

class VerticalSpace extends StatelessWidget {
  final double height;

  const VerticalSpace(this.height);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
    );
  }
}

class HorizontalSpace extends StatelessWidget {
  final double width;

  const HorizontalSpace(this.width);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
    );
  }
}
