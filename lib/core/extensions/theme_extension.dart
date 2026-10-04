import 'package:flutter/material.dart';

extension ThemeExtensions on BuildContext {
  ThemeData get appTheme => Theme.of(this).extension<ThemeData>()!;

  ThemeData get materialTheme => Theme.of(this);
}
