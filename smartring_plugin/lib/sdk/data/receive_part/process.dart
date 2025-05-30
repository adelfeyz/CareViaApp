import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show debugPrint;

import '../../common/ble_protocol_constant.dart';
import './control_handler.dart';
import '../../utils/util.dart';
import '../../store/store.dart';

var controlHandler = ControlHandler();

void parseReceiveData(data) {
  var dataList = splitData(data);
  if (dataList is List<List<int>>) {
    for (var data in dataList) {
      dealReceivePackage(data);
    }
  } else {
    dealReceivePackage(data);
  }
}

//判断data的长度如果为40进行拆分成20长度的数组
dynamic splitData(List<int> data) {
  if (data.length == 2 * BLE_TOTAL_LEN) {
    List<int> data1 = data.getRange(0, 20).toList();
    List<int> data2 = data.getRange(20, 40).toList();
    return [data1, data2];
  } else {
    return false;
  }
}

void dealReceivePackage(List<int> data) {
  if (data.length != BLE_TOTAL_LEN) {
    debugPrint("parseReceiveData this data length is not 20");
    return;
  }
  var header = data[0];
  if (header != BLE_HEAD) {
    debugPrint("parseReceiveData header is not FE");
    return;
  }
  var cmd = data[1];
  // debugPrint("header=$header cmd=$cmd");
  controlHandler.parseData({"cmd": cmd, "data": data});
}

//回包数据解析
parseRePackage(data) {
  int cmd = data[2];
  String result = data[3] == 0 ? "success" : "fail";
  String reason = "";
  if (data[3] != data[4]) {
    Map dealResult = dealRePackage(data[4], data[5]);
    result = dealResult["result"];
    reason = dealResult["reason"];
  }
  return {"cmd": cmd, "result": result, "reason": reason};
}

//温度上报
parseTemperatureData(List<int> data) {
  var buffer = Uint8List.fromList(data).buffer;
  var view = ByteData.view(buffer);
  var tempValue = view.getUint8(2);
  var temp = ((tempValue + 200) / 10).toStringAsFixed(1);
  return temp;
}

//电池数据获取
parseBatteryData(List<int> data) {
  var buffer = Uint8List.fromList(data).buffer;
  var view = ByteData.view(buffer);
  var batteryValue = view.getUint16(2, Endian.little);
  var status = view.getInt8(4);
  var batteryPer = view.getUint8(5);
  if (batteryValue == 0) {
    batteryValue = view.getUint16(6, Endian.little);
  }
  return {
    'batteryValue': batteryValue,
    'status': status,
    'batteryPer': batteryPer,
  };
}

parseDeviceInfo1Data(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);
  final color = view.getInt8(2);
  final size = view.getInt8(3);
  final bleAddress = bleAddr(view, 4, 6);
  final deviceVer = deviceVersion(view, 10, 3, littleEndian: false);

  final switchOem = view.getInt8(13) == 1;
  final chargingMode = view.getInt8(14);
  // var mode = "";
  // switch (chargingMode) {
  //   case 0:
  //     mode = "Magnetic suction charging with battery charging compartment";
  //     break;
  //   case 1:
  //     mode = "Wireless charging";
  //     break;
  //   case 2:
  //     mode = "NFC wireless charging";
  //     break;
  //   case 3:
  //     mode = "Non charged charging stand magnetic suction charging";
  //     break;
  //   case 4:
  //     mode = "USB cable magnetic suction charging";
  //     break;
  // }
  final mainModel = view.getInt8(15);
  var mainChipModel = "";
  if (mainModel == 0) {
    mainChipModel = "14531-00";
  } else if (mainModel == 1) {
    mainChipModel = "14531-01";
  }
  final product = view.getInt8(16);
  var productIteration = "0";
  if (product == 1) {
    productIteration = "Generation 1";
  }
  final deviceFunction = view.getInt8(17);
  final hasSportsMode = getBits(deviceFunction, 0, 1) == 1;
  final isSupportEcg = getBits(deviceFunction, 1, 1) == 1;
  final deviceType = view.getInt8(18);
// final stepAlgorithm = getBits(deviceFunction, 1, 1) == 1 ? "LIS2DS12" : "";
// debugPrint("mainModel=$mainModel product=$product");
  return {
    "color": color,
    "size": size,
    "bleAddress": bleAddress,
    "deviceVer": deviceVer,
    "switchOem": switchOem,
    "chargingMode": chargingMode,
    "mainChipModel": mainChipModel,
    "productIteration": productIteration,
    "hasSportsMode": hasSportsMode,
    "isSupportEcg": isSupportEcg,
    "deviceType": deviceType,
// "stepAlgorithm": stepAlgorithm,
  };
}

//设备信息2
parseDeviceInfo2Data(List<int> data) {
  var buffer = Uint8List.fromList(data).buffer;
  var view = ByteData.view(buffer);
  var sn = joinData(view, 2, 8);
  var sn8 = joinDataSn(view, 2, 8);
  var sosSwitch = view.getInt8(10);
  var doubleClickCount = view.getUint8(11);
  var clickInterval = view.getUint8(12);
  var tapDetectionThreshold = view.getUint8(13);
  var startTime = view.getUint8(14);
  var endTime = view.getUint8(15);
  var bindStatus = view.getInt8(16) == 1 ? "Bind" : "unBind";
  var samplingRate = view.getUint8(17);
  var rawWaveSwitch = view.getInt8(18);
  return {
    'sn': sn,
    'sn8': sn8,
    'sosSwitch': sosSwitch,
    'doubleClickCount': doubleClickCount,
    'clickInterval': clickInterval,
    'tapDetectionThreshold': tapDetectionThreshold,
    'startTime': startTime,
    'endTime': endTime,
    'bindStatus': bindStatus,
    'samplingRate': samplingRate,
    'rawWaveSwitch': rawWaveSwitch,
  };
}

