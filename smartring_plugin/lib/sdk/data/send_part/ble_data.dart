

import 'package:flutter/material.dart';

import '../../common/ble_protocol_constant.dart';

const OEM_CO = "Linktop";
const DATA_TOTAL_LEN = 17;

Map dealMap = <int, Function>{
  SendCMD.TimeSyncSettings: timeSynData,
  SendCMD.GetHealth: getHealthData,
  SendCMD.Step: commonData,
  SendCMD.Temperature: commonData,
  SendCMD.ShutDown: commonData,
  SendCMD.Restart: commonData,
  SendCMD.RestoreFactorySettings: commonData,
  SendCMD.HistoricalNum: historicalData,
  SendCMD.HistoricalData: historicalData,
  SendCMD.CleanHistoricalData: commonData,
  SendCMD.DeviceInfo1: commonData,
  SendCMD.DeviceInfo2: commonData,
  SendCMD.DeviceInfo5: commonData,
  SendCMD.BatteryDataAndState: commonData,
  SendCMD.DeviceBindAndUnBind: deviceBindAndUnBindData,
  SendCMD.SetHealthPara: setHealthParaData,
  SendCMD.HeartRateTime: heartRateTimeData,
  SendCMD.SwitchOem: switchOEMData,
  SendCMD.StartOemVerify: commonData,
  SendCMD.StartOemVerifyR2: sendOEMR2Data,
  SendCMD.SetOemAesKey: setAESKeyData,
  SendCMD.SetOemAesIv: setAESIvData,
  SendCMD.SetSportModeParameters: setSportModeParametersData,
  SendCMD.OXSettings: setOxSettingData,
  SendCMD.Ecg: setECGData,
  SendCMD.EcgAndPPG: setECGAndPPGData,
  SendCMD.USER_INFO: userInfoData,
  SendCMD.SET_EXERCISE: setExerciseData,
  SendCMD.NEW_ALGORITHM_HISTORY_NUM: historicalData,
  SendCMD.NEW_ALGORITHM_HISTORY: historicalData,
  SendCMD.ACTIVE_DATA: commonData,
  SendCMD.CLEAN_NEW_HISTORY: commonData,
  SendCMD.SET_REPORTING_EXERCISE: setReportExercise,
  SendCMD.SET_MEASUREMENT_TIMING: setMeasurementTimingData,
  SendCMD.Ppg: setPPGData,
};

List<int> timeSynData({data}) {
  var array = <int>[];

  var timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
// 前4个字节存入时间戳，小端存入
  for (var i = 0; i < 4; i++) {
    var byte = (timestamp >> (i * 8)) & 0xff; // 取出每一位数据
    array.add(byte);
  }
// 接着7个字节存入年月日时分秒
  var now = DateTime.now();
  var year = now.year;
  var month = now.month.toString().padLeft(2, '0');
  var day = now.day.toString().padLeft(2, '0');
  var hours = now.hour.toString().padLeft(2, '0');
  var minutes = now.minute.toString().padLeft(2, '0');
  var seconds = now.second.toString().padLeft(2, '0');
  for (var index = 0; index < 2; index++) {
    var byte = (year >> (index * 8)) & 0xff; // 取出每一位数据
    array.add(byte);
  }
  array.add(int.parse(month) & 0xff);
  array.add(int.parse(day) & 0xff);
  array.add(int.parse(hours) & 0xff);
  array.add(int.parse(minutes) & 0xff);
  array.add(int.parse(seconds) & 0xff);
// 接着存后6个字节0x00
  for (var index = 0; index < 6; index++) {
    array.add(0x00);
  }
  return array;
}

List<int> getHealthData({data, required Map<String, dynamic> innerData}) {
  var array = <int>[];
  var on = innerData["isOn"] ? 1 : 0;
  var single = innerData["isSingle"] ? 0 : 1;
  // debugPrint("getHealthData on=$on single=$single");
  array.add(on & 0xff);
  array.add(single & 0xff);
  var len = DATA_TOTAL_LEN - array.length;
  for (var index = 0; index < len; index++) {
    array.add(0x00);
  }
  return array;
}

List<int> historicalData({required Map<String, dynamic> data}) {
  var array = <int>[];
  var all = data["isAll"] ? 1 : 0;
  array.add(all & 0xff);
// UUID
  if (data["uuid"] != null) {
    for (var index = 0; index < 3; index++) {
      array.add((data["uuid"] >> (8 * index)) & 0xff);
    }
  } else {
    for (var index = 0; index < 3; index++) {
      array.add(0xff);
    }
  }
  var len = DATA_TOTAL_LEN - array.length;
  for (var index = 0; index < len; index++) {
    array.add(0x00);
  }
  return array;
}

