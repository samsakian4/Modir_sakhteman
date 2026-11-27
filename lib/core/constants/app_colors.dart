import 'package:flutter/material.dart';

abstract class AppColors {
  AppColors._();
  static const Color primary = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFEF6C00);
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF1565C0);
  static const Color collecting = warning;
  static const Color ready = info;
  static const Color inProgress = Color(0xFF9C6ADE);
  static const Color completed = primary;
}
