import 'package:flutter/material.dart';
import 'package:techgadoll_app/core/theme/app_theme.dart';

Widget pumpApp(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    home: Scaffold(body: child),
  );
}
