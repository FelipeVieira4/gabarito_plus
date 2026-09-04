// responsive_container.dart
import 'package:flutter/material.dart';

class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 800,
    this.breakpoint = 700,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double maxWidth;
  final double breakpoint;
  final EdgeInsets padding;

  static bool isWide(BuildContext context, {double breakpoint = 700}) {
    return MediaQuery.of(context).size.width >= breakpoint;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}