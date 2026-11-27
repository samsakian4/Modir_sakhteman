import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/models/charge_payment.dart';
import '../../../apartments/presentation/providers/apartment_providers.dart';
import '../providers/payment_providers.dart';

class PaymentFormPage extends ConsumerStatefulWidget {
  const PaymentFormPage({super.key, this.existingPayment, this.apartmentIdForNew});
  final ChargePayment? existingPayment;
  final String? apartmentIdForNew;
  bool get isEditMode => existingPayment != null;

  @override
  ConsumerState<PaymentFormPage> createState() => _PaymentFormPageState();
}

class _PaymentFormPageState extends ConsumerState<PaymentFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late DateTime _selectedDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final ChargePayment? existing = widget.existingPayment;
    if (existing != null) {
      _amountController.text = CurrencyFormatter.formatAmount(existing.amount);
      _descriptionController.text = existing.description ?? '';
      _selectedDate = existing.paymentDate;
    } else {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
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

    final double amount = CurrencyFormatter.parseToInt(_amountController.text)?.toDouble() ?? 0;
    final String? description = _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim();
    final Jalali jalali = DateFormatter.toJalali(_selectedDate);

    final result = widget.isEditMode
        ? await ref.read(updatePaymentUseCaseProvider)(id: widget.existingPayment!.id, amount: amount, paymentDate: _selectedDate, jalaliYear: jalali.year, jalaliMonth: jalali.month, description: description)
        : await ref.read(createPaymentUseCaseProvider)(apartmentId: widget.apartmentIdForNew ?? widget.existingPayment!.apartmentId, amount: amount, paymentDate: _selectedDate, jalaliYear: jalali.year, jalaliMonth: jalali.month, description: description);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold((failure) => AppSnackbar.error(context, failure.message), (_) {
      ref.read(paymentListProvider.notifier).refresh();
      ref.read(apartmentListProvider.notifier).refresh();
      AppSnackbar.success(context, widget.isEditMode ? 'پرداخت ویرایش شد.' : 'پرداخت با موفقیت ثبت شد.');
      context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Jalali previewJalali = DateFormatter.toJalali(_selectedDate);

    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditMode ? 'ویرایش پرداخت' : 'ثبت پرداخت شارژ')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.spaceM),
          children: [
            TextFormField(controller: _amountController, decoration: const InputDecoration(labelText: 'مبلغ (تومان)', prefixIcon: Icon(Icons.payments_outlined)), keyboardType: TextInputType.number, validator: Validators.amount),
            const SizedBox(height: AppDimensions.spaceM),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'تاریخ پرداخت', prefixIcon: Icon(Icons.calendar_today_outlined)),
                child: Text('${DateFormatter.jalaliMonthName(previewJalali.month)} ${CurrencyFormatter.toPersianDigits(previewJalali.day.toString())}، ${CurrencyFormatter.toPersianDigits(previewJalali.year.toString())}'),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceM),
            TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'توضیح (اختیاری)'), maxLines: 2),
            const SizedBox(height: AppDimensions.spaceL),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(AppDimensions.minTouchTarget)),
              child: _isSubmitting ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)) : Text(widget.isEditMode ? 'ذخیره تغییرات' : 'ثبت پرداخت'),
            ),
          ],
        ),
      ),
    );
  }
}
