import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothIO {
  StreamSubscription<List<int>>? _sub;

  Future<void> write(BluetoothCharacteristic? c, List<int> v) async =>
      c?.write(v);

  Future<void> writeNoRsp(BluetoothCharacteristic? c, List<int> v) async =>
      c?.write(v, withoutResponse: true);

  Future<List<int>> read(BluetoothCharacteristic? c) async {
    if (c == null) return [];
    return await c.read();
  }

  Future<void> setNotify(BluetoothCharacteristic? c, bool enable) async {
    if (c != null) {
      await c.setNotifyValue(enable);
    }
  }

  Future<void> listen(BluetoothCharacteristic? c,
      void Function(List<int> data) onData) async {
    _sub = c?.onValueReceived.listen(onData);
    await c?.setNotifyValue(true);
  }

  Future<void> cancel() => _sub?.cancel() ?? Future.value();
}
