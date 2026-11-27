import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';

class PasswordTextField extends StatefulWidget {
  const PasswordTextField({super.key, required this.controller, this.enabled = true, this.textInputAction = TextInputAction.done, this.onSubmitted});
  final TextEditingController controller;
  final bool enabled;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: _obscure,
      textDirection: TextDirection.ltr,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: 'رمز عبور',
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined), onPressed: () => setState(() => _obscure = !_obscure)),
      ),
      validator: Validators.password,
    );
  }
}
