import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeModeController extends ValueNotifier<ThemeMode> {
  ThemeModeController._() : super(ThemeMode.system);

  static final ThemeModeController instance = ThemeModeController._();

  static const String _boxName = 'app_settings';
  static const String _key = 'theme_mode';

  static Future<void> init() async {
    final box = await Hive.openBox<String>(_boxName);
    final saved = box.get(_key);
    instance.value = _decode(saved);
  }

  Future<void> set(ThemeMode mode) async {
    if (value == mode) return;
    value = mode;
    final box = Hive.box<String>(_boxName);
    await box.put(_key, _encode(mode));
  }

  static ThemeMode _decode(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _encode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  String get displayLabel {
    switch (value) {
      case ThemeMode.light:
        return 'Светлая';
      case ThemeMode.dark:
        return 'Тёмная';
      case ThemeMode.system:
        return 'Системная';
    }
  }
}
