import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

enum GoalStatus {
  collecting('collecting', 'در حال جمع‌آوری بودجه', AppColors.collecting),
  ready('ready', 'آماده اجرا', AppColors.ready),
  inProgress('in_progress', 'در حال اجرا', AppColors.inProgress),
  completed('completed', 'انجام شده', AppColors.completed);

  const GoalStatus(this.dbValue, this.label, this.color);
  final String dbValue;
  final String label;
  final Color color;

  static GoalStatus fromDbValue(String value) => GoalStatus.values.firstWhere((s) => s.dbValue == value, orElse: () => GoalStatus.collecting);
}
