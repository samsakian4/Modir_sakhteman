import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../core/constants/app_constants.dart';
import '../core/network/network_info.dart';

final Provider<Connectivity> connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final Provider<NetworkInfo> networkInfoProvider = Provider<NetworkInfo>((ref) => NetworkInfoImpl(ref.watch(connectivityProvider)));

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const String _key = 'theme_mode';
  Box<dynamic> get _box => Hive.box(AppConstants.hiveSettingsBox);

  @override
  ThemeMode build() {
    final String? saved = _box.get(_key) as String?;
    return switch (saved) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.light,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _box.put(_key, mode.name);
  }
}

final NotifierProvider<ThemeModeNotifier, ThemeMode> themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
