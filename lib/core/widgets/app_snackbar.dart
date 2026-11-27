import 'package:flutter/material.dart';

abstract class AppSnackbar {
  AppSnackbar._();
  static void success(BuildContext context, String message) => _show(context, message, Colors.green.shade700, Icons.check_circle_outline);
  static void error(BuildContext context, String message) => _show(context, message, Theme.of(context).colorScheme.error, Icons.error_outline);
  static void info(BuildContext context, String message) => _show(context, message, Colors.blue.shade700, Icons.info_outline);

  static void _show(BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        backgroundColor: color,
        content: Row(children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
        ]),
      ));
  }
}
