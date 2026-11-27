abstract class AppConstants {
  AppConstants._();
  static const String appName = 'صندوق شارژ ساختمان';
  static const String appVersion = '1.0.0';
  static const int minPasswordLength = 6;
  static const String iranPhoneRegexPattern = r'^09\d{9}$';
  static const String authEmailDomain = 'building-charge.local';
  static const int maxAttachmentSizeMb = 10;
  static const List<String> allowedAttachmentExtensions = ['jpg', 'jpeg', 'png', 'pdf'];
  static const String hiveDashboardBox = 'dashboard_cache';
  static const String hiveApartmentsBox = 'apartments_cache';
  static const String hivePaymentsBox = 'payments_cache';
  static const String hiveExpensesBox = 'expenses_cache';
  static const String hiveGoalsBox = 'goals_cache';
  static const String hiveSyncQueueBox = 'sync_queue';
  static const String hiveSessionBox = 'session';
  static const String hiveSettingsBox = 'settings';
}
