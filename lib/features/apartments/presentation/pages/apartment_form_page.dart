import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/apartment.dart';
import '../providers/apartment_providers.dart';

class ApartmentFormPage extends ConsumerStatefulWidget {
  const ApartmentFormPage({super.key, this.apartmentId});
  final String? apartmentId;
  bool get isEditMode => apartmentId != null;

  @override
  ConsumerState<ApartmentFormPage> createState() => _ApartmentFormPageState();
}

class _ApartmentFormPageState extends ConsumerState<ApartmentFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _unitNumberController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _residentsCountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _prefilled = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _unitNumberController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _residentsCountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _prefillFrom(Apartment apartment) {
    if (_prefilled) return;
    _unitNumberController.text = apartment.unitNumber;
    _ownerNameController.text = apartment.ownerName;
    _phoneController.text = apartment.phone ?? '';
    _residentsCountController.text = apartment.residentsCount?.toString() ?? '';
    _notesController.text = apartment.notes ?? '';
    _prefilled = true;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSubmitting = true);

    final String unitNumber = _unitNumberController.text.trim();
    final String ownerName = _ownerNameController.text.trim();
    final String? phone = _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim();
    final int? residentsCount = _residentsCountController.text.trim().isEmpty ? null : int.tryParse(_residentsCountController.text.trim());
    final String? notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

    final result = widget.isEditMode
        ? await ref.read(updateApartmentUseCaseProvider)(id: widget.apartmentId!, unitNumber: unitNumber, ownerName: ownerName, phone: phone, residentsCount: residentsCount, notes: notes)
        : await ref.read(createApartmentUseCaseProvider)(unitNumber: unitNumber, ownerName: ownerName, phone: phone, residentsCount: residentsCount, notes: notes);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold((failure) => AppSnackbar.error(context, failure.message), (_) {
      ref.read(apartmentListProvider.notifier).refresh();
      if (widget.isEditMode) ref.invalidate(apartmentDetailProvider(widget.apartmentId!));
      AppSnackbar.success(context, widget.isEditMode ? 'واحد ویرایش شد.' : 'واحد با موفقیت ثبت شد.');
      context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget form = Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.spaceM),
        children: [
          TextFormField(controller: _unitNumberController, decoration: const InputDecoration(labelText: 'شماره واحد'), validator: Validators.unitNumber),
          const SizedBox(height: AppDimensions.spaceM),
          TextFormField(controller: _ownerNameController, decoration: const InputDecoration(labelText: 'نام مالک'), validator: (v) => Validators.required(v, fieldName: 'نام مالک')),
          const SizedBox(height: AppDimensions.spaceM),
          TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'شماره تماس (اختیاری)'), keyboardType: TextInputType.phone, textDirection: TextDirection.ltr),
          const SizedBox(height: AppDimensions.spaceM),
          TextFormField(controller: _residentsCountController, decoration: const InputDecoration(labelText: 'تعداد ساکنین (اختیاری)'), keyboardType: TextInputType.number),
          const SizedBox(height: AppDimensions.spaceM),
          TextFormField(controller: _notesController, decoration: const InputDecoration(labelText: 'توضیحات (اختیاری)'), maxLines: 3),
          const SizedBox(height: AppDimensions.spaceL),
          FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(AppDimensions.minTouchTarget)),
            child: _isSubmitting
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Text(widget.isEditMode ? 'ذخیره تغییرات' : 'افزودن واحد'),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditMode ? 'ویرایش واحد' : 'افزودن واحد')),
      body: widget.isEditMode
          ? ref.watch(apartmentDetailProvider(widget.apartmentId!)).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorView(failure: error is Failure ? error : UnknownFailure(error.toString())),
              data: (apartment) {
                _prefillFrom(apartment);
                return form;
              },
            )
          : form,
    );
  }
}
