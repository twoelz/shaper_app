import 'package:flutter/material.dart';

class MyVerticalFlexConstrainBox extends StatelessWidget {
  MyVerticalFlexConstrainBox({this.maxHeight, this.minHeight, this.child});
  final Widget child;
  final double maxHeight;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    // observe: Flexible here!
    return Flexible(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
          minHeight: (minHeight != null) ? minHeight : 1,
        ),
        child: (child != null) ? child : Container(),
      ),
    );
  }
}

class MyHorizontalConstrainBox extends StatelessWidget {
  MyHorizontalConstrainBox({this.maxWidth, this.minWidth, this.child});
  final Widget child;
  final double maxWidth;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    // observe: not Flexible!
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        minWidth: (minWidth != null) ? minWidth : 1,
      ),
      child: Container(
        child: (child != null) ? child : Container(),
      ),
    );
  }
}
