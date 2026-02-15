import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  late Box settingsBox;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  Future<void> init() async {
    settingsBox = await Hive.openBox('settings');

    final saved = settingsBox.get('themeMode', defaultValue: 'system');

    _themeMode = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;

    settingsBox.put(
      'themeMode',
      switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        _ => 'system',
      },
    );

    notifyListeners();
  }
}
