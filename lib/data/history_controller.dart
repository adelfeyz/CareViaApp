import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:smartring_plugin/sdk/core.dart';
import 'package:smartring_plugin/sdk/common/ble_protocol_constant.dart';
import 'package:flutter/foundation.dart';

import '../models/history_sample.dart';
import '../runtime/ring_sdk_bridge.dart';
import 'repositories/raw_data_repository.dart';
import 'models/raw_frame.dart';

/// Controller that wraps SDK historical-data APIs and exposes Rx state
class HistoryController extends GetxController {
  final _ring = RingManager.instance;

  // observables -----------------------------------------------------------
  final RxInt totalEntries = 0.obs;
  final RxInt minUuid = 0.obs;
  final RxInt maxUuid = 0.obs;

  final RxBool loading = false.obs;
  final RxList<HistorySample> samples = <HistorySample>[].obs;

  final List<Map> _raw = [];

  @override
  void onClose() {
    // The SDK does not expose an unregister API as of now.
    super.onClose();
  }

  /* -------------------------------------------------------------------- */
  Future<void> fetchCount() async {
    loading.value = true;
    final c = Completer<void>();

    _ring.registerProcess(ReceiveType.HistoricalNum, (data) {
      debugPrint('[HistoricalNum] raw=$data');
      totalEntries.value = data['num'] ?? 0;
      minUuid.value = data['minUUID'] ?? 0;
      maxUuid.value = data['maxUUID'] ?? 0;
      loading.value = false;
      c.complete();
    });

    await RingSdkBridge().send(SendType.historicalNum);
    return c.future;
  }

  /* -------------------------------------------------------------------- */
  Future<void> fetchData() async {
    if (maxUuid.value == 0) {
      await fetchCount();
      if (maxUuid.value == 0) return; // nothing to do
    }

    loading.value = true;
    samples.clear();
    int received = 0;

    _ring.registerProcess(ReceiveType.HistoricalData, (data) {
      final uuid = data['uuid'];
      final list = data['historyArray'];
      final len = (list as List?)?.length ?? 0;
      debugPrint('[HistoricalData] pkt uuid=$uuid len=$len');

      if (list is List && list.isNotEmpty) {
        // This packet contains the entire historical dataset according to vendor spec
        debugPrint('[HistoricalData] non-empty list received – using as full payload');
        _raw.clear();
        _raw.addAll(List<Map>.from(list));
      }

      // Finish when we have at least one entry (ring sends empty packets first)
      if (_raw.isNotEmpty && !loading.value) {
        // already finished earlier
        return;
      }

      if (_raw.isNotEmpty) {
        debugPrint('Received last packet, total raw entries=${_raw.length}');
        if (_raw.isNotEmpty) {
          debugPrint('[RawExample] ${_raw.first}');
        }

        for (final m in _raw) {
          final s = HistorySample.fromMap(m);
          samples.add(s);
          // Store raw frame for pipeline
          if (m.containsKey('uuid')) {
            final int uuid = m['uuid'] is int ? m['uuid'] as int : 0;
            // Convert historical map into a RawFrame so that downstream
            // processors (sleep, HRV, etc.) can consume rich, typed data
            // instead of opaque JSON bytes.
            final frame = RawFrame(
              timeStamp: (m['timeStamp'] ?? m['timestamp'] ?? 0) is int
                  ? (m['timeStamp'] ?? m['timestamp']) as int
                  : 0,
              heartRate: m['heartRate'] ?? m['HeartRate'] ?? 0,
              motionDetectionCount: m['motionDetectionCount'] ?? m['motion'] ?? 0,
              detectionMode: m['detectionMode'] ?? 0,
              sportsMode: (() {
                final v = m['sportsMode'];
                if (v is bool) return v ? 'open' : 'close';
                if (v is int) return v == 1 ? 'open' : 'close';
                if (v is String) return v;
                return '';
              })(),
              wearStatus: ((m['wearStatus'] ?? 0) is bool)
                  ? ((m['wearStatus'] as bool) ? 1 : 0)
                  : (m['wearStatus'] ?? 0) as int,
              chargeStatus: ((m['chargeStatus'] ?? 0) is bool)
                  ? ((m['chargeStatus'] as bool) ? 1 : 0)
                  : (m['chargeStatus'] ?? 0) as int,
              uuid: uuid,
              hrv: m['hrv'],
              temperature: (m['temperature'] ?? 0).toDouble(),
              step: m['step'] ?? 0,
              reStep: m['reStep'] ?? 0,
              ox: m['ox'] ?? 0,
              rawHr: m['rawHr'],
              respiratoryRate: m['respiratoryRate'] ?? 0,
              batteryLevel: m['batteryLevel'] ?? m['battery'] ?? 0,
              // keep legacy reference for potential debugging
              kind: RawKind.history,
              payload: Uint8List.fromList(utf8.encode(jsonEncode(m))),
            );
            RawDataRepository.instance.append(frame);
          }
        }
        debugPrint('Converted samples length=${samples.length}');
        loading.value = false;
        _raw.clear();
      }
    });

    await RingSdkBridge().send(SendType.historicalData);
  }
} 