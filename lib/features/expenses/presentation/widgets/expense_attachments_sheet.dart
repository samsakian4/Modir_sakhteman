import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/services/file_share.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/widgets/app_snackbar.dart';

final FutureProviderFamily<List<StoredFile>, String> expenseAttachmentsProvider = FutureProvider.family<List<StoredFile>, String>((ref, expenseId) {
  return ref.read(storageServiceProvider).list(bucket: SupabaseBuckets.expenseFiles, folder: 'expenses/$expenseId');
});

Future<void> showExpenseAttachments(BuildContext context, String expenseId) {
  return showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (_) => _AttachmentsSheet(expenseId: expenseId));
}

class _AttachmentsSheet extends ConsumerWidget {
  const _AttachmentsSheet({required this.expenseId});
  final String expenseId;

  Future<void> _open(BuildContext context, WidgetRef ref, StoredFile file) async {
    try {
      final bytes = await ref.read(storageServiceProvider).download(bucket: SupabaseBuckets.expenseFiles, path: file.path);
      await deliverFile(bytes: bytes, fileName: file.name, mimeType: mimeTypeFor(file.name));
    } catch (_) {
      if (context.mounted) AppSnackbar.error(context, 'باز کردن فایل ممکن نشد. اتصال اینترنت را بررسی کنید.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final files = ref.watch(expenseAttachmentsProvider(expenseId));
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppDimensions.spaceM, 0, AppDimensions.spaceM, AppDimensions.spaceM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('رسیدها و فاکتورها', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppDimensions.spaceS),
            files.when(
              loading: () => const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
              error: (_, __) => const Padding(padding: EdgeInsets.all(16), child: Text('دریافت فهرست فایل‌ها ممکن نشد.')),
              data: (list) {
                if (list.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Text('فایلی برای این هزینه ثبت نشده است.'));
                return Column(children: [
                  for (final StoredFile f in list)
                    ListTile(
                      leading: Icon(f.name.toLowerCase().endsWith('.pdf') ? Icons.picture_as_pdf_outlined : Icons.image_outlined),
                      title: Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: const Icon(Icons.open_in_new_rounded),
                      onTap: () => _open(context, ref, f),
                    ),
                ]);
              },
            ),
          ],
        ),
      ),
    );
  }
}
