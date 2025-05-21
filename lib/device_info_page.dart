import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bluetooth/bluetooth_manager.dart';
import 'bluetooth/bluetooth_uuid.dart';
import 'data/ring_settings_repository.dart';
import 'data/ring_settings.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({super.key});

  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  final _repo = Get.find<RingSettingsRepository>();
  final _bt   = BluetoothManager.instance;

  late final Rx<RingSettings?> _settings;
  final RxBool _isScanning = false.obs;

  @override
  void initState() {
    super.initState();
    _settings = Rx<RingSettings?>(_repo.load());

    // listen to scan updates to refresh UI
    _bt.addScanListener((s) => _isScanning.value = s);
  }

  /* ---------- actions ---------- */
  Future<void> _startScan() async {
    await _bt.startScan();
  }

  Future<void> _connectAndSave(ScanResult r) async {
    try {
      await _bt.connect(r.device);
      final s = RingSettings(
        deviceId: r.device.remoteId.str,
        name: r.device.platformName,
        color: '',
        size: 0,
      );
      await _repo.save(s);
      _settings.value = s;
    } catch (e) {
      Get.snackbar('Connect', 'Failed: $e');
    }
  }

  Future<void> _delete() async {
    await _bt.disconnect();
    await _repo.clear();
    _settings.value = null;
  }

  /* ---------- UI widgets ---------- */
  Widget _info(RingSettings s) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Device ID', s.deviceId),
            _row('Name', s.name),
            _row('Color', s.color),
            _row('Size', s.size.toString()),
            _row('Saved at', s.savedAt.toLocal().toString()),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _delete,
              icon: const Icon(Icons.delete),
              label: const Text('Forget Device'),
            ),
          ],
        ),
      );

  Widget _scanner() => Column(
        children: [
          if (_isScanning.value) const CircularProgressIndicator(),
          Obx(() => ListView.builder(
                shrinkWrap: true,
                itemCount: _bt.rings.length,
                itemBuilder: (_, i) {
                  final r = _bt.rings[i];
                  return ListTile(
                    title: Text(r.device.platformName.isEmpty
                        ? r.device.remoteId.str
                        : r.device.platformName),
                    subtitle: Text('RSSI ${r.rssi}'),
                    onTap: () => _connectAndSave(r),
                  );
                },
              )),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _startScan, child: const Text('Scan')),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device Info')),
      body: Obx(() {
        final s = _settings.value;
        return s == null ? _scanner() : _info(s);
      }),
    );
  }

  Widget _row(String label, String value) => Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      );
} 