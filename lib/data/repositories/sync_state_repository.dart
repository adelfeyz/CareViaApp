import 'package:hive/hive.dart';

/// Persists incremental-sync cursors (e.g. highest processed uuid).
class SyncStateRepository {
  SyncStateRepository._internal();
  static final SyncStateRepository instance = SyncStateRepository._internal();

  static const _boxName = 'sync_state';
  static const _kMaxUuidKey = 'maxUuid';
  static const _kLastProcessedKey = 'lastProcessed';

  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  int getLastUuid() => _box.get(_kMaxUuidKey, defaultValue: 0) as int;

  Future<void> setLastUuid(int value) => _box.put(_kMaxUuidKey, value);

  DateTime? getLastProcessedAt() {
    final millis = _box.get(_kLastProcessedKey);
    if (millis is int) return DateTime.fromMillisecondsSinceEpoch(millis);
    return null;
  }

  Future<void> setLastProcessed(DateTime dt) => _box.put(_kLastProcessedKey, dt.millisecondsSinceEpoch);
} 