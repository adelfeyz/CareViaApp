import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'ring_settings.dart';

class RingSettingsRepository {
  RingSettingsRepository._();
  static final RingSettingsRepository _i = RingSettingsRepository._();
  factory RingSettingsRepository() => _i;

  late Box<RingSettings> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(RingSettingsAdapter());
    }
    _box = await Hive.openBox<RingSettings>('ring_settings');
  }

  Future<void> save(RingSettings s) async {
    await _box.clear();
    await _box.add(s);
  }

  Future<void> clear() async => _box.clear();

  RingSettings? load() => _box.isNotEmpty ? _box.getAt(0) : null;

  Future<BluetoothDevice?> getSavedDevice() async {
    final s = load();
    if (s == null) return null;
    try {
      return await BluetoothDevice.fromId(s.deviceId);
    } catch (_) {
      return null;
    }
  }

  Future<void> close() => Hive.close();
} 