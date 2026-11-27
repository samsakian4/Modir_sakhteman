import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import 'supabase_service.dart';

class StoredFile {
  const StoredFile({required this.name, required this.path});
  final String name;
  final String path;
}

/// Backend-agnostic file storage contract (doc 21: no Supabase calls in UI).
abstract class StorageService {
  Future<void> upload({required String bucket, required String path, required Uint8List bytes});
  Future<List<StoredFile>> list({required String bucket, required String folder});
  Future<Uint8List> download({required String bucket, required String path});
}

class SupabaseStorageService implements StorageService {
  SupabaseStorageService(this._client);
  final sb.SupabaseClient _client;

  static String _safeName(String name) => name.replaceAll(RegExp(r'[^\w.\-]'), '_');

  @override
  Future<void> upload({required String bucket, required String path, required Uint8List bytes}) async {
    final String name = path.split('/').last;
    final String ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    if (!AppConstants.allowedAttachmentExtensions.contains(ext)) throw const StorageException();
    if (bytes.length > AppConstants.maxAttachmentSizeMb * 1024 * 1024) {
      throw StorageException('حجم فایل نباید بیشتر از ${AppConstants.maxAttachmentSizeMb} مگابایت باشد.');
    }
    final String target = '${path.substring(0, path.lastIndexOf('/') + 1)}${DateTime.now().millisecondsSinceEpoch}_${_safeName(name)}';
    try {
      await _client.storage.from(bucket).uploadBinary(target, bytes);
    } on sb.StorageException catch (e) {
      throw StorageException(e.message);
    } catch (e) {
      final String t = e.toString().toLowerCase();
      if (t.contains('failed to fetch') || t.contains('socket') || t.contains('network')) throw const NetworkException();
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<StoredFile>> list({required String bucket, required String folder}) async {
    try {
      final List<sb.FileObject> objects = await _client.storage.from(bucket).list(path: folder);
      return [for (final sb.FileObject o in objects) if (o.id != null) StoredFile(name: o.name, path: '$folder/${o.name}')];
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Uint8List> download({required String bucket, required String path}) async {
    try {
      return await _client.storage.from(bucket).download(path);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

final Provider<StorageService> storageServiceProvider = Provider<StorageService>((ref) => SupabaseStorageService(SupabaseService.client));
