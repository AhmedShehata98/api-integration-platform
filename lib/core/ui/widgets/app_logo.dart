import 'package:flutter/material.dart';

/// The Test Point logo. The 256 px image keeps it sharp at sizes up to 128.
class AppLogo extends StatelessWidget {
  const AppLogo({this.size = 40, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo/128x128@2x.png',
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'Test Point',
    );
  }
}
