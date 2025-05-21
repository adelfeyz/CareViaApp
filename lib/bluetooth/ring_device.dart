import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class RingDevice {
  final BluetoothDevice device;
  final int rssi;
 
  RingDevice({required this.device, required this.rssi});
} 