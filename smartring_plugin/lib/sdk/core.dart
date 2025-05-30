import 'dart:typed_data';

import './data/send_part/control_send.dart';
import './data/receive_part/process.dart';
import './global/global.dart';
import './oem/oem.dart';
import 'utils/batteryUtil.dart';
import './utils/util.dart';

class RingManager {
  static final RingManager _instance = RingManager._internal();

  late ControlSend controlSend;
  

  factory RingManager() {
    return _instance;
  }

  RingManager._internal() {
    _init();
  }

  static RingManager get instance => _instance;

  void _init() {
    controlSend = ControlSend();
  }

  //send data to ble
  Uint8List sendBle(Enum key, [data]) {
    return controlSend.send(key, data);
  }

  //receive data from ble
  void receiveData(data) {
    parseReceiveData(data);
  }

  void registerProcess(int receiveType, Function listener) {
    unRegisterProcess(receiveType, listener);
    registerListener(receiveType, listener);
  }

  void unRegisterProcess(int receiveType, Function listener) {
    unRegisterListener(receiveType, listener);
  }

  //oem verify
  void startOEMVerify(caseCallback) {
    startOem(caseCallback);
  }

  Map parseBroadcastData(List<int> data, bool isAndroid) {
    return parseBroadcast(data, isAndroid);
  }

  int calcBattery(voltage, charging, wireless) {
    return toBatteryLevel(voltage, charging, wireless);
  }

  int convertToVoltage(data){
    return convertECGDataToVoltage(data);
  }
}