List<int> setSOSparaData({required Map<String, dynamic> data}) {
  var array = <int>[];
  var open = data['open'] ? 1 : 0;
  array.add(open & 0xff);
  array.add(data['doubleClickTimes'] & 0xff);
  array.add(data['timeInterval'] & 0xff);
  array.add(data['threshold'] & 0xff);
  var diff = data['endTime'] - data['startTime'];
  if (diff <= 0) {
    throw ArgumentError('startTime > endTime');
  }
  array.add(data['startTime'] & 0xff);
  array.add(data['endTime'] & 0xff);
  var len = DATA_TOTAL_LEN - array.length;
  for (var index = 0; index < len; index++) {
    array.add(0x00);
  }
  return array;
}

// List<int> writeNumData(Map<String, dynamic> props) {
// var array = <int>[];
// array.add(props['color'] & 0xff);
// array.add(props['size'] & 0xff);
// // ble address
// for (var index = 0; index < 6; index++) {
// array.add(props['addr'][index] & 0xff);
// }
// // sn
// for (var index = 0; index < 8; index++) {
// array.add(props['sn'][index] & 0xff);
// }
// // 写号位
// array.add(update & 0xff);
// return array;
// }

List<int> deviceBindAndUnBindData(
    {data, required Map<String, dynamic> innerData}) {
  var array = <int>[];
  var bind = innerData["isBind"] ? 1 : 0;
  array.add(bind & 0xff);
  var len = DATA_TOTAL_LEN - array.length;
  for (var index = 0; index < len; index++) {
    array.add(0x00);
  }
  return array;
}

List<int> aDVParaData({required Map<String, dynamic> data}) {
  var array = <int>[];
  for (var index = 0; index < 2; index++) {
    array.add(data['func_interval'][index] & 0xff);
  }
  array.add(data['func_power'] & 0xff);
  for (var index = 0; index < 2; index++) {
    array.add(data['sos_interval'][index] & 0xff);
  }
  array.add(data['sos_power'] & 0xff);
  array.add(data['sos_time'] & 0xff);
  var len = DATA_TOTAL_LEN - array.length;
  for (var index = 0; index < len; index++) {
    array.add(0x00);
  }
  return array;
}

List<int> heartRateTimeData({required Map data}) {
  var array = <int>[];
  array.add(data["time"] & 0xff);
  var len = DATA_TOTAL_LEN - array.length;
  for (var index = 0; index < len; index++) {
    array.add(0x00);
  }
  return array;
}

List<int> switchOEMData({required Map<String, int> data}) {
  var array = <int>[];
  array.add(data["switch"]!);
  var len = DATA_TOTAL_LEN - array.length;
  for (var index = 0; index < len; index++) {
    array.add(0x00);
  }
  return array;
}

List<int> sendOEMR2Data({required List<int> data}) {
  // debugPrint("sendOEMR2Data  data=$data");
  var array = <int>[];
  array.addAll(data);
  var len = DATA_TOTAL_LEN - array.length;
  for (var index = 0; index < len; index++) {
    array.add(0x00);
  }
  return array;
}

List<int> hexToBytes(String hexString) {
  List<int> bytes = [];
  for (int i = 0; i < hexString.length; i += 2) {
    String hex = hexString.substring(i, i + 2);
    int byte = int.parse(hex, radix: 16);
    bytes.add(byte);
  }
  return bytes;
}

// String bytesToHex(List<int> bytes) {
//   String hexString = '';
//   for (int byte in bytes) {
//     String hex = byte.toRadixString(16).padLeft(2, '0');
//     hexString += hex;
//   }
//   return hexString;
// }

List<int> subArray(String str) {
  final result = <int>[];
  for (var i = 0; i < str.length; i += 2) {
    final subStr = str.substring(i, i + 2);
    result.add(int.parse(subStr, radix: 16));
  }
  return result;
}

// String stringToHex(String str) {
//   var hexString = '';
//   for (var i = 0; i < str.length; i++) {
//     final hex = str.codeUnitAt(i).toRadixString(16);
//     hexString += hex.padLeft(2, '0');
//   }
//   return hexString;
// }

List<int> setAESKeyData({required String data}) {
  var array = <int>[];
  var arr = subArray(data);
  array.addAll(arr);
  var len = DATA_TOTAL_LEN - array.length;
  for (var index = 0; index < len; index++) {
    array.add(0x00);
  }
  return array;
}

List<int> setAESIvData({required String data}) {
  var array = <int>[];
  var arr = subArray(data);
  array.addAll(arr);
  var len = DATA_TOTAL_LEN - array.length;
  for (var index = 0; index < len; index++) {
    array.add(0x00);
  }
  return array;
}

// String bytesToHex(List<int> bytes) {
//   final hexChars = List<String>.generate(
//       bytes.length, (i) => bytes[i].toRadixString(16).padLeft(2, '0'));
//   return hexChars.join();
// }

