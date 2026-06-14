import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData of(Brightness brightness) => ThemeData(
    colorSchemeSeed: const Color(0xFF00A1D6),
    useMaterial3: true,
    brightness: brightness,
    fontFamilyFallback: const [
      'Noto Sans SC',
      'PingFang SC',
      'Microsoft YaHei',
      'SimHei',
      'Arial',
    ],
  );
}
