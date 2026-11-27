import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/enums/expense_category.dart';
import '../../../../shared/models/expense.dart';
import '../providers/expense_providers.dart';
import '../widgets/attachment_picker.dart';
import '../widgets/expense_attachments_sheet.dart';

class ExpenseFormPage extends ConsumerStatefulWidget {
  const ExpenseFormPage({super.key, this.existingExpense});
  final Expense? existingExpense;
  bool get isEditMode => existingExpense != null;

  @override
  ConsumerState<ExpenseFormPage> createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends ConsumerState<ExpenseFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late DateTime _selectedDate;
  late ExpenseCategory _selectedCategory;
  bool _isSubmitting = false;
  List<PlatformFile> _pendingFiles = [];

  @override
  void initState() {
    super.initState();
    final Expense? existing = widget.existingExpense;
    if (existing != null) {
      _titleController.text = existing.title;
      _amountController.text = CurrencyFormatter.formatAmount(existing.amount);
      _descriptionController.text = existing.description ?? '';
      _selectedDate = existing.expenseDate;
      _selectedCategory = existing.category;
    } else {
      _selectedDate = DateTime.now();
      _selectedCategory = ExpenseCategory.other;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 1)), locale: const Locale('fa', 'IR'));
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSubmitting = true);

    final String title = _titleController.text.trim();
    final double amount = CurrencyFormatter.parseToInt(_amountController.text)?.toDouble() ?? 0;
    final String? description = _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim();

    final result = widget.isEditMode
        ? await ref.read(updateExpenseUseCaseProvider)(id: widget.existingExpense!.id, title: title, category: _selectedCategory, amount: amount, expenseDate: _selectedDate, description: description)
        : await ref.read(createExpenseUseCaseProvider)(title: title, category: _selectedCategory, amount: amount, expenseDate: _selectedDate, description: description);

    String? uploadError;
    final Expense? saved = result.fold((_) => null, (e) => e);
    if (saved != null) {
      for (final PlatformFile file in _pendingFiles) {
        try {
          await ref.read(storageServiceProvider).upload(bucket: SupabaseBuckets.expenseFiles, path: 'expenses/${saved.id}/${file.name}', bytes: file.bytes!);
        } catch (e) {
          uploadError = e.toString();
        }
      }
      ref.invalidate(expenseAttachmentsProvider(saved.id));
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold((failure) => AppSnackbar.error(context, failure.message), (_) {
      ref.read(expenseListProvider.notifier).refresh();
      AppSnackbar.success(context, widget.isEditMode ? 'هزینه ویرایش شد.' : 'هزینه با موفقیت ثبت شد.');
      if (uploadError != null) AppSnackbar.error(context, 'هزینه ثبت شد، اما آپلود فایل ناموفق بود: $uploadError');
      context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditMode ? 'ویرایش هزینه' : 'ثبت هزینه')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.spaceM),
          children: [
            TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'عنوان هزینه'), validator: (v) => Validators.required(v, fieldName: 'عنوان')),
            const SizedBox(height: AppDimensions.spaceM),
            DropdownButtonFormField<ExpenseCategory>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(labelText: 'دسته‌بندی'),
              items: [for (final ExpenseCategory category in ExpenseCategory.values) DropdownMenuItem(value: category, child: Row(children: [Icon(category.icon, size: 20), const SizedBox(width: AppDimensions.spaceS), Text(category.label)]))],
              onChanged: (value) {
                if (value != null) setState(() => _selectedCategory = value);
              },
            ),
            const SizedBox(height: AppDimensions.spaceM),
            TextFormField(controller: _amountController, decoration: const InputDecoration(labelText: 'مبلغ (تومان)', prefixIcon: Icon(Icons.payments_outlined)), keyboardType: TextInputType.number, validator: Validators.amount),
            const SizedBox(height: AppDimensions.spaceM),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              child: InputDecorator(decoration: const InputDecoration(labelText: 'تاریخ', prefixIcon: Icon(Icons.calendar_today_outlined)), child: Text(DateFormatter.formatFull(_selectedDate))),
            ),
            const SizedBox(height: AppDimensions.spaceM),
            TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'توضیحات (اختیاری)'), maxLines: 3),
            const SizedBox(height: AppDimensions.spaceM),
            AttachmentPicker(files: _pendingFiles, onChanged: (files) => setState(() => _pendingFiles = files)),
            if (widget.isEditMode)
              TextButton.icon(onPressed: () => showExpenseAttachments(context, widget.existingExpense!.id), icon: const Icon(Icons.folder_open_outlined), label: const Text('مشاهده فایل‌های قبلی')),
            const SizedBox(height: AppDimensions.spaceL),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(AppDimensions.minTouchTarget)),
              child: _isSubmitting ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)) : Text(widget.isEditMode ? 'ذخیره تغییرات' : 'ثبت هزینه'),
            ),
          ],
        ),
      ),
    );
  }
}
