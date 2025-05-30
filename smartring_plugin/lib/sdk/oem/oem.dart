import '../global/global.dart';
import '../common/ble_protocol_constant.dart' show ReceiveType,SendType ;

var sn=[] ;

void oemR1Listener(data) {
  if (data != null) {
    var verifyData = {"sn": sn, "txt": data};
    // debugPrint("oemR1Listener $verifyData");
    callBack(SendType.startOEMVerifyR2, verifyData);
  }
}

void oemResultListener(data) {
  // debugPrint("oemResultListener data=$data ");
  // unRegisterListener(ReceiveType.OEMR1, oemR1Listener);
  // unRegisterListener(ReceiveType.OEMResult, oemResultListener);
  // unRegisterListener(ReceiveType.DeviceInfo2, deviceInfo2Listener);
}

void deviceInfo2Listener(data) {
  // debugPrint("deviceInfo2Listener $data");
  if (data != null) {
    if (data["sn8"]!= null) {
      sn = data["sn8"];
      callBack(SendType.startOEMVerify);
    }
  }
}

var callBack;

void startOem(Function caseCallback) {
  unRegisterListener(ReceiveType.OEMR1, oemR1Listener);
  unRegisterListener(ReceiveType.OEMResult, oemResultListener);
  unRegisterListener(ReceiveType.DeviceInfo2, deviceInfo2Listener);
  registerListener(ReceiveType.OEMR1, oemR1Listener);
  registerListener(ReceiveType.OEMResult, oemResultListener);
  registerListener(ReceiveType.DeviceInfo2, deviceInfo2Listener);
  // debugPrint("startOem");
  callBack = caseCallback;
  caseCallback(SendType.deviceInfo2);
}