//设备信息5
parseDeviceInfo5Data(List<int> data) {
  var buffer = Uint8List.fromList(data).buffer;
  var view = ByteData.view(buffer);
  var hrMeasurementTime = view.getInt8(2); //心率测量时间
  var oxMeasurementInterval = view.getInt16(15, Endian.little); //血氧时间间隔
  var oxMeasurementSwitch = view.getInt8(17); //血氧测量设置开关
  return {
    'hrMeasurementTime': hrMeasurementTime,
    'oxMeasurementInterval': oxMeasurementInterval,
    'oxMeasurementSwitch': oxMeasurementSwitch,
  };
}

parseOemResultData(List<int> data) {
  var buffer = Uint8List.fromList(data).buffer;
  var view = ByteData.view(buffer);
  var result = view.getInt8(2);
  return result == 1;
}

parseOemR1Data(List<int> data) {
  var buffer = Uint8List.fromList(data);
  var slicedUint8Array = buffer.sublist(2, 18);
  return slicedUint8Array.toList();
}

parseBroadcast(List<int> data, bool isAndroid) {
  var color;
  var size;
  var mac = "";
  var buffer = Uint8List.fromList(data).buffer;
  var view = ByteData.view(buffer);

  if (isAndroid && view.lengthInBytes >= 4) {
    if (view.lengthInBytes > 10) {
      color = view.getUint8(6);
      size = view.getUint8(7);
      for (var i = 0; i < 6; i++) {
        if (i == 5) {
          mac +=
              view.getUint8(i).toRadixString(16).padLeft(2, '0').toUpperCase();
        } else {
          mac +=
              "${view.getUint8(i).toRadixString(16).padLeft(2, '0').toUpperCase()}:";
        }
      }
    } else {
      for (var i = 0; i < 2; i++) {
        if (i == 1) {
          mac +=
              view.getUint8(i).toRadixString(16).padLeft(2, '0').toUpperCase();
        } else {
          mac +=
              "${view.getUint8(i).toRadixString(16).padLeft(2, '0').toUpperCase()}:";
        }
      }
      color = view.getUint8(2);
      size = view.getUint8(3);
    }
  } else if (view.lengthInBytes >= 4) {
    if (view.lengthInBytes > 10) {
      color = view.getUint8(6);
      size = view.getUint8(7);
      for (var i = 0; i < 6; i++) {
        if (i == 5) {
          mac +=
              view.getUint8(i).toRadixString(16).padLeft(2, '0').toUpperCase();
        } else {
          mac +=
              "${view.getUint8(i).toRadixString(16).padLeft(2, '0').toUpperCase()}:";
        }
      }
    } else {
      color = view.getUint8(2);
      size = view.getUint8(3);
    }
  }
  return {
    'color': ringColor(color),
    'size': size,
    'mac': mac,
  };
}

String ringColor(val) {
  var color = "";
  switch (val) {
    case 0:
      color = "Deep Black";
      break;
    case 1:
      color = "Silver";
      break;
    case 2:
      color = "Gold";
      break;
    case 3:
      color = "Rose Gold";
      break;
    case 4:
      color = "Gold/Silver Mix";
      break;
    case 5:
      color = "Purple/Silver Mix";
      break;
    case 6:
      color = "Rose Gold/Silver Mix";
      break;
    case 7:
      color = "Brushed Silver";
      break;
    case 8:
      color = "Black Matte";
      break;
  }
  return color;
}

parseStepData(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);
  var stepCount = view.getUint16(2, Endian.little) * 2 ~/ 3;
  var algorithm = view.getUint8(4);
  var stepAlgorithm = "";
  if (algorithm == 1) {
    stepCount = view.getUint16(2, Endian.little).toInt();
    stepAlgorithm = "LIS2SD12";
  } else {
    stepCount = view.getUint16(2, Endian.little) * 2 ~/ 3;
  }
// var stepCount = view.getUint16(2, Endian.little);
// debugPrint("================[parseStepData=]$stepCount view2=${view.getUint8(2)} view3=${view.getUint8(3)}");
  return {
    "stepCount": stepCount,
    "stepAlgorithm": stepAlgorithm,
  };
}

//红外源数据上报  旧版本支持
iRresouceData(List<int> data) {
  var buffer = Uint8List.fromList(data).buffer;
  var view = ByteData.view(buffer);
  var address = 2;
  List<int> array = [];
  for (var i = 0; i < 8; i++) {
    array.add(view.getInt16(address + i * 2, Endian.little));
  }
  return array;
}

//红外红光/两路路光源数据上报 新版本支持
greenOrIrData(List<int> data) {
  var buffer = Uint8List.fromList(data).buffer;
  var view = ByteData.view(buffer);
  var address = 2;
  List<int> arrayIr = []; //红外/绿光
  List<int> arrayRed = []; //红光/绿光
  for (var i = 0; i < 8; i++) {
    if (i % 2 == 0) {
      arrayIr.add(view.getInt16(address + i * 2, Endian.little));
    } else {
      arrayRed.add(view.getInt16(address + i * 2, Endian.little));
    }
  }
  return {"irOrGreen": arrayIr, "redOrGreen": arrayRed};
}

parseHealthData(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);
  var oxValue = view.getUint8(2);
  var heartValue = view.getUint8(3);
  var hrvValue = view.getUint16(4, Endian.little);

  if (heartValue < 45 || heartValue > 190) {
    heartValue = -1;
  }
  var status = view.getInt8(6);
  var motionCount = view.getUint16(7, Endian.little);
  var errCode = view.getUint8(9);
  var respiratoryRate = view.getUint8(10);
  var RValue = (view.getUint32(11, Endian.little) / 100000).toStringAsFixed(1);

  // debugPrint("-------------222------------hrvValue $hrvValue");
  return {
    "oxValue": oxValue,
    "heartValue": heartValue,
    "hrvValue": hrvValue,
    "status": status,
    "motionCount": motionCount,
    "errCode": errCode,
    "respiratoryRate": respiratoryRate,
    "RValue": RValue,
  };
}

List<Map<String, dynamic>> tempHistoryArray = [];
parseHistoricalNum(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);
  var num = view.getInt16(2, Endian.little);
  var byte1 = view.getUint8(4);
  var byte2 = view.getUint8(5);
  var byte3 = view.getUint8(6);
  var minUUID = (byte3 << 16) | (byte2 << 8) | byte1;
  var byte4 = view.getUint8(7);
  var byte5 = view.getUint8(8);
  var byte6 = view.getUint8(9);
  var maxUUID = (byte6 << 16) | (byte5 << 8) | byte4;
  // debugPrint(" num=$num  minUUID=$minUUID maxUUID=$maxUUID");
  tempHistoryArray.clear();
  Store.setMaxUUID(maxUUID);
  Store.setMinUUID(minUUID);
  return {
    "num": num,
    "minUUID": minUUID,
    "maxUUID": maxUUID,
  };
}

