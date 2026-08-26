import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

class AppSettings {
  final bool useSeparator;
  final String durationFormat;
  final AppThemeMode themeMode;
  final String currency;
  final int decimalPlaces;

  const AppSettings({
    this.useSeparator = false,
    this.durationFormat = '天数',
    this.themeMode = AppThemeMode.system,
    this.currency = 'CNY',
    this.decimalPlaces = 2,
  });

  AppSettings copyWith({
    bool? useSeparator,
    String? durationFormat,
    AppThemeMode? themeMode,
    String? currency,
    int? decimalPlaces,
  }) {
    return AppSettings(
      useSeparator: useSeparator ?? this.useSeparator,
      durationFormat: durationFormat ?? this.durationFormat,
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
      decimalPlaces: decimalPlaces ?? this.decimalPlaces,
    );
  }

  ThemeMode get materialThemeMode {
    switch (themeMode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }
}

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  static const _keySeparator = 'use_separator';
  static const _keyDuration = 'duration_format';
  static const _keyTheme = 'theme_mode';
  static const _keyCurrency = 'currency';
  static const _keyDecimal = 'decimal_places';

  late SharedPreferences _prefs;

  @override
  Future<AppSettings> build() async {
    _prefs = await SharedPreferences.getInstance();
    return _load();
  }

  AppSettings _load() {
    return AppSettings(
      useSeparator: _prefs.getBool(_keySeparator) ?? false,
      durationFormat: _prefs.getString(_keyDuration) ?? '天数',
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == (_prefs.getString(_keyTheme) ?? ''),
        orElse: () => AppThemeMode.system,
      ),
      currency: _prefs.getString(_keyCurrency) ?? 'CNY',
      decimalPlaces: _prefs.getInt(_keyDecimal) ?? 2,
    );
  }

  Future<void> _save(AppSettings s) async {
    await _prefs.setBool(_keySeparator, s.useSeparator);
    await _prefs.setString(_keyDuration, s.durationFormat);
    await _prefs.setString(_keyTheme, s.themeMode.name);
    await _prefs.setString(_keyCurrency, s.currency);
    await _prefs.setInt(_keyDecimal, s.decimalPlaces);
  }

  void setUseSeparator(bool v) {
    state = AsyncValue.data(state.value!.copyWith(useSeparator: v));
    _save(state.value!);
  }

  void setDurationFormat(String v) {
    state = AsyncValue.data(state.value!.copyWith(durationFormat: v));
    _save(state.value!);
  }

  void setThemeMode(AppThemeMode v) {
    state = AsyncValue.data(state.value!.copyWith(themeMode: v));
    _save(state.value!);
  }

  void setCurrency(String v) {
    state = AsyncValue.data(state.value!.copyWith(currency: v));
    _save(state.value!);
  }

  void setDecimalPlaces(int v) {
    state = AsyncValue.data(state.value!.copyWith(decimalPlaces: v));
    _save(state.value!);
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
