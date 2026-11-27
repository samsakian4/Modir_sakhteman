import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

/// Cross-platform "save / open / share" for in-memory files.
/// On web this triggers a browser download; on mobile it opens the share sheet.
Future<void> deliverFile({required Uint8List bytes, required String fileName, required String mimeType}) async {
  await SharePlus.instance.share(ShareParams(files: [XFile.fromData(bytes, name: fileName, mimeType: mimeType)], fileNameOverrides: [fileName]));
}

String mimeTypeFor(String fileName) {
  final String n = fileName.toLowerCase();
  if (n.endsWith('.pdf')) return 'application/pdf';
  if (n.endsWith('.png')) return 'image/png';
  if (n.endsWith('.jpg') || n.endsWith('.jpeg')) return 'image/jpeg';
  if (n.endsWith('.xlsx')) return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
  return 'application/octet-stream';
}