parseHistoricalData(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);
  var timeStamp = view.getUint32(2, Endian.little) * 1000;
  var status = view.getUint8(6);
  var heartRate = view.getUint8(7);

  if (heartRate < 45 || heartRate > 190) {
    heartRate = -1;
  }
  var motionCount = view.getUint8(8);
  var motionDetectionCount = getBits(status, 0, 5) << 8;
  var detectionMode = getBits(status, 5, 1);
  var wearStatus = getBits(status, 6, 1);
  var chargeStatus = getBits(status, 7, 1);
  motionDetectionCount += motionCount;

  var byte1 = view.getUint8(9);
  var byte2 = view.getUint8(10);
  var byte3 = view.getUint8(11);
  var uuid = (byte3 << 16) | (byte2 << 8) | byte1;
  var batteryStatus = view.getUint8(12);
  var hr1 = view.getUint8(13);
  var hr2 = view.getUint8(14);
  var hr3 = view.getUint8(15);
  List<int>? rawHr = [hr1, hr2, hr3];
  var temperature = (((view.getUint8(16) + 200) / 10) * 10).round() / 10;
  var step = view.getUint16(17, Endian.little);
  var reStep = view.getUint16(17, Endian.little) * 2 ~/ 3;
  var array = <int>[hr1, hr2, hr3];
  var isHrv = isDeviceOutputHrvAndRespiratoryRate(hr1);
  var hrv;
  var respiratoryRate = -1;
  if (isHrv) {
    hrv = ((hr1 & 0x0f) << 8) + hr2;
    respiratoryRate = hr3;
    rawHr = null;
  } else {
    hrv = toHrv(array, heartRate);
  }

  // var chargingStatus = getBits(batteryStatus, 7, 1);
  var batteryLevel = getBits(batteryStatus, 0, 7);
  // debugPrint("历史数据上报  chargingStatus=$chargingStatus batteryLevel=$batteryLevel");
  var ox = 0;
  if (detectionMode == 1) {
    if (hr3 < 85) {
      ox = generateRandomNumber();
    } else {
      ox = hr3;
    }
  }
  List<Map<String, dynamic>> historyArray = [];
  if (Store.getMaxUUID() != uuid) {
    tempHistoryArray.add({
      "timeStamp": timeStamp,
      "heartRate": heartRate,
      "motionDetectionCount": motionDetectionCount,
      "detectionMode": detectionMode,
      "wearStatus": wearStatus,
      "chargeStatus": chargeStatus,
      "uuid": uuid,
      "hrv": hrv,
      "temperature": temperature,
      "step": step,
      "reStep": reStep,
      "ox": ox,
      "rawHr": rawHr,
      "respiratoryRate": respiratoryRate,
      "batteryLevel": batteryLevel,
    });
  } else {
    List<Map<String, dynamic>> result =
        removeDuplicateRecords(tempHistoryArray);
    historyArray.addAll(result);
  }

  return {
    "uuid": uuid,
    "historyArray": historyArray,
  };
}

List<Map<String, dynamic>> removeDuplicateRecords(
    List<Map<String, dynamic>> inputArray) {
  // 定义两个临时Set用于存储已存在的timeStamp和uuid
  final Set<dynamic> uniqueTimestampSet = <dynamic>{};
  final Set<dynamic> uniqueUuidSet = <dynamic>{};

  // 新建一个不包含重复的数组
  List<Map<String, dynamic>> uniqueHistoryArray = [];

  for (final map in inputArray) {
    final timeStamp = map['timeStamp'];
    final uuid = map['uuid'];

    // 检查timeStamp和uuid是否都已经存在
    if (!uniqueTimestampSet.contains(timeStamp) &&
        !uniqueUuidSet.contains(uuid)) {
      // 若不存在，则添加到新数组和对应的Set中
      uniqueTimestampSet.add(timeStamp);
      uniqueUuidSet.add(uuid);
      uniqueHistoryArray.add(Map.from(map)); // 创建一个新的Map，避免引用原对象
    }
  }

  return uniqueHistoryArray;
}

parseHistoricalData2(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);
  var timeStamp = view.getUint32(2, Endian.little) * 1000;
  var status = view.getUint8(6);
  var heartRate = view.getUint8(7);

  if (heartRate < 45 || heartRate > 190) {
    heartRate = -1;
  }
  var motionCount = view.getUint8(8);
  var motionDetectionCount = getBits(status, 0, 4) << 8;
  var sportsMode = getBits(status, 4, 1) == 1 ? "open" : "close";
  var detectionMode = getBits(status, 5, 1);
  var wearStatus = getBits(status, 6, 1);
  var chargeStatus = getBits(status, 7, 1);
  motionDetectionCount += motionCount;

  var byte1 = view.getUint8(9);
  var byte2 = view.getUint8(10);
  var byte3 = view.getUint8(11);
  var uuid = (byte3 << 16) | (byte2 << 8) | byte1;
  var batteryStatus = view.getUint8(12);
  var hr1 = view.getUint8(13);
  var hr2 = view.getUint8(14);
  var hr3 = view.getUint8(15);
  List<int>? rawHr = [hr1, hr2, hr3];
  var temperature = (((view.getUint8(16) + 200) / 10) * 10).round() / 10;
  var step = view.getUint16(17, Endian.little);
  var reStep = view.getUint16(17, Endian.little) * 2 ~/ 3;
  var array = <int>[hr1, hr2, hr3];
  var isHrv = isDeviceOutputHrvAndRespiratoryRate(hr1);
  var hrv;
  var respiratoryRate = -1;
  if (isHrv) {
    hrv = ((hr1 & 0x0f) << 8) + hr2;
    respiratoryRate = hr3;
    rawHr = null;
  } else {
    hrv = toHrv(array, heartRate);
  }
  var ox = 0;
  if (detectionMode == 1) {
    if (hr3 < 85) {
      ox = generateRandomNumber();
    } else {
      ox = hr3;
    }
  }
  // var chargingStatus = getBits(batteryStatus, 7, 1);
  var batteryLevel = getBits(batteryStatus, 0, 7);
  // debugPrint("历史数据上报  chargingStatus=$chargingStatus batteryLevel=$batteryLevel");
  List<Map<String, dynamic>> historyArray = [];
  if (Store.getMaxUUID() != uuid) {
    tempHistoryArray.add({
      "timeStamp": timeStamp,
      "heartRate": heartRate,
      "motionDetectionCount": motionDetectionCount,
      "detectionMode": detectionMode,
      "sportsMode": sportsMode,
      "wearStatus": wearStatus,
      "chargeStatus": chargeStatus,
      "uuid": uuid,
      "hrv": hrv,
      "temperature": temperature,
      "step": step,
      "reStep": reStep,
      "ox": ox,
      "rawHr": rawHr,
      "respiratoryRate": respiratoryRate,
      "batteryLevel": batteryLevel,
    });
  } else {
    List<Map<String, dynamic>> result =
        removeDuplicateRecords(tempHistoryArray);
    historyArray.addAll(result);
  }

  return {
    "uuid": uuid,
    "historyArray": historyArray,
  };
}

