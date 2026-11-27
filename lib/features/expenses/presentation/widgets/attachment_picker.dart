import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/app_snackbar.dart';

/// Lets the admin attach receipt/invoice files (jpg, png, pdf) to an expense.
class AttachmentPicker extends StatelessWidget {
  const AttachmentPicker({super.key, required this.files, required this.onChanged});
  final List<PlatformFile> files;
  final ValueChanged<List<PlatformFile>> onChanged;

  Future<void> _pick(BuildContext context) async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: AppConstants.allowedAttachmentExtensions, allowMultiple: true, withData: true);
    if (result == null) return;
    final List<PlatformFile> next = [...files];
    for (final PlatformFile f in result.files) {
      if (f.bytes == null) continue;
      if (f.size > AppConstants.maxAttachmentSizeMb * 1024 * 1024) {
        if (context.mounted) AppSnackbar.error(context, 'حجم فایل «${f.name}» بیشتر از ${AppConstants.maxAttachmentSizeMb} مگابایت است.');
        continue;
      }
      next.add(f);
    }
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(onPressed: () => _pick(context), icon: const Icon(Icons.attach_file_rounded), label: const Text('افزودن رسید / فاکتور')),
        for (int i = 0; i < files.length; i++)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(files[i].name.toLowerCase().endsWith('.pdf') ? Icons.picture_as_pdf_outlined : Icons.image_outlined),
            title: Text(files[i].name, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => onChanged([...files]..removeAt(i))),
          ),
        const SizedBox(height: AppDimensions.spaceXXS),
      ],
    );
  }
}