List<int> setSportModeParametersData({required Map<String, dynamic> data}) {
  var array = <int>[];
  var open = data['switch'];
  array.add(open & 0xff);
  if (open != 0) {
    var timeInterval = data['timeInterval'];
    array.add(timeInterval & 0xff);
    array.add(0x00);
    var duration = data['duration'];
    array.add(duration & 0xff);
    array.add(0x00);
    var mode = data['mode'];
    if (mode != null) {
      array.add(mode & 0xff);
    }
  }

  var len = DATA_TOTAL_LEN - array.length;
  for (var index = 0; index < len; index++) {
    array.add(0x00);
  }
  return array;
}

List<int> setHealthParaData({required Map<String, dynamic> data}) {
  var array = <int>[];
  var samplingRate = data['samplingRate'];
  // debugPrint('samplingRate=${samplingRate}');
  var open = data['switch'];
  array.add(samplingRate & 0xff);
  array.add(open & 0xff);
  var len = DATA_TOTAL_LEN - array.length;
  for (var index = 0; index < len; index++) {
    array.add(0x00);
  }
  return array;
}

///switch:0 OFF,1 ON
///samplingRate:当clockFrequency=0时 [62.5,125,250,500,1000,2000] 可选 ，clockFrequency=1时可选[64,128,256,512,1024,2048]
///clockFrequency：0 时钟频率为32000Hz,1 时钟频率为32768 默认
///ecgPgaGain 0-7的可选 默认是2,即增益是4
///dispSrc:0 原始数据,1 算法库数据
///
List<int> setECGData({required Map<String, dynamic> data}) {
  var array = <int>[];
  var samplingRate = data['samplingRate'];
  var open = data['switch'];
  var clockFrequency = data["clockFrequency"];
  var ecgPgaGain = 2;
  var dispSrc = data['dispSrc'];
  // List<int> byteBuffer = samplingRate.toUnsigned(16).toList();
  array.add(open & 0xff);
  array.add(samplingRate);
  array.add(0x00);
  // if (samplingRate <= 255) {
  //   array.addAll(samplingRate);
  //   array.add(0x00);
  // } else {
  //   // 对于大于255的值，通常会拆分为两个字节
  //   assert(samplingRate > 255 && samplingRate <= 65535); // 确保在0-65535范围内
  //   // 拆分成两个字节并按小端序（Little Endian）添加到数组中
  //   array.add((samplingRate & 0xFF00) >> 8);
  //   array.add(samplingRate & 0x00FF); // 最高有效字节

  //   // 最低有效字节
  // }
  array.add(clockFrequency & 0xff);
  array.add(ecgPgaGain & 0xff);
  array.add(dispSrc & 0xff);
  var len = DATA_TOTAL_LEN - array.length;
  for (var index = 0; index < len; index++) {
    array.add(0x00);
  }
  return array;
}

///switch:0 OFF,1 ON
///samplingRate:当clockFrequency=0时 [62.5,125,250,500,1000,2000] 可选 ，clockFrequency=1时可选[64,128,256,512,1024,2048]
///clockFrequency：0 时钟频率为32000Hz,1 时钟频率为32768 默认
///ppgLed:0 PPG_LED1_GREEN,1 PPG_LED2_IR(默认),2 PPG_LED3_RED,3 PPG_LED4_GREEN,4 PPG_LED5_RED,5 PPG_LED6_IR
///ppgCurrent 采样电流:0x00-0xff  默认0x10,16*0.125mA=2mA
///ecgPgaGain 0-7的可选 默认是2,即增益是4
///
List<int> setECGAndPPGData({required Map<String, dynamic> data}) {
  var array = <int>[];
  var samplingRate = data['samplingRate'];
  var open = data['switch'];
  var clockFrequency = 1;
  var ppgLed = 1;
  var ppgCurrent = 16;
  var ecgPgaGain = 2;
  // List<int> byteBuffer = samplingRate.toUnsigned(16).toList();
  array.add(open & 0xff);
  array.add(samplingRate);
  array.add(0x00);
  // if (samplingRate <= 255) {
  //   array.addAll(samplingRate);
  //   array.add(0x00);
  // } else {
  //   // 对于大于255的值，通常会拆分为两个字节
  //   assert(samplingRate > 255 && samplingRate <= 65535); // 确保在0-65535范围内
  //   // 拆分成两个字节并按小端序（Little Endian）添加到数组中
  //   array.add((samplingRate & 0xFF00) >> 8); // 最低有效字节
  //   array.add(samplingRate & 0x00FF); // 最高有效字节
  // }
  array.add(clockFrequency & 0xff);
  array.add(ppgLed & 0xff);
  array.add(ppgCurrent & 0xff);
  array.add(ecgPgaGain & 0xff);
  var len = DATA_TOTAL_LEN - array.length;
  for (var index = 0; index < len; index++) {
    array.add(0x00);
  }
  return array;
}