parseHistoricalData3(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);
  var timeStamp = view.getUint32(2, Endian.little) * 1000;
  var status = view.getUint8(6);
  var heartRate = view.getUint8(7);

  if (heartRate < 45 || heartRate > 190) {
    heartRate = -1;
  }
  var motionCount = view.getUint8(8);
  var motionDetectionCount = getBits(status, 0, 4) << 8;
  var sportsMode = getBits(status, 4, 1) == 1 ? "open" : "close";
  var detectionMode = getBits(status, 5, 1);
  var wearStatus = getBits(status, 6, 1);
  var chargeStatus = getBits(status, 7, 1);
  motionDetectionCount += motionCount;

  var byte1 = view.getUint8(9);
  var byte2 = view.getUint8(10);
  var byte3 = view.getUint8(11);
  var uuid = (byte3 << 16) | (byte2 << 8) | byte1;
  var batteryStatus = view.getUint8(12);
  var hr1 = view.getUint8(13);
  var hr2 = view.getUint8(14);
  var hr3 = view.getUint8(15);
  List<int>? rawHr = [hr1, hr2, hr3];
  var temperature = (((view.getUint8(16) + 200) / 10) * 10).round() / 10;
  var step = view.getUint16(17, Endian.little);
  var reStep = view.getUint16(17, Endian.little) * 2 ~/ 3;
  var array = <int>[hr1, hr2, hr3];
  var isHrv = isDeviceOutputHrvAndRespiratoryRate(hr1);
  var hrv;
  var respiratoryRate = -1;
  // var chargingStatus = getBits(batteryStatus, 7, 1);
  var batteryLevel = getBits(batteryStatus, 0, 7);
  // debugPrint("历史数据上报  chargingStatus=$chargingStatus batteryLevel=$batteryLevel");
  // debugPrint("历史数据上报3 isHrv=$isHrv hr1=$hr1 hr2=$hr2 hr3=$hr3");
  if (isHrv) {
    hrv = ((hr1 & 0x0f) << 8) + hr2;
    respiratoryRate = hr3;
    rawHr = null;
  } else {
    hrv = toHrv(array, heartRate);
  }

  var ox = 0;
  if (detectionMode == 1) {
    if (hr3 < 85) {
      ox = generateRandomNumber();
    } else {
      ox = hr3;
    }
  }

  List<Map<String, dynamic>> historyArray = [];
  if (Store.getMaxUUID() != uuid) {
    tempHistoryArray.add({
      "timeStamp": timeStamp,
      "heartRate": heartRate,
      "motionDetectionCount": motionDetectionCount,
      "detectionMode": detectionMode,
      "sportsMode": sportsMode,
      "wearStatus": wearStatus,
      "chargeStatus": chargeStatus,
      "uuid": uuid,
      "hrv": hrv,
      "temperature": temperature,
      "step": step,
      "reStep": reStep,
      "ox": ox,
      "rawHr": rawHr,
      "respiratoryRate": respiratoryRate,
      "batteryLevel": batteryLevel,
    });
  } else {
    List<Map<String, dynamic>> result =
        removeDuplicateRecords(tempHistoryArray);
    historyArray.addAll(result);
  }

  return {
    "uuid": uuid,
    "historyArray": historyArray,
  };
}

//ECG源数据
parseECGRawData(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);
  final ecgValues = <int>[];
  for (var i = 0; i <= 12; i += 3) {
    var ecgValue = 0;
    if (view.getUint8(i + 2) & 0x02 == 2) {
      ecgValue = (view.getUint8(i + 2) << 16) |
          (view.getUint8(i + 3) << 8) |
          view.getUint8(i + 4) - 0x40000;
    } else {
      ecgValue = (view.getUint8(i + 2) << 16) |
          (view.getUint8(i + 3) << 8) |
          view.getUint8(i + 4);
    }

    ecgValues.add(ecgValue);
  }
  var dataCount = view.getUint16(17, Endian.little);
  return {'ecgList': ecgValues, 'dataCount': dataCount};
}

//ecg和ppg源数据
parseEcgAndPpg(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);
  final ecgValues = <int>[];
  final ppgValues = <int>[];

  for (var i = 0; i <= 10; i += 5) {
    var ppgValue = (getBits(view.getUint8(i + 4), 4, 4) << 16) |
        (view.getUint8(i + 3) << 8) |
        view.getUint8(i + 2);
    var ecgValue = 0;
    if (getBits(view.getUint8(i + 4), 1, 1) & 0x02 == 2) {
      ecgValue = (getBits(view.getUint8(i + 4), 0, 2) << 16) |
          (view.getUint8(i + 5) << 8) |
          view.getUint8(i + 6) - 0x40000;
    } else {
      ecgValue = (getBits(view.getUint8(i + 4), 0, 2) << 16) |
          (view.getUint8(i + 5) << 8) |
          view.getUint8(i + 6);
    }

    ecgValues.add(ecgValue);
    ppgValues.add(ppgValue);
  }

  var dataCount = view.getUint16(17, Endian.little);
  return {'ecgList': ecgValues, 'ppgList': ppgValues, 'dataCount': dataCount};
}

