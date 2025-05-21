import 'dart:async';

import 'package:get/get.dart';
import 'package:smartring_plugin/sdk/core.dart';
import 'package:smartring_plugin/sdk/common/ble_protocol_constant.dart';
import 'package:flutter/foundation.dart';

import '../models/history_sample.dart';
import '../runtime/ring_sdk_bridge.dart';

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
        }
        debugPrint('Converted samples length=${samples.length}');
        loading.value = false;
        _raw.clear();
      }
    });

    await RingSdkBridge().send(SendType.historicalData);
  }
} 