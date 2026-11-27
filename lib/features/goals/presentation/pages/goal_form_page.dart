import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/models/goal.dart';
import '../providers/goal_providers.dart';

class GoalFormPage extends ConsumerStatefulWidget {
  const GoalFormPage({super.key, this.existingGoal});
  final Goal? existingGoal;
  bool get isEditMode => existingGoal != null;

  @override
  ConsumerState<GoalFormPage> createState() => _GoalFormPageState();
}

class _GoalFormPageState extends ConsumerState<GoalFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  final TextEditingController _currentAmountController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final Goal? existing = widget.existingGoal;
    if (existing != null) {
      _titleController.text = existing.title;
      _descriptionController.text = existing.description ?? '';
      _targetAmountController.text = CurrencyFormatter.formatAmount(existing.targetAmount);
      _currentAmountController.text = CurrencyFormatter.formatAmount(existing.currentAmount);
      _startDate = existing.startDate;
      _endDate = existing.endDate;
    } else {
      _currentAmountController.text = CurrencyFormatter.formatAmount(0);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final DateTime initial = (isStart ? _startDate : _endDate) ?? DateTime.now();
    final DateTime? picked = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(2020), lastDate: DateTime(2035), locale: const Locale('fa', 'IR'));
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSubmitting = true);

    final String title = _titleController.text.trim();
    final String? description = _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim();
    final double targetAmount = CurrencyFormatter.parseToInt(_targetAmountController.text)?.toDouble() ?? 0;
    final double currentAmount = CurrencyFormatter.parseToInt(_currentAmountController.text)?.toDouble() ?? 0;

    final result = widget.isEditMode
        ? await ref.read(updateGoalUseCaseProvider)(id: widget.existingGoal!.id, title: title, description: description, targetAmount: targetAmount, currentAmount: currentAmount, startDate: _startDate, endDate: _endDate)
        : await ref.read(createGoalUseCaseProvider)(title: title, description: description, targetAmount: targetAmount, currentAmount: currentAmount, startDate: _startDate, endDate: _endDate);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold((failure) => AppSnackbar.error(context, failure.message), (_) {
      ref.read(goalListProvider.notifier).refresh();
      AppSnackbar.success(context, widget.isEditMode ? 'هدف ویرایش شد.' : 'هدف جدید با موفقیت ثبت شد.');
      context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditMode ? 'ویرایش هدف' : 'هدف جدید')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.spaceM),
          children: [
            TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'عنوان هدف'), validator: (v) => Validators.required(v, fieldName: 'عنوان')),
            const SizedBox(height: AppDimensions.spaceM),
            TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'توضیحات (اختیاری)'), maxLines: 3),
            const SizedBox(height: AppDimensions.spaceM),
            TextFormField(controller: _targetAmountController, decoration: const InputDecoration(labelText: 'مبلغ موردنیاز (تومان)', prefixIcon: Icon(Icons.flag_outlined)), keyboardType: TextInputType.number, validator: Validators.amount),
            const SizedBox(height: AppDimensions.spaceM),
            TextFormField(
              controller: _currentAmountController,
              decoration: const InputDecoration(labelText: 'مبلغ تأمین‌شده تاکنون (تومان)', prefixIcon: Icon(Icons.savings_outlined)),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'لطفاً مبلغ را وارد کنید (در صورت نبود مبلغ، صفر وارد کنید).';
                final int? parsed = CurrencyFormatter.parseToInt(v);
                if (parsed == null || parsed < 0) return 'لطفاً مبلغ معتبر وارد کنید.';
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.spaceM),
            InkWell(
              onTap: () => _pickDate(isStart: true),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              child: InputDecorator(decoration: const InputDecoration(labelText: 'تاریخ شروع (اختیاری)', prefixIcon: Icon(Icons.calendar_today_outlined)), child: Text(_startDate == null ? 'انتخاب نشده' : DateFormatter.formatFull(_startDate!))),
            ),
            const SizedBox(height: AppDimensions.spaceM),
            InkWell(
              onTap: () => _pickDate(isStart: false),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              child: InputDecorator(decoration: const InputDecoration(labelText: 'مهلت پایان (اختیاری)', prefixIcon: Icon(Icons.event_outlined)), child: Text(_endDate == null ? 'انتخاب نشده' : DateFormatter.formatFull(_endDate!))),
            ),
            const SizedBox(height: AppDimensions.spaceL),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(AppDimensions.minTouchTarget)),
              child: _isSubmitting ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)) : Text(widget.isEditMode ? 'ذخیره تغییرات' : 'ثبت هدف'),
            ),
          ],
        ),
      ),
    );
  }
}
