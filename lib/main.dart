import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bluetooth/bluetooth_manager.dart';
import 'package:smartring_plugin/sdk/core.dart';
import 'package:smartring_plugin/sdk/common/ble_protocol_constant.dart';
import 'bluetooth/bluetooth_uuid.dart';
import 'ring_live_page.dart';
import 'data/ring_settings_repository.dart';
import 'device_info_page.dart';
import 'sample_data_page.dart';
import 'ring_data_receiver.dart';
import 'retrieve_data_page.dart';

enum ConnStatus { disconnected, scanning, connected }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() async {
    final repo = RingSettingsRepository();
    await repo.init();

    // ---------- attempt auto-reconnect -----------------------
    final saved = await repo.getSavedDevice();
    if (saved != null) {
      try {
        await BluetoothManager.instance.connect(saved);
        await RingDataReceiver.instance.start();
      } catch (_) {
        // ignore – user can reconnect from UI
      }
    }

    return repo;
  });
  runApp(const RingApp());
}

class RingApp extends StatelessWidget {
  const RingApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Ring Demo',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const RingHome(),
    );
  }
}

class RingHome extends StatefulWidget {
  const RingHome({super.key});

  @override
  State<RingHome> createState() => _RingHomeState();
}

class _RingHomeState extends State<RingHome> {
  final _bt = BluetoothManager.instance;
  final Rx<ConnStatus> _status = ConnStatus.disconnected.obs;

  @override
  void initState() {
    super.initState();

    // initial state
    _status.value = _bt.isConnected ? ConnStatus.connected : ConnStatus.disconnected;

    // listen to scan / connect events
    _bt.addScanListener((running) {
      if (running) {
        _status.value = ConnStatus.scanning;
      } else {
        // revert to connected / disconnected after scan stops
        _status.value = _bt.isConnected ? ConnStatus.connected : ConnStatus.disconnected;
      }
    });
    _bt.addConnectListener((device, isConnect) {
      _status.value = isConnect ? ConnStatus.connected : ConnStatus.disconnected;
    });
  }

  Color _colorOf(ConnStatus s) {
    switch (s) {
      case ConnStatus.connected:
        return Colors.green;
      case ConnStatus.scanning:
        return Colors.yellow;
      case ConnStatus.disconnected:
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _colorOf(_status.value),
                  ),
                )),
            const SizedBox(width: 8),
            const Text('Smart Ring'),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ExpansionTile(
              leading: const Icon(Icons.monitor_heart),
              title: const Text('Health Data'),
              children: [
                ListTile(
                  leading: const Icon(Icons.favorite),
                  title: const Text('Live Data'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RingLivePage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.show_chart),
                  title: const Text('Sample Data'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SampleDataPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Retrieve Data'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RetrieveDataPage()),
                    );
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Device Info'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DeviceInfoPage()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Select an option from the menu', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
