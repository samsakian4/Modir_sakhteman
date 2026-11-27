import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';

class PhoneTextField extends StatelessWidget {
  const PhoneTextField({super.key, required this.controller, this.enabled = true, this.textInputAction = TextInputAction.next});
  final TextEditingController controller;
  final bool enabled;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.phone,
      textDirection: TextDirection.ltr,
      textInputAction: textInputAction,
      decoration: const InputDecoration(labelText: 'شماره موبایل', hintText: '09121234567', prefixIcon: Icon(Icons.phone_iphone_outlined)),
      validator: Validators.phone,
    );
  }
}
