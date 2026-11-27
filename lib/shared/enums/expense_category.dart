import 'package:flutter/material.dart';

enum ExpenseCategory {
  cleaning('cleaning', 'نظافت', Icons.cleaning_services_outlined),
  repairs('repairs', 'تعمیرات', Icons.build_outlined),
  greenSpace('green_space', 'فضای سبز', Icons.grass_outlined),
  elevator('elevator', 'آسانسور', Icons.elevator_outlined),
  electricity('electricity', 'برق', Icons.bolt_outlined),
  water('water', 'آب', Icons.water_drop_outlined),
  gas('gas', 'گاز', Icons.local_fire_department_outlined),
  other('other', 'سایر', Icons.category_outlined);

  const ExpenseCategory(this.dbValue, this.label, this.icon);
  final String dbValue;
  final String label;
  final IconData icon;

  static ExpenseCategory fromDbValue(String value) => ExpenseCategory.values.firstWhere((c) => c.dbValue == value, orElse: () => ExpenseCategory.other);
}
