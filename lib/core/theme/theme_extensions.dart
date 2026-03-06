import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

extension AppThemeContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Returns adaptive horizontal padding based on screen width.
  /// Wider screens get more padding so content doesn't hug the edges.
  double get responsivePadding {
    final width = MediaQuery.of(this).size.width;
    if (width > AppConstants.compactWidthBreakpoint) {
      return AppConstants.tabletPadding;
    }
    return AppConstants.defaultPadding;
  }

  /// Symmetric responsive EdgeInsets for horizontal padding.
  EdgeInsets get responsiveHorizontalPadding {
    return EdgeInsets.symmetric(horizontal: responsivePadding);
  }
}
