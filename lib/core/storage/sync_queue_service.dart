import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';

class SyncQueueService {
  SyncQueueService(this._uuid);
  final Uuid _uuid;

  Box<Map> get _box => Hive.box<Map>(AppConstants.hiveSyncQueueBox);

  Future<void> enqueue({required String operationType, required String entity, required Map<String, dynamic> payload}) async {
    final String id = _uuid.v4();
    await _box.put(id, {'id': id, 'operation_type': operationType, 'entity': entity, 'payload': payload, 'created_at': DateTime.now().toIso8601String()});
  }

  List<Map<String, dynamic>> get pendingOperations => _box.values.map((e) => e.cast<String, dynamic>()).toList();
  Future<void> remove(String id) => _box.delete(id);
}
