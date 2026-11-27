import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import '../widgets/password_text_field.dart';
import '../widgets/phone_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final String phone = CurrencyFormatter.toEnglishDigits(_phoneController.text.trim());
    await ref.read(authProvider.notifier).login(phone: phone, password: _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next case AuthUnauthenticated(:final errorMessage?)) {
        if (previous is AuthLoading) AppSnackbar.error(context, errorMessage);
      }
    });

    final AuthState authState = ref.watch(authProvider);
    final bool isSubmitting = authState is AuthLoading;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spaceL),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppDimensions.spaceXXL),
                    Center(
                      child: Container(
                        width: 88, height: 88,
                        decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(AppDimensions.radiusXL)),
                        child: Icon(Icons.savings_outlined, size: AppDimensions.iconXL, color: scheme.onPrimaryContainer),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceM),
                    Text(AppConstants.appName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: AppDimensions.spaceXXL),
                    PhoneTextField(controller: _phoneController, enabled: !isSubmitting),
                    const SizedBox(height: AppDimensions.spaceM),
                    PasswordTextField(controller: _passwordController, enabled: !isSubmitting, onSubmitted: (_) => _submit()),
                    const SizedBox(height: AppDimensions.spaceL),
                    FilledButton(
                      onPressed: isSubmitting ? null : _submit,
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(AppDimensions.minTouchTarget)),
                      child: isSubmitting
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                          : const Text('ورود'),
                    ),
                    const SizedBox(height: AppDimensions.spaceXXL),
                    Center(child: Text('نسخه ${AppConstants.appVersion}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
