import 'package:smartring_plugin/sdk/core.dart';
import 'package:smartring_plugin/sdk/common/ble_protocol_constant.dart';

import '../bluetooth/bluetooth_manager.dart';
import '../bluetooth/bluetooth_uuid.dart';

/// Thin glue-layer between our custom BluetoothManager and
/// the vendor RingManager. It forwards TX and RX bytes so that
/// RingManager.registerProcess callbacks fire as expected.
class RingSdkBridge {
  RingSdkBridge._();
  static final RingSdkBridge _i = RingSdkBridge._();
  factory RingSdkBridge() => _i;

  final _ring = RingManager.instance;
  final _bt   = BluetoothManager.instance;

  /// Send a BLE command via SDK → encode → write to characteristic
  Future<void> send(SendType type, [dynamic data]) async {
    final bytes = _ring.sendBle(type, data);
    await _bt.write(WRITE_UUID, bytes.toList());
  }

  /// Feed every notification packet back into the SDK parser.
  void feedIncoming(List<int> bytes) {
    _ring.receiveData(bytes);
  }
} 