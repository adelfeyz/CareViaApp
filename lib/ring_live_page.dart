import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

import 'bluetooth/bluetooth_manager.dart';
import 'bluetooth/bluetooth_uuid.dart';
import 'bluetooth/permission_manager.dart';
import 'ring_data_receiver.dart';
import 'runtime/ring_live_buffer.dart';
import 'models/health_sample.dart';

/// One-screen demo that scans, connects, shows live vitals.
class RingLivePage extends StatefulWidget {
  const RingLivePage({super.key});

  @override
  State<RingLivePage> createState() => _RingLivePageState();
}

class _RingLivePageState extends State<RingLivePage> {
  final _bt = BluetoothManager.instance;
  final _rxHeart = 0.obs, _rxSpo2 = 0.obs, _rxHrv = 0.obs;
  late final StreamSubscription<List<HealthSample>> _bufSub;
  List<HealthSample> _buffer = [];

  @override
  void initState() {
    super.initState();
    _bufSub = RingLiveBuffer().stream.listen((list) {
      setState(() => _buffer = list);
      if (list.isNotEmpty) {
        final last = list.last;
        _rxHeart.value = last.heart;
        _rxSpo2.value  = last.spo2;
        _rxHrv.value   = last.hrv;
      }
    });
    _init();
  }

  Future<void> _init() async {
    // permissions
    final ok = await requestBlePermissions();
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('BLE / GPS permissions denied')),
      );
      return;
    }

    // auto-connect first ring that advertises FILTER_UUID
    ever<List<ScanResult>>(_bt.rings, (list) async {
      if (list.isEmpty) return;
      await _bt.stopScan();
      await _bt.connect(list.first.device);
      await RingDataReceiver.instance.start();
    });

    _scan(); // kick-off
  }

  /* ---------- actions ---------- */
  Future<void> _scan()   => _bt.startScan();
  Future<void> _disconnect() async {
    await _bt.disconnect();
    _rxHeart.value = _rxSpo2.value = _rxHrv.value = 0;
  }

  /* ---------- UI ---------- */
  Widget _value(String label, RxInt v, Color c) => Obx(() => Column(
        children: [
          Text(v.value.toString(),
              style: TextStyle(fontSize: 48, color: c, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ring Live')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _value('Heart', _rxHeart, Colors.red),
                _value('SpO₂',  _rxSpo2, Colors.blue),
                _value('HRV',   _rxHrv,  Colors.green),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: _buffer.isEmpty
                  ? const Center(child: Text('Waiting for packets…'))
                  : SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: _buffer.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.heart.toDouble())).toList(),
                              color: Colors.red,
                              isCurved: false,
                              dotData: FlDotData(show: true),
                            ),
                          ],
                          titlesData: FlTitlesData(show: false),
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _disconnect,
              child: const Text('Disconnect'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => RingLiveBuffer().clear(),
        child: const Icon(Icons.delete),
      ),
    );
  }

  @override
  void dispose() {
    _bufSub.cancel();
    RingDataReceiver.instance.dispose();
    super.dispose();
  }
}