//ecg算法库数据
parseEcgAlgorithmLibrary(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);
  final ecgValues = <int>[];
  for (var i = 0; i <= 12; i += 2) {
    var ecgValue = 0;
    // var signed = getBits(view.getUint8(i + 2), 7, 1);
    // if (signed == 1) {
    //   ecgValue = (view.getUint8(i + 2) << 8) | view.getUint8(i + 3) - 0x10000;
    // } else {
    //   ecgValue = (view.getUint8(i + 2) << 8) | view.getUint8(i + 3);
    // }
    ecgValue = view.getInt16(i + 2, Endian.big);

    ecgValues.add(ecgValue);
  }
  var dataCount = view.getUint16(16, Endian.little);
  return {'ecgList': ecgValues, 'dataCount': dataCount};
}

parseEcgAlgorithmResult(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);

  int heartRate = view.getUint8(2);
  int ARR_CHK = view.getUint8(3);

  int resultOfArrhythmia = getBits(ARR_CHK, 0, 4);
  // 解释结果含义...

  int low_amplitude = getBits(ARR_CHK, 4, 1);
  int significant_noise = getBits(ARR_CHK, 5, 1);
  int unstable_signal = getBits(ARR_CHK, 6, 1);
  int not_enough_data = getBits(ARR_CHK, 7, 1);

  int rmssd = (view.getUint8(4) << 8) | view.getUint8(5);
  int sdnn = (view.getUint8(6) << 8) | view.getUint8(7);
  int pressureIndex = view.getUint8(8);
  int bmr = (view.getUint8(9) << 8) | view.getUint8(10);
  int active_cal = (view.getUint8(11) << 8) | view.getUint8(12);
  int use_prsn = view.getUint8(13);

  int signalQuality = getBits(use_prsn, 0, 4);
  // 解释信号质量含义...

  int present = getBits(use_prsn, 4, 1);
  int alive = getBits(use_prsn, 5, 1);

  int avg_hr = view.getUint8(14);
  return {
    'heartRate': heartRate,
    'resultOfArrhythmia': resultOfArrhythmia,
    'low_amplitude': low_amplitude,
    'significant_noise': significant_noise,
    'unstable_signal': unstable_signal,
    'not_enough_data': not_enough_data,
    'rmssd': rmssd,
    'sdnn': sdnn,
    'pressureIndex': pressureIndex,
    'bmr': bmr,
    'active_cal': active_cal,
    'signalQuality': signalQuality,
    'present': present,
    'alive': alive,
    'avg_hr': avg_hr,
  };
}

//ecg手指检测数据
parseEcgFingerDetect(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);
  int fingerDetect = view.getUint8(2);
  return {'fingerDetect': fingerDetect};
}

//userInfo数据
parseUserInfoData(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);
  int cmd = view.getUint8(2);
  int sex = view.getUint8(3); //性别
  int age = view.getUint8(4); //年龄
  int height = view.getUint16(5, Endian.little); //身高
  int weight = view.getUint8(7); //体重
  return {
    "cmd": cmd,
    "sex": sex,
    "age": age,
    "height": height,
    "weight": weight
  };
}

//设置测量时间数据
parseSetMeasurementTimingData(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);
  int cmd = view.getUint8(2);
  int type = view.getUint8(3);
  int time1 = view.getUint8(4);
  int time1Interval = view.getUint16(5, Endian.little);
  int time2 = view.getUint8(7);
  int time2Interval = view.getUint16(8, Endian.little);
  int time3Interval = view.getUint8(10);
  return {
    "cmd": cmd,
    "type": type,
    "time1": time1,
    "time1Interval": time1Interval,
    "time2": time2,
    "time2Interval": time2Interval,
    "time3Interval": time3Interval
  };
}

//ppg设置
parsePpgSettings(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);
  int cmd = view.getUint8(2);
  int on_off = view.getUint8(3);
  int led = view.getUint8(4);
  int current = view.getUint8(5);
  int autoAdjBrightness = view.getUint8(6);
  int sps = view.getUint8(7);
  return {
    "cmd": cmd,
    "on_off": on_off,
    "led": led,
    "current": current,
    "autoAdjBrightness": autoAdjBrightness,
    "sps": sps
  };
}

parsePpgData(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);
  List<int> ppgList = [];
  int sign = view.getInt8(18);
  int ppg1 = 0;
  int ppg2 = 0;
  int ppg3 = 0;
  int ppg4 = 0;
  if (sign == 0) {
    ppg1 = view.getUint32(2, Endian.little);
    ppg2 = view.getUint32(6, Endian.little);
    ppg3 = view.getUint32(10, Endian.little);
    ppg4 = view.getUint32(14, Endian.little);
  } else {
    ppg1 = view.getInt32(2, Endian.little);
    ppg2 = view.getInt32(6, Endian.little);
    ppg3 = view.getInt32(10, Endian.little);
    ppg4 = view.getInt32(14, Endian.little);
    var p16_b= view.getInt16(2,Endian.little);
    var p16_a= view.getInt16(4,Endian.little);
    debugPrint("ppg1=$ppg1 p16_b=$p16_b p16_a=$p16_a ");
    debugPrint("data=$data ");
  }
  ppgList.add(ppg1);
  ppgList.add(ppg2);
  ppgList.add(ppg3);
  ppgList.add(ppg4);
  return {"ppgList": ppgList};
}

