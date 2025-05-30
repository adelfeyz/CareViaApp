import 'dart:typed_data';
import 'dart:math'; 

Map dealRePackage(reResult, reReason) {
  String result = "";
  String reason = "";
  switch (reResult) {
    case 0:
      result = "success";
      break;
    case 1:
      result = "fail";
      break;
    case 2:
      result = "Execution failed without validation";
      break;
  }
  switch (reReason) {
    case 1:
      reason = "Equipment automatic measurement";
      break;
    case 2:
      reason = "Equipment in operation measurement";
      break;
    case 3:
      reason = "Device App measurement in progress";
      break;
    case 4:
      reason = "parameter error";
      break;
  }
  return {"result": result, "reason": reason};
}

String joinData(ByteData view, int start, int length) {
  String hexStr = "";
  for (int index = 0; index < length; index++) {
    int i = start + index;
    if (hexStr.isEmpty && view.getUint8(i) == 0) {
      continue;
    }
    hexStr += view.getUint8(i).toRadixString(16).padLeft(2, '0');
  }
  return hexStr;
}

List<int> joinDataSn(ByteData view, int start, int length) {
  // String hexStr = "";
  // for (int index = 0; index < length; index++) {
  //   int i = start + index;
  //   hexStr += view.getUint8(i).toRadixString(16).padLeft(2, '0');
  // }
  List<int> snList = [];
    for (int index = 0; index < length; index++) {
    int i = start + index;
    snList.add(view.getUint8(i));
  }
  return snList;
}

String bleAddr(ByteData view, int start, int length,
    {bool littleEndian = true}) {
  String addr = "";
  if (littleEndian) {
    for (int index = length - 1; index >= 0; index--) {
      if (index == 0) {
        addr += view
            .getUint8(start + index)
            .toRadixString(16)
            .padLeft(2, '0')
            .toUpperCase();
      } else {
        addr +=
            "${view.getUint8(start + index).toRadixString(16).padLeft(2, '0').toUpperCase()}:";
      }
    }
  } else {
    for (int index = 0; index < length; index++) {
      if (index == length - 1) {
        addr += view
            .getUint8(start + index)
            .toRadixString(16)
            .padLeft(2, '0')
            .toUpperCase();
      } else {
        addr +=
            "${view.getUint8(start + index).toRadixString(16).padLeft(2, '0').toUpperCase()}:";
      }
    }
  }
  return addr;
}

bool isDeviceOutputHrvAndRespiratoryRate(int byte) {
  var v1 = getBits(byte, 4, 4);
  var v11 = 14;
  var result = false;

  if (v11.toRadixString(2) == v1.toRadixString(2)) {
    result = true;
  }

  return result;
}

int getBits(int byte, int start, int length) {
// 字节byte有8位bit，右移start位，截取长度为length的bit
// 10011001 右移 0位，还是10011001
// 0xFF的二进制为 11111111（8个1），右移8-length的长度，变为：00011111
// 10011001
// & 00011111
// 00011001 --------> bit
  var bit = (byte >> start) & (0xFF >> (8 - length));
  return bit;
}

String deviceVersion(ByteData view, int start, int length,
    {bool littleEndian = true}) {
  String ver = "";
  if (littleEndian) {
    for (int index = length - 1; index >= 0; index--) {
      if (index == 0) {
        ver += view.getUint8(start + index).toRadixString(16);
      } else {
        ver += "${view.getUint8(start + index).toRadixString(16)}.";
      }
    }
  } else {
    for (int index = 0; index < length; index++) {
      if (index == length - 1) {
        ver += view.getUint8(start + index).toRadixString(16);
      } else {
        ver += "${view.getUint8(start + index).toRadixString(16)}.";
      }
    }
  }
  return ver;
}

int toHrv(List<int> array, int hr) {
  final size = array.length;
  var hrAvg = 0.0;
  var hrv = 0.0;
  var rrLst;
  for (var i = 0; i < array.length; i++) {
    if (array[i] == 0) {
      continue;
    }
    final hrCur = int.parse(array[i].toString());
    final rrCur = (60000.0 / hrCur).floor();
    hrAvg += hrCur;
    if (rrLst != null) {
      hrv += pow(rrCur - rrLst, 2.0);
    }
    rrLst = rrCur;
  }
  hrAvg /= size;
  hrv /= size - 1;
  if (hrAvg >= (hr - 1) && hrAvg <= (hr + 1)) {
    return sqrt(hrv).round();
  } else {
    return -2;
  }
}

int generateRandomNumber() {
  final random = Random();

  int randomNumber = random.nextInt(5) + 95;

  return randomNumber;
}

int convertECGDataToVoltage(int data) {
  return (data * 1000 / (131072 * 80) * 1000).floor();
}

String _addLeadingZeroIfNeeded(int value) {
  return value.toString().padLeft(2, '0');
}

