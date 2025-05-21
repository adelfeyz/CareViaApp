// lib/bluetooth/bluetooth_manager.dart
// A refactored Bluetooth manager that follows the provider sample:
// * Scans only for SUOTA‑capable (0xFEF5) peripherals
// * Exposes a reactive list of matching ScanResults
// * Handles connect / reconnect and characteristic collection through UuidManager
// * Delegates all read / write / notify I/O to BluetoothIO
// --------------------------------------------------------------

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

import 'bluetooth_io.dart';
import 'bluetooth_uuid.dart';
import 'bluetooth_listener.dart';
import 'permission_manager.dart';

class BluetoothManager {
  BluetoothManager._();
  static final BluetoothManager instance = BluetoothManager._();

  // Listeners --------------------------------------------------
  final _scanListener    = ScanListener();
  final _connectListener = ConnectListener();

  void addScanListener(void Function(bool) listener) =>
      _scanListener.addListener(listener);
  void addConnectListener(void Function(BluetoothDevice?, bool) listener) =>
      _connectListener.addListener(listener);

  // Internals --------------------------------------------------
  final _uuidMgr = UuidManager();
  final _io      = BluetoothIO();

  final RxList<ScanResult> _rings = <ScanResult>[].obs;
  RxList<ScanResult> get rings => _rings;

  BluetoothDevice? _device;
  bool _isScanning = false;
  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<bool>? _isScanningSub;

  bool get isConnected => _device != null;

  // ------------------------------------------------------------
  //  Scan for rings
  // ------------------------------------------------------------
  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    // a) permissions
    if (!await requestBlePermissions()) {
      throw Exception('BLE permissions denied');
    }
    if (_isScanning) return;

    _rings.clear();
    _isScanning = true;
    _scanListener.notify(isScanning: true);

    // b) LISTEN to scan stream - keep everything (no mfg-filter here)
    _scanSub ??= FlutterBluePlus.scanResults.listen((results) {
      debugPrint('\n=== Scan Results ===');
      for (final r in results) {
        debugPrint('ADV ${r.device.platformName} (${r.device.remoteId.str}), '
                 'RSSI=${r.rssi} '
                 'UUIDs=${r.advertisementData.serviceUuids}');
      }
      debugPrint('====================\n');
      
      // push the full list into the RxList for the UI
      _rings
        ..clear()
        ..addAll(results);
    });

    // c) ACTUAL SCAN - **service filter only**
    await FlutterBluePlus.startScan(
      withServices: [Guid(FILTER_UUID)],
      timeout: timeout,
    );

    // d) end-of-scan sentinel
    _isScanningSub ??= FlutterBluePlus.isScanning.listen((running) {
      if (!running) {
        _isScanning = false;
        _scanListener.notify(isScanning: false);
      }
    });
  }

  Future<void> stopScan() async {
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }
    await _scanSub?.cancel();
    _scanSub = null;
  }

  // ------------------------------------------------------------
  //  Connect / disconnect
  // ------------------------------------------------------------
  Future<void> connect(BluetoothDevice device) async {
    await stopScan();

    // --------------------------------------------------------
    //  Notify UI that we are *attempting* to connect – use the
    //  same scan listener as a simple  "progress/yellow" signal.
    // --------------------------------------------------------
    _scanListener.notify(isScanning: true); // show YELLOW ("connecting")

    bool success = false;
    try {
      await device.connect(autoConnect: false, timeout: const Duration(seconds: 10));

      // Wait a beat for service discovery to be stable
      await Future.delayed(const Duration(seconds: 1));

      // --------------------------------------------------------
      //  Discover services & characteristics
      // --------------------------------------------------------
      _uuidMgr.reset();
      final services = await device.discoverServices();
      for (final s in services) {
        _uuidMgr.collect(s.characteristics);
      }

      // Connection succeeded -------------------------------------------------
      _device = device;
      _connectListener.notify(device: device, isConnect: true);
      success = true;

      // Auto-handle disconnects ---------------------------------------------
      device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _device = null;
          _connectListener.notify(device: device, isConnect: false);
        }
      });

    } on FlutterBluePlusException catch (e) {
      // Retry once on the infamous GATT 133 (Android quirk)
      if (e.code == 133) {
        try {
          await device.clearGattCache();
          await Future.delayed(const Duration(seconds: 1));
          await device.connect(autoConnect: false);
        } catch (_) {
          // fall through to error handling below
        }
      }
      // Connection failed ----------------------------------------------------
      _connectListener.notify(device: device, isConnect: false);
      rethrow;
    } catch (e) {
      _connectListener.notify(device: device, isConnect: false);
      rethrow;
    } finally {
      // Turn off the yellow indicator regardless of outcome
      _scanListener.notify(isScanning: false);
      if (!success) {
        _device = null;
      }
    }
  }

  Future<void> disconnect() async {
    await _device?.disconnect();
    _device = null;
  }

  // ------------------------------------------------------------
  //  Convenience I/O wrappers - simplified as per sample
  // ------------------------------------------------------------
  Future<void> write(String uuid, List<int> value) => 
      _io.write(_uuidMgr[uuid], value);

  Future<void> writeNoRsp(String uuid, List<int> value) => 
      _io.writeNoRsp(_uuidMgr[uuid], value);
      
  Future<List<int>> read(String uuid) => 
      _io.read(_uuidMgr[uuid]);
      
  Future<void> subscribe(String uuid, ValueChanged<List<int>> onData) async {
    final c = _uuidMgr[uuid];
    if (c == null) {
      throw Exception('Characteristic $uuid not found');
    }
    await _io.listen(c, onData);
  }
  
  // Clean up resources
  void dispose() {
    _scanSub?.cancel();
    _isScanningSub?.cancel();
    disconnect();
  }
} 