//新历史数据上报算法
parseNewAlgorithmHistoryData(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);
  int timeStamp = view.getUint32(2, Endian.little) * 1000;
  int byte1 = view.getUint8(6);
  int byte2 = view.getUint8(7);
  int byte3 = view.getUint8(8);
  int uuid = (byte3 << 16) | (byte2 << 8) | byte1;
  int ibi = view.getUint16(9, Endian.little);
  dynamic stress = view.getUint8(11);
  if (stress != 0xff) {
    stress /= 100;
  }
  dynamic cardiac_coherence = view.getUint8(12);
  if (cardiac_coherence != 0xff) {
    cardiac_coherence /= 100;
  }
  int hrv = view.getUint16(13, Endian.little);
  int respiratory_rate = view.getUint8(15);
  int heart_rate = view.getUint8(16);
  return {
    'timeStamp': timeStamp,
    'uuid': uuid,
    'ibi': ibi,
    'stress': stress,
    'cardiac_coherence': cardiac_coherence,
    'hrv': hrv,
    'respiratory_rate': respiratory_rate,
    'heart_rate': heart_rate
  };
}

//排除游泳活动历史数据
parseExcludedSwimmingActivityHistoryData(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);
  int timeStamp = view.getUint32(2, Endian.little) * 1000;
  int byte1 = view.getUint8(6);
  int byte2 = view.getUint8(7);
  int byte3 = view.getUint8(8);
  int uuid = (byte3 << 16) | (byte2 << 8) | byte1;
  double distance = view.getUint8(9) / 10;
  int step = view.getUint16(10, Endian.little);
  int total_energy = view.getUint16(12, Endian.little);
  int total_active_energy = view.getUint16(14, Endian.little);
  int vo2 = view.getUint8(16);
  int vo2Max = view.getUint8(17);
  int type = view.getUint8(18);
  int active_type = getBits(type, 0, 3);
  int exercise_type = getBits(type, 3, 1);
  return {
    "timeStamp": timeStamp,
    "uuid": uuid,
    "distance": distance,
    "step": step,
    "total_energy": total_energy,
    "total_active_energy": total_active_energy,
    "vo2": vo2,
    "vo2Max": vo2Max,
    "active_type": active_type,
    "exercise_type": exercise_type
  };
}

//健身活动历史数据
parseExerciseActivityHistoryData(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);
  var timeStamp = view.getUint32(2, Endian.little) * 1000;
  int step = view.getUint16(6, Endian.little);
  double distance = view.getUint8(8) / 10;
  int speed = view.getUint8(9);
  int step_frequency = view.getUint8(10);
  int total_energy = view.getUint16(11, Endian.little);
  int total_active_energy = view.getUint16(13, Endian.little);
  double current_energy_consumed = view.getUint16(15, Endian.little) / 10;
  int exercise_type = view.getUint8(17);
  int heart_rate = view.getUint8(18);
  return {
    "timeStamp": timeStamp,
    "step": step,
    "distance": distance,
    "speed": speed,
    "step_frequency": step_frequency,
    "total_energy": total_energy,
    "total_active_energy": total_active_energy,
    "current_energy_consumed": current_energy_consumed,
    "exercise_type": exercise_type,
    "heart_rate": heart_rate
  };
}

//游泳活动历史数据
parseSwimmingExerciseHistoryData(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);
  var timeStamp = view.getUint32(2, Endian.little) * 1000;
  int total_stroke_count = view.getUint16(6, Endian.little);
  int total_stroke_time = view.getUint16(8, Endian.little);
  int total_distance = view.getUint16(10, Endian.little);
  double swimming_pace = view.getUint16(12, Endian.little) / 10;
  int swimming_laps = view.getUint8(14);
  int average_swimming_efficiency = view.getUint16(15, Endian.little);

  return {
    "timeStamp": timeStamp,
    "total_stroke_count": total_stroke_count,
    "total_stroke_time": total_stroke_time,
    "total_distance": total_distance,
    "swimming_pace": swimming_pace,
    "swimming_laps": swimming_laps,
    "average_swimming_efficiency": average_swimming_efficiency
  };
}

//单圈游泳历史数据
parseSingleLapSwimmingHistoryData(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);
  var timeStamp = view.getUint32(2, Endian.little) * 1000;
  int stroke_count = view.getUint16(6, Endian.little);
  int swimming_time = view.getUint16(8, Endian.little);
  int stroke_rate = view.getUint8(10);
  int swimming_posture = view.getUint8(11);
  double swimming_pace = view.getUint16(12, Endian.little) / 10;
  int swimming_efficiency = view.getUint16(14, Endian.little);
  int circle_detection = view.getUint8(16);
  int swimming_distance = view.getUint8(17);
  return {
    "timeStamp": timeStamp,
    "stroke_count": stroke_count,
    "swimming_time": swimming_time,
    "stroke_rate": stroke_rate,
    "swimming_posture": swimming_posture,
    "swimming_pace": swimming_pace,
    "swimming_efficiency": swimming_efficiency,
    "circle_detection": circle_detection,
    "swimming_distance": swimming_distance
  };
}

//
parseStepTemperatureActivityIntensityHistoryData(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);
  var timeStamp = view.getUint32(2, Endian.little) * 1000;
  //uuid
  int byte1 = view.getUint8(6);
  int byte2 = view.getUint8(7);
  int byte3 = view.getUint8(8);
  int uuid = (byte3 << 16) | (byte2 << 8) | byte1;
  //step
  int step = view.getUint16(9, Endian.little);
  //temperature
  double temperature =
      double.parse(((view.getUint8(11) + 200) / 10).toStringAsFixed(1));
  //intensity
  int activity_intensity = view.getUint8(12);
  int acc_sd = view.getUint16(13, Endian.little);
  if (view.getUint8(11) == 0xff) {
    temperature = 0xff;
  } else if (view.getUint8(11) == 0x00) {
    temperature = 0x00;
  }
  return {
    "timeStamp": timeStamp,
    "uuid": uuid,
    "step": step,
    "temperature": temperature,
    "activity_intensity": activity_intensity,
    "acc_sd": acc_sd
  };
}

