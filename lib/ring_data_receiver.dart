import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'bluetooth/bluetooth_manager.dart';
import 'bluetooth/bluetooth_uuid.dart';
import 'models/health_sample.dart';
import 'runtime/ring_live_buffer.dart';
import 'runtime/ring_sdk_bridge.dart';
import 'package:smartring_plugin/sdk/common/ble_protocol_constant.dart';
import 'data/repositories/raw_data_repository.dart';
import 'data/models/raw_frame.dart';

/// ------------------------------------------------------------
///  RingDataReceiver
///  • negotiates MTU / connection-priority once a link is up
///  • enables notifications on NOTIFY_UUID
///  • publishes every decoded packet as [HealthSample]
/// ------------------------------------------------------------
class RingDataReceiver {
  RingDataReceiver._();
  static final RingDataReceiver instance = RingDataReceiver._();

  final StreamController<HealthSample> _ctrl =
      StreamController.broadcast();

  Stream<HealthSample> get stream => _ctrl.stream;

  bool _started = false;
  int _lastUuid = 0;

  /// Call after BluetoothManager.connect succeeds.
  Future<void> start() async {
    if (_started) return;
    _started = true;

    final bt = BluetoothManager.instance;

    // ---------- optimise link – ignore if helpers absent ----------
    try {
      await (bt as dynamic).requestMtu(43);
    } catch (_) {
      // Method not available – safe to ignore
    }
    try {
      await (bt as dynamic).requestConnectionPriority();
    } catch (_) {
      // Method not available – safe to ignore
    }

    // ---------- subscribe to live packets ------------------------
    try {
      await bt.subscribe(NOTIFY_UUID, _onBytes);
      // send time sync immediately
      await RingSdkBridge().send(SendType.timeSyn);
    } catch (e, s) {
      debugPrint('❌ subscribe failed: $e\n$s');
    }
  }

  void _onBytes(List<int> bytes) {
    // forward raw packet to SDK parser so that registerProcess callbacks fire
    try {
      RingSdkBridge().feedIncoming(bytes);
    } catch (_) {}

    if (bytes.length < 4) return;           // guard
    final sample = HealthSample(
      bytes[0],                             // HR
      bytes[1],                             // SpO₂
      bytes[2] | (bytes[3] << 8),           // HRV (LE16)
    );
    _ctrl.add(sample);
    RingLiveBuffer().add(sample);

    // Store raw frame for processing
    final frame = RawFrame(
      timeStamp: DateTime.now().millisecondsSinceEpoch,
      heartRate: bytes[0],
      motionDetectionCount: 0,
      detectionMode: 0,
      sportsMode: '',
      wearStatus: 0,
      chargeStatus: 0,
      uuid: _lastUuid++,  // Use a simple incrementing counter for UUID
      ox: bytes[1],
      hrv: bytes[2] | (bytes[3] << 8),
      step: 0,
      reStep: 0,
      batteryLevel: 0,
      kind: RawKind.ppgIrOrGreen,
      payload: Uint8List.fromList(bytes),
    );
    RawDataRepository.instance.append(frame);
  }

  Future<void> dispose() async {
    await _ctrl.close();
  }
}