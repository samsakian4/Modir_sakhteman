import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

abstract class LocalStorageService {
  LocalStorageService._();
  static bool _initialized = false;

  static final List<String> _boxNames = [
    AppConstants.hiveDashboardBox, AppConstants.hiveApartmentsBox, AppConstants.hivePaymentsBox,
    AppConstants.hiveExpensesBox, AppConstants.hiveGoalsBox, AppConstants.hiveSyncQueueBox,
    AppConstants.hiveSessionBox, AppConstants.hiveSettingsBox,
  ];

  static Future<void> initialize() async {
    if (_initialized) return;
    await Hive.initFlutter();
    for (final String name in _boxNames) {
      if (name == AppConstants.hiveSettingsBox) {
        await Hive.openBox<dynamic>(name); // simple key/value settings (theme etc.)
      } else {
        await Hive.openBox<Map>(name);
      }
    }
    _initialized = true;
  }

  static Box<Map> _box(String boxName) {
    if (!Hive.isBoxOpen(boxName)) throw CacheException('Box «$boxName» باز نشده است.');
    return Hive.box<Map>(boxName);
  }

  static Future<void> put(String boxName, String id, Map<String, dynamic> value) async {
    try {
      await _box(boxName).put(id, value);
    } catch (e) {
      throw CacheException('خطا در ذخیره‌سازی محلی: $e');
    }
  }

  static Map<String, dynamic>? get(String boxName, String id) => _box(boxName).get(id)?.cast<String, dynamic>();
  static List<Map<String, dynamic>> getAll(String boxName) => _box(boxName).values.map((e) => e.cast<String, dynamic>()).toList();
  static Future<void> delete(String boxName, String id) => _box(boxName).delete(id);
  static Future<void> clear(String boxName) => _box(boxName).clear();
}