//活动数据
parseActiveData(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);
  var year = view.getUint8(2);
  var month = view.getUint8(3);
  var day = view.getUint8(4);
  var total_walk_steps = view.getUint16(5, Endian.little); // 总的走路步数
  var total_run_steps = view.getUint16(7, Endian.little); // 总的跑步步数
  var total_other_steps = view.getUint16(9, Endian.little); // 总的游泳步数
  var total_distance = view.getUint8(11); // 总的距离
  var total_energy = view.getUint16(12, Endian.little); // 总的能量
  var total_active_energy = view.getUint16(14, Endian.little); // 总的活动能量
  var energy_consumed = view.getUint16(16, Endian.little); // 总的睡眠时间
  return {
    "year": year,
    "month": month,
    "day": day,
    "total_walk_steps": total_walk_steps,
    "total_run_steps": total_run_steps,
    "total_other_steps": total_other_steps,
    "total_distance": total_distance / 10,
    "total_energy": total_energy,
    "total_active_energy": total_active_energy,
    "energy_consumed": energy_consumed / 10
  };
}

//睡眠历史数据
parseSleepHistoryData(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);
  var timeStamp = view.getUint32(2, Endian.little) * 1000;
  int byte1 = view.getUint8(6);
  int byte2 = view.getUint8(7);
  int byte3 = view.getUint8(8);
  int uuid = (byte3 << 16) | (byte2 << 8) | byte1;
  int timeStamp_type = view.getUint8(9);
  int sleep_timeStamp = view.getUint32(10, Endian.little) * 1000;
  int bed_time = view.getUint16(14, Endian.little);
  int wake_index = view.getUint8(16);

  return {
    "timeStamp": timeStamp,
    "uuid": uuid,
    "timeStamp_type": timeStamp_type,
    "sleep_timeStamp": sleep_timeStamp,
    "bed_time": bed_time,
    "wake_index": wake_index
  };
}

//每日活动历史数据
parseDailyActivityHistoryData(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);
  var year = view.getUint8(2);
  var month = view.getUint8(3);
  var day = view.getUint8(4);
  var total_walk_steps = view.getUint16(5, Endian.little);
  var total_run_steps = view.getUint16(7, Endian.little);
  var total_other_steps = view.getUint16(9, Endian.little);
  var total_distance = view.getUint8(11) / 10;
  var total_energy = view.getUint16(12, Endian.little);
  var total_active_energy = view.getUint16(14, Endian.little);
  var current_energy_consumed = view.getUint16(16, Endian.little) / 10;
  return {
    "year": year,
    "month": month,
    "day": day,
    "total_walk_steps": total_walk_steps,
    "total_run_steps": total_run_steps,
    "total_other_steps": total_other_steps,
    "total_distance": total_distance,
    "total_energy": total_energy,
    "total_active_energy": total_active_energy,
    "current_energy_consumed": current_energy_consumed
  };
}

//PPG测量数据
parsePpgMeasurementData(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);
  var blood_oxygen = view.getUint8(2);
  var heart_rate = view.getUint8(3);
  var hrv = view.getUint16(4, Endian.little);
  var status = view.getUint8(6);
  var motion_count = view.getUint16(7, Endian.little);
  var heart_rate_quality = view.getUint8(9);
  //呼吸率
  var respiratory_rate = view.getUint8(10);
  //血氧R值
  var oxygen_r_value = view.getUint32(11, Endian.little) / 100000;
  //ibi
  var ibi = view.getUint16(15, Endian.little);
  dynamic stress = view.getUint8(17);
  if (stress != 0xff) {
    stress /= 100;
  }
  dynamic cardiac_coherence = view.getUint8(18);
  if (cardiac_coherence != 0xff) {
    cardiac_coherence /= 100;
  }
  return {
    "blood_oxygen": blood_oxygen,
    "heart_rate": heart_rate,
    "hrv": hrv,
    "status": status,
    "motion_count": motion_count,
    "heart_rate_quality": heart_rate_quality,
    "respiratory_rate": respiratory_rate,
    "oxygen_r_value": oxygen_r_value,
    "ibi": ibi,
    "stress": stress,
    "cardiac_coherence": cardiac_coherence
  };
}

//健身动作数据
parseExerciseVitalSignsHistoryData(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);
  var timeStamp = view.getUint32(2, Endian.little) * 1000;
  int heart_rate = view.getUint8(6);
  int hrv = view.getUint16(7, Endian.little);
  //呼吸率
  int respiratory_rate = view.getUint8(9);
  //ibi
  int ibi = view.getUint16(10, Endian.little);
  //stress
  dynamic stress = view.getUint8(12);
  if (stress != 0xff) {
    stress /= 100;
  }
  //cardiac_coherence
  dynamic cardiac_coherence = view.getUint8(13);
  if (cardiac_coherence != 0xff) {
    cardiac_coherence /= 100;
  }
  //vo2
  int vo2 = view.getUint8(14);
  //vo2Max
  int vo2Max = view.getUint8(15);
  //temperature
  double temperature =
      double.parse(((view.getUint8(16) + 200) / 10).toStringAsFixed(1));
  //锻炼类型
  int exercise_type = view.getUint8(17);

  int type = view.getUint8(18);
  //运动类型
  var active_type = getBits(type, 0, 3);
  var exercise_status = getBits(type, 3, 1);

  return {
    "timeStamp": timeStamp,
    "heart_rate": heart_rate,
    "hrv": hrv,
    "respiratory_rate": respiratory_rate,
    "ibi": ibi,
    "stress": stress,
    "cardiac_coherence": cardiac_coherence,
    "vo2": vo2,
    "vo2Max": vo2Max,
    "temperature": temperature,
    "exercise_type": exercise_type,
    "active_type": active_type,
    "exercise_status": exercise_status
  };
}

//获取报告运动数据
parseGetReportingExerciseData(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);
  var steps = view.getUint16(2, Endian.little);
  var distance = view.getUint16(4, Endian.little) / 10;
  var speed = view.getUint8(6);
  var frequency = view.getUint8(7);
  var total_energy = view.getUint16(8, Endian.little);
  var total_active_energy = view.getUint16(10, Endian.little);
  var current_energy_consumed = view.getUint16(12, Endian.little) / 10;
  var exercise_type = view.getUint8(14);
  var heart_rate = view.getUint8(15);
  dynamic cardiac_coherence = view.getUint8(16);
  if (cardiac_coherence != 0xff) {
    cardiac_coherence /= 100;
  }
  return {
    "steps": steps,
    "distance": distance,
    "speed": speed,
    "frequency": frequency,
    "total_energy": total_energy,
    "total_active_energy": total_active_energy,
    "current_energy_consumed": current_energy_consumed,
    "exercise_type": exercise_type,
    "heart_rate": heart_rate,
    "cardiac_coherence": cardiac_coherence
  };
}

