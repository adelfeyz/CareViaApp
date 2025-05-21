import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart';

/// Request all permissions needed for BLE scanning and connection
Future<bool> requestBlePermissions() async {
  // Ensure location services are enabled (required for BLE scanning on Android)
  final gps = Location();
  if (!await gps.serviceEnabled() && !await gps.requestService()) return false;

  // Request all required permissions
  final statuses = await [
    Permission.locationWhenInUse,
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.bluetoothAdvertise,
  ].request();
  
  return statuses.values.every((s) => s.isGranted);
} 