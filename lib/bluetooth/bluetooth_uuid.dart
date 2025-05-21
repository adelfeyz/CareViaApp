import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// Core UUIDs used for scanning and communication
const FILTER_UUID  = "0000FEF5-0000-1000-8000-00805F9B34FB";   // <- use as scan filter
const UUID_SERVICE = "00001822-0000-1000-8000-00805F9B34FB";   // 0x1822 in iOS
const WRITE_UUID   = "000066FE-0000-1000-8000-00805F9B34FB";
const NOTIFY_UUID  = "000066FE-0000-1000-8000-00805F9B34FB";

class UuidManager {
  final List<String> _uuids = [];
  final List<BluetoothCharacteristic> _chars = [];

  void reset() { _uuids.clear(); _chars.clear(); }

  void collect(List<BluetoothCharacteristic> list) {
    for (final c in list) {
      var id = c.characteristicUuid.toString().toUpperCase();
      if (id.length == 4) id = '0000$id-0000-1000-8000-00805F9B34FB';
      if (!_uuids.contains(id)) { _uuids.add(id); _chars.add(c); }
    }
  }

  BluetoothCharacteristic? operator [](String uuid) {
    final i = _uuids.indexOf(uuid);
    return i == -1 ? null : _chars[i];
  }
}