parseTemperatureHistoryData(List<int> data) {
  final buffer = Uint8List.fromList(data).buffer;
  final view = ByteData.view(buffer);
  var timeStamp = view.getUint32(2, Endian.little) * 1000;
  var temperature1 =
      double.parse(((view.getUint8(6) + 200) / 10).toStringAsFixed(1));
  var temperature2 =
      double.parse(((view.getUint8(7) + 200) / 10).toStringAsFixed(1));
  var temperature3 =
      double.parse(((view.getUint8(8) + 200) / 10).toStringAsFixed(1));
  var temperature4 =
      double.parse(((view.getUint8(9) + 200) / 10).toStringAsFixed(1));
  var temperature5 =
      double.parse(((view.getUint8(10) + 200) / 10).toStringAsFixed(1));
  if (view.getUint8(6) == 0xff) {
    temperature1 = 0xff;
  }
  if (view.getUint8(7) == 0xff) {
    temperature2 = 0xff;
  }
  if (view.getUint8(8) == 0xff) {
    temperature3 = 0xff;
  }
  if (view.getUint8(9) == 0xff) {
    temperature4 = 0xff;
  }
  if (view.getUint8(10) == 0xff) {
    temperature5 = 0xff;
  }
  return {
    "timeStamp": timeStamp,
    "temperature1": temperature1,
    "temperature2": temperature2,
    "temperature3": temperature3,
    "temperature4": temperature4,
    "temperature5": temperature5
  };
}

dynamic parseAllData(data, int type) {
  // debugPrint("type=$type ");
  late dynamic result;
  switch (type) {
    case ReceiveType.Temperature:
      result = parseTemperatureData(data);
      break;
    case ReceiveType.HistoricalNum:
      result = parseHistoricalNum(data);
      break;
    case ReceiveType.HistoricalData:
      result = parseHistoricalData(data);
      break;
    case ReceiveType.HistoricalData2:
      result = parseHistoricalData2(data);
      break;
    case ReceiveType.HistoricalData3:
      result = parseHistoricalData3(data);
      break;
    case ReceiveType.DeviceInfo1:
      result = parseDeviceInfo1Data(data);
      break;
    case ReceiveType.DeviceInfo2:
      result = parseDeviceInfo2Data(data);
      break;
    case ReceiveType.DeviceInfo5:
      result = parseDeviceInfo5Data(data);
      break;
    case ReceiveType.BatteryDataAndState:
      result = parseBatteryData(data);
      break;
    case ReceiveType.RePackage:
      result = parseRePackage(data);
      break;
    case ReceiveType.Health:
      result = parseHealthData(data);
      break;
    case ReceiveType.Step:
      result = parseStepData(data);
      break;
    case ReceiveType.OEMR1:
      result = parseOemR1Data(data);
      break;
    case ReceiveType.OEMResult:
      result = parseOemResultData(data);
      break;
    case ReceiveType.IRresouce:
      result = iRresouceData(data);
      break;
    case ReceiveType.GreenOrIr:
      result = greenOrIrData(data);
      break;
    case ReceiveType.EcgRaw:
      result = parseECGRawData(data);
      break;
    case ReceiveType.EcgAndPpg:
      result = parseEcgAndPpg(data);
      break;
    case ReceiveType.EcgAlgorithm:
      result = parseEcgAlgorithmLibrary(data);
      break;
    case ReceiveType.EcgAlgorithmResult:
      result = parseEcgAlgorithmResult(data);
      break;
    case ReceiveType.EcgFingerDetect:
      result = parseEcgFingerDetect(data);
      break;
    case ReceiveType.USER_INFO_OR_SET_MEASUREMENT_TIMING_OR_PPG:
      int type = data[2];
      if (type == SendCMD.USER_INFO) {
        result = parseUserInfoData(data);
      } else if (type == SendCMD.SET_MEASUREMENT_TIMING) {
        result = parseSetMeasurementTimingData(data);
      } else if (type == SendCMD.Ppg) {
        result = parsePpgSettings(data);
      }
      break;
    case ReceiveType.NEW_ALGORITHM_HISTORY:
      result = parseNewAlgorithmHistoryData(data);
      break;
    case ReceiveType.NEW_ALGORITHM_HISTORY_NUM:
      result = parseHistoricalNum(data);
      break;
    case ReceiveType.EXCLUDED_SWIMMING_ACTIVITY_HISTORY:
      result = parseExcludedSwimmingActivityHistoryData(data);
      break;
    case ReceiveType.EXERCISE_ACTIVITY_HISTORY:
      result = parseExerciseActivityHistoryData(data);
      break;
    case ReceiveType.SWIMMING_EXERCISE_HISTORY:
      result = parseSwimmingExerciseHistoryData(data);
      break;
    case ReceiveType.SINGLE_LAP_SWIMMING_HISTORY:
      result = parseSingleLapSwimmingHistoryData(data);
      break;
    case ReceiveType.STEP_TEMPERATURE_ACTIVITY_INTENSITY_HISTORY:
      result = parseStepTemperatureActivityIntensityHistoryData(data);
      break;
    case ReceiveType.ACTIVE_DATA:
      result = parseActiveData(data);
      break;
    case ReceiveType.SLEEP_HISTORY:
      result = parseSleepHistoryData(data);
      break;
    case ReceiveType.DAILY_ACTIVITY_HISTORY:
      result = parseDailyActivityHistoryData(data);
      break;
    case ReceiveType.PPG_MEASUREMENT:
      result = parsePpgMeasurementData(data);
      break;
    case ReceiveType.EXERCISE_VITAL_SIGNS_HISTORY:
      result = parseExerciseVitalSignsHistoryData(data);
      break;
    case ReceiveType.GET_REPORTING_EXERCISE:
      result = parseGetReportingExerciseData(data);
      break;
    case ReceiveType.TEMPERATURE_HISTORY:
      result = parseTemperatureHistoryData(data);
      break;
    case ReceiveType.PPG_DATA:
      result = parsePpgData(data);
      break;
  }
  return result;
}
