import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSettings {
  final bool useSeparator;
  final String durationFormat;

  const AppSettings({this.useSeparator = false, this.durationFormat = '天数'});

  AppSettings copyWith({bool? useSeparator, String? durationFormat}) {
    return AppSettings(
      useSeparator: useSeparator ?? this.useSeparator,
      durationFormat: durationFormat ?? this.durationFormat,
    );
  }
}

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => const AppSettings();

  void setUseSeparator(bool v) => state = state.copyWith(useSeparator: v);
  void setDurationFormat(String v) => state = state.copyWith(durationFormat: v);
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