List<int> setOxSettingData({data}) {
  var array = <int>[];
  var on = data["switch"];
  array.add(on & 0xff);
  for (var i = 0; i < 8; i++) {
    array.add(0x00);
  }
  var interval = data['timeInterval']; //时间间隔 5-360分钟
  for (var index = 0; index < 2; index++) {
    var byte = (interval >> (index * 8)) & 0xff; // 取出每一位数据
    array.add(byte);
  }
  var len = DATA_TOTAL_LEN - array.length;
  for (var index = 0; index < len; index++) {
    array.add(0x00);
  }
  return array;
}

///function:0 获取,1 设置
///sex:0 男,1 女
///age:1-115岁
///height:身高 单位毫米 1200-3000
///weight:体重 单位千克 30-200
List<int> userInfoData({required Map<String, dynamic> data}) {
  var array = <int>[];
  var fuc = data["function"]; //获取/设置
  var sex = data["sex"]; //性别
  var age = data["age"]; //年龄
  var height = data["height"]; //身高
  var weight = data["weight"]; //体重
  array.add(fuc & 0xff);
  array.add(sex & 0xff);
  array.add(age & 0xff);
  // 将身高转换为小端模式的两个字节
  array.add(height & 0xff); // 最低有效字节
  array.add((height >> 8) & 0xff); // 最高有效字节
  array.add(weight & 0xff);
  var len = DATA_TOTAL_LEN - array.length;
  for (var index = 0; index < len; index++) {
    array.add(0x00);
  }
  return array;
}

List<int> setExerciseData({required Map<String, dynamic> data}) {
  var array = <int>[];
  var fuc = data["function"];
  var type = data["type"];
  var hrStorageInterval = 10; //默认10秒存储一次  不开放设置
  var poolSize = data["poolSize"];
  var exerciseTime = data["exerciseTime"];
  array.add(fuc & 0xff);
  array.add(type & 0xff);
  array.add(hrStorageInterval & 0xff); // 最低有效字节
  array.add((hrStorageInterval >> 8) & 0xff); // 最高有效字节
  array.add(poolSize & 0xff);
  array.add(exerciseTime & 0xff); // 最低有效字节
  array.add((exerciseTime >> 8) & 0xff); // 最高有效字节
  var len = DATA_TOTAL_LEN - array.length;
  for (int index = 0; index < len; index++) {
    array.add(0x00);
  }
  return array;
}

List<int> setReportExercise({required Map<String, dynamic> data}) {
  var array = <int>[];
  var on_off = data["on_off"];
  array.add(on_off & 0xff);
  var len = DATA_TOTAL_LEN - array.length;
  for (var index = 0; index < len; index++) {
    array.add(0x00);
  }
  return array;
}

List<int> setMeasurementTimingData({required Map<String, dynamic> data}) {
  var array = <int>[];
  var fuc = data["function"];
  var type = data["type"];
  var time1 = data["time1"];
  var time1Interval = data["time1Interval"];
  var time2 = data["time2"];
  var time2Interval = data["time2Interval"];
  var time3Interval = data["time3Interval"];
  array.add(fuc & 0xff);
  array.add(type & 0xff);
  array.add(time1 & 0xff);
  array.add(time1Interval & 0xff); // 最低有效字节
  array.add((time1Interval >> 8) & 0xff); // 最高有效字节
  array.add(time2 & 0xff);
  array.add(time2Interval & 0xff); // 最低有效字节
  array.add((time2Interval >> 8) & 0xff);
  array.add(time3Interval & 0xff); 
  var len = DATA_TOTAL_LEN - array.length;
  for (var index = 0; index < len; index++) {
    array.add(0x00);
  }
  return array;
}

///on_off:0 OFF,1 ON
///led:0 绿灯,1 红灯,2 红外
///current 采样电流:0-255
///autoAdjBrightness:0 关闭自动亮度调节,1 开启自动亮度调节
///sps:0 25SPS,1 50SPS,2 100SPS,3 200SPS,4 400SPS
List<int> setPPGData({required Map<String, dynamic> data}) {
  var array = <int>[];
  var on_off = data["on_off"];
  var led = 0;
  var current = 0;
  var autoAdjBrightness = 1;
  var sps=2;
  array.add(on_off & 0xff);
  array.add(led & 0xff);
  array.add(current & 0xff);
  array.add(autoAdjBrightness & 0xff); // 最低有效字节
  array.add(sps & 0xff); // 最高有效字节
  var len = DATA_TOTAL_LEN - array.length;
  for (var index = 0; index < len; index++) {
    array.add(0x00);
  }
  return array;
}

List<int> commonData({data}) {
  var array = <int>[];
  for (var index = 0; index < DATA_TOTAL_LEN; index++) {
    array.add(0x00);
  }
  return array;
}
