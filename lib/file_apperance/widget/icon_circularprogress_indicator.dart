import 'package:flutter/material.dart';

class IconCircularProgressIndicator extends StatelessWidget {
  const IconCircularProgressIndicator({
    Key? key,
    this.progress,
    required this.child,
  }) : super(key: key);

  final double? progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircularProgressIndicator.adaptive(
          value: progress,
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}
