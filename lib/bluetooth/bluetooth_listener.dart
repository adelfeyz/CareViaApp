// lib/bluetooth/bluetooth_listener.dart
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Base class that holds callbacks of type [T].
abstract class Listener<T extends Function> {
  final List<T> _listeners = [];

  void addListener(T listener) {
    if (!_listeners.contains(listener)) _listeners.add(listener);
  }

  void removeListener(T listener) {
    _listeners.remove(listener);
  }

  // expose a read-only iterable
  Iterable<T> get listeners => _listeners;
}

/* -------------------------------------------------------------------------- */
/*  Scan listener:  bool  ->  void                                            */
/* -------------------------------------------------------------------------- */


class ScanListener
    extends Listener<void Function(bool)> {
  void notify({ required bool isScanning }) {
    for (final cb in listeners) {
      cb(isScanning);
    }
  }
}

/* -------------------------------------------------------------------------- */
/*  Connect listener:  (BluetoothDevice?, bool)  ->  void                     */
/* -------------------------------------------------------------------------- */

class ConnectListener
    extends Listener<void Function(BluetoothDevice?, bool)> {
  void notify({
    required BluetoothDevice? device,
    required bool isConnect,
  }) {
    for (final cb in listeners) {
      cb(device, isConnect);
    }
  }
}
