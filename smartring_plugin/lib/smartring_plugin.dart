import 'dart:ffi';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart' as pgffi;
import 'package:flutter/material.dart';

import 'smartring_plugin_bindings_generated.dart';

String _company = "Linktop";
// String _company = "Bonatra";
class SleepType {
  static const int NONE = 0;
  static const int WAKE = 1;
  static const int NREM1 = 2;
  static const int NREM3 = 3;
  static const int REM = 4;
  static const int NAP = 5;
}

List<int> aes128_decrypt(
  List<int> sn,
  List<int> data,
) {
  int company_size = _company.length;
  Pointer<Char> companyPtr = _company.toNativeUtf8().cast<Char>();

// sn分配内存
  int sn_size = sn.length;
  final snPtr = pgffi.calloc<ffi.Char>(sn_size);

// 将数据复制到内存中
  for (var i = 0; i < sn.length; i++) {
    final charCode = sn[i];
    snPtr[i] = charCode;
  }

  //加密数据处理
// sn分配内存
  int data_size = data.length;
  final dataPtr = pgffi.calloc<ffi.Char>(data_size);

// 将数据复制到内存中
  for (var i = 0; i < data.length; i++) {
    final charCode = data[i];
    dataPtr[i] = charCode;
  }

  //处理输出数据
  var out_size = 0;
  if (0 == data_size % 16) {
    out_size = data_size;
  } else {
    out_size = data_size + (16 - data_size % 16);
  }
  final outPtr = pgffi.calloc<ffi.Char>(out_size);

  _bindings.aes128_decrypt(
    snPtr,
    sn_size,
    companyPtr,
    company_size,
    dataPtr,
    data_size,
    outPtr,
  );
  List<int> out_data = [];
  for (var i = 0; i < out_size; i++) {
    final charCode = outPtr[i];
    out_data.add(charCode);
  }
  pgffi.calloc.free(companyPtr);
  pgffi.calloc.free(snPtr);
  pgffi.calloc.free(dataPtr);
  pgffi.calloc.free(outPtr);
  return out_data;
}

//计算电池电量
int toBatteryLevel(int voltage, bool charging, bool wireless) {
  return _bindings.toBatteryLevel(voltage, charging, wireless);
}

//计算血氧饱和度
List oxygenSaturation(List sleepTimeArray, List historyArray) {
  int sleepSize = sleepTimeArray.length;
  int historySize = historyArray.length;
  List resultArray = [];
  final sleepArrayPointer =
      pgffi.calloc<ffi.Pointer<SleepArrayElement>>(sleepSize);
  for (var i = 0; i < sleepSize; i++) {
    sleepArrayPointer.elementAt(i).value = _bindings.createSleepArrayElement(
        0,
        sleepTimeArray[i]["sleepTimePeriod"]["startTime"],
        sleepTimeArray[i]["sleepTimePeriod"]["endTime"]);
  }
// debugPrint(
//         " hr0=${sleepArray[0]["hr"]} ,startTime=${sleepArray[0]["startTime"]} , endTime=${sleepArray[0]["endTime"]} ,sleepArray.length=${sleepArray.length}");
//         debugPrint(
//         " hr=${sleepArray[0]["hr"]} ,startTime0=${sleepArrayPointer[0].ref.sleepTimePeriod.startTime} , endTime=${sleepArrayPointer[0].ref.sleepTimePeriod.endTime} ,sleepArray.length=${sleepArray.length}");
//         debugPrint(
//         " hr1=${sleepArray[1]["hr"]} ,startTime=${sleepArray[1]["startTime"]} , endTime=${sleepArray[1]["endTime"]} ,sleepArray.length=${sleepArray.length}");
//         debugPrint(
//         " hr=${sleepArray[1]["hr"]} ,startTime1=${sleepArrayPointer[1].ref.sleepTimePeriod.startTime} , endTime=${sleepArrayPointer[1].ref.sleepTimePeriod.endTime} ,sleepArray.length=${sleepArray.length}");
  final resultSizePointer = pgffi.calloc<ffi.Int>();

  final historyArrayPointer = pgffi.calloc<ffi.Pointer<Data>>(historySize);
  for (var i = 0; i < historySize; i++) {
    historyArrayPointer[i] = _bindings.createDataArrayElement(
        historyArray[i]["ts"], historyArray[i]["hr"], historyArray[i]["ox"]);
  }
  // historyArrayPointer.elementAt(0).value =
  //     _bindings.createDataArrayElement(1619915100000, 77, 85);
  // historyArrayPointer.elementAt(0).value =
  //     _bindings.createDataArrayElement(1619918700000, 55, 78);
  // historyArrayPointer.elementAt(0).value =
  //     _bindings.createDataArrayElement(1619919100000, 65, 86);
  ffi.Pointer<OxygenSaturationResult> result = _bindings.oxygenSaturation(
      sleepArrayPointer,
      sleepSize,
      historyArrayPointer,
      historySize,
      resultSizePointer);

  for (var i = 0; i < resultSizePointer[0]; i++) {
    resultArray.add({
      "startTime": formatDateTime(result[i].startTime),
      "endTime": formatDateTime(result[i].endTime),
      "oxygen": result[i].oxygen
    });
  }

  pgffi.calloc.free(sleepArrayPointer);
  pgffi.calloc.free(historyArrayPointer);
  pgffi.calloc.free(resultSizePointer);
  pgffi.calloc.free(result);
  return resultArray;
  // OxygenSaturationResult bb=aa.elementAt(0).cast<OxygenSaturationResult>() as OxygenSaturationResult;
}

//计算心率沉浸
List<Map> heartRateImmersion(
    List sleepTimeArray, List historyArray, List hrArray) {
  int sleepArraySize = sleepTimeArray.length;
  int historyArraySize = historyArray.length;
  int hrArraySize = hrArray.length;
  List<Map> resultArray = [];
  final sleepArrayPointer =
      pgffi.calloc<ffi.Pointer<SleepArrayElement>>(sleepArraySize);
  for (var i = 0; i < sleepArraySize; i++) {
    sleepArrayPointer.elementAt(i).value = _bindings.createSleepArrayElement(
        0,
        sleepTimeArray[i]["sleepTimePeriod"]["startTime"],
        sleepTimeArray[i]["sleepTimePeriod"]["endTime"]);
  }
  final historyArrayPointer = pgffi.calloc<ffi.Pointer<Data>>(historyArraySize);
  for (var i = 0; i < historyArraySize; i++) {
    historyArrayPointer[i] = _bindings.createDataArrayElement(
        historyArray[i]["ts"], historyArray[i]["hr"], historyArray[i]["ox"]);
  }
  final hrArrayPointer = pgffi.calloc<ffi.Pointer<Data>>(hrArraySize);
  for (var i = 0; i < hrArraySize; i++) {
    hrArrayPointer[i] =
        _bindings.createDataArrayElement(hrArray[i]["ts"], hrArray[i]["hr"], 0);
  }

  final resultSizePointer = pgffi.calloc<ffi.Int>();
  ffi.Pointer<HeartRateImmersionResult> hrIPointer =
      _bindings.heartRateImmersion(
          sleepArrayPointer,
          sleepArraySize,
          historyArrayPointer,
          historyArraySize,
          hrArrayPointer,
          hrArraySize,
          resultSizePointer);
  for (var i = 0; i < resultSizePointer[0]; i++) {
    // debugPrint(
    //     " startTime=${result.elementAt(i).ref.startTime} ,endTime=${result.elementAt(i).ref.endTime} , ox=${result[i].oxygen}");

    resultArray.add({
      "time": formatDateTime(hrIPointer[i].ts, isFull: false),
      "restingHeartRate": hrIPointer[i].restingHeartRate,
    });
  }
  pgffi.calloc.free(sleepArrayPointer);
  pgffi.calloc.free(historyArrayPointer);
  pgffi.calloc.free(hrArrayPointer);
  pgffi.calloc.free(hrIPointer);
  return resultArray;
}

//计算呼吸率
List<Map> respiratoryRate(List sleepTimeArray, List historyArray) {
  List<Map> resultArray = [];
  int sleepArraySize = sleepTimeArray.length;
  int historyArraySize = historyArray.length;
  final sleepArrayPointer =
      pgffi.calloc<ffi.Pointer<SleepArrayElement>>(sleepArraySize);
  for (var i = 0; i < sleepArraySize; i++) {
    sleepArrayPointer.elementAt(i).value = _bindings.createSleepArrayElement(
        0,
        sleepTimeArray[i]["sleepTimePeriod"]["startTime"],
        sleepTimeArray[i]["sleepTimePeriod"]["endTime"]);
  }
  final historyArrayPointer = pgffi.calloc<ffi.Pointer<Data>>(historyArraySize);
  for (var i = 0; i < historyArraySize; i++) {
    historyArrayPointer[i] = _bindings.createDataArrayElement(
        historyArray[i]["ts"], historyArray[i]["hr"], historyArray[i]["ox"]);
  }
  final resultSizePointer = pgffi.calloc<ffi.Int>();
  final respiratoryRateResult = _bindings.respiratoryRate(sleepArrayPointer,
      sleepArraySize, historyArrayPointer, historyArraySize, resultSizePointer);
  for (var i = 0; i < resultSizePointer[0]; i++) {
    resultArray.add({
      "startTime": respiratoryRateResult[i].timeSlot.sleepTimePeriod.startTime,
      "endTime": respiratoryRateResult[i].timeSlot.sleepTimePeriod.endTime,
      "hrAvg": respiratoryRateResult[i].timeSlot.data,
      "respiratoryRate": respiratoryRateResult[i].respiratoryRate,
    });
  }
  return resultArray;
}

//静息心率
List<Map> restingHeartRate(List hrArray) {
  List<Map> resultArray = [];
  int hrArraySize = hrArray.length;
  final hrArrayPointer = pgffi.calloc<ffi.Pointer<Data>>(hrArraySize);
  for (var i = 0; i < hrArraySize; i++) {
    hrArrayPointer[i] =
        _bindings.createDataArrayElement(hrArray[i]["ts"], hrArray[i]["hr"], 0);
  }

  final resultSizePointer = pgffi.calloc<ffi.Int>();
  final restingHeartRateData = _bindings.restingHeartRate(
      hrArrayPointer, hrArraySize, resultSizePointer);

  for (var i = 0; i < resultSizePointer[0]; i++) {
    resultArray.add({
      "ts": restingHeartRateData[i].ref.ts,
      "data": restingHeartRateData[i].ref.hr,
    });
  }
  pgffi.calloc.free(hrArrayPointer);
  pgffi.calloc.free(resultSizePointer);
  return resultArray;
}

//计算卡路里
double caloriesCalculation(
  double height,
  int step,
  double strengthGrade,
) {
  return _bindings.caloriesCalculation(height, step, strengthGrade);
}

List<Map> sleepNewAlgorithm(List historyArray,List newHistoryArray) {
  List<Map> resultArray = [];
  int historyArraySize = historyArray.length;
  int newHistoryArraySize = newHistoryArray.length;
  final hr_list = pgffi.calloc<smp_hr_t>(historyArraySize);
  final csem_list = pgffi.calloc<csem_sleep_t>(newHistoryArraySize);
  final root = pgffi.calloc<ffi.Pointer<sleep_root>>(historyArraySize);
  for (var i = 0; i < historyArraySize; i++) {
    hr_list[i].hrv = historyArray[i]["hrv"];
    hr_list[i].motion = historyArray[i]["motion"];
    hr_list[i].rate = historyArray[i]["hr"];
    hr_list[i].steps = historyArray[i]["steps"];
    hr_list[i].ts = historyArray[i]["ts"];
  }
  for (var i = 0; i < newHistoryArraySize; i++) {
    csem_list[i].bed_rest_duration = newHistoryArray[i]["bed_rest_duration"];
    csem_list[i].type = newHistoryArray[i]["type"];
    csem_list[i].awake_order = newHistoryArray[i]["awake_order"];
    csem_list[i].ts = newHistoryArray[i]["ts"];
  }
  _bindings.csem_calc(1,1,csem_list, newHistoryArraySize, hr_list, historyArraySize, root);
 if (root[0].address != 0) {
    // debugPrint(" root[0].ref.count=${root[0].ref.count} ");
    for (var i = 0; i < root[0].ref.count; i++) {
      List<Map> stagingList = [];
      // debugPrint(" root[0].ref.summaries[i].cnt_acts=${root[0].ref.summaries[i].cnt_acts} ");
      for (var j = 0; j < root[0].ref.summaries[i].cnt_acts; j++) {
        var ea = root[0].ref.summaries[i].act_list[j];

        int begin = ea.begin;
        int end = ea.end;
        int type = 0;
        switch (ea.type) {
          case sleep_type_t.ENUM_SLEEP_STAGING_TYPE_WAKE:
            type = SleepType.WAKE;
            break;
          case sleep_type_t.ENUM_SLEEP_STAGING_TYPE_NREM1:
            type = SleepType.NREM1;
            break;
          case sleep_type_t.ENUM_SLEEP_STAGING_TYPE_NREM3:
            type = SleepType.NREM3;
            break;
          case sleep_type_t.ENUM_SLEEP_STAGING_TYPE_REM:
            type = SleepType.REM;
            break;
          case sleep_type_t.ENUM_SLEEP_STAGING_TYPE_NAP:
            type = SleepType.NAP;
            break;
          default:
            type = SleepType.NONE;
            break;
        }
        stagingList.add({"type": type, "startTime": begin, "endTime": end});
        // debugPrint("stagingList startTime ${formatDateTime(begin)} ");
      }
      resultArray.add({
        "startTime": root[0].ref.summaries[i].begin,
        "endTime": root[0].ref.summaries[i].end,
        "stagingList": stagingList
      });
      // debugPrint("stagingList end 睡眠开始时间 ${formatDateTime(root[0].ref.summaries[i].begin)} ");
    }
    _bindings.free_activities(root[0]);
  }

  pgffi.calloc.free(hr_list);
  pgffi.calloc.free(csem_list);
  pgffi.calloc.free(root);
  return resultArray;
}

List<Map> sleepAlgorithm(List historyArray) {
  List<Map> resultArray = [];

  int historyArraySize = historyArray.length;
  final hr_list = pgffi.calloc<smp_hr_t>(historyArraySize);
  // ffi.Pointer<sleep_root> myPointer = ffi.Pointer.fromAddress(0);
  // ffi.Pointer<ffi.Pointer<sleep_root>> root = ffi.Pointer<ffi.Pointer<sleep_root>>.fromAddress(myPointer.address);
  final root = pgffi.calloc<ffi.Pointer<sleep_root>>(historyArraySize);
  for (var i = 0; i < historyArraySize; i++) {
    hr_list[i].hrv = historyArray[i]["hrv"];
    hr_list[i].motion = historyArray[i]["motion"];
    hr_list[i].rate = historyArray[i]["hr"];
    hr_list[i].steps = historyArray[i]["steps"];
    hr_list[i].ts = historyArray[i]["ts"];
  }
  for (var i = 0; i < historyArraySize; i++) {
    // debugPrint(" 1sleepAlgorithm  hrv=${hr_list[i].hrv} motion=${hr_list[i].motion} rate=${hr_list[i].rate} steps=${hr_list[i].steps} ts=${hr_list[i].ts}");
  }
  _bindings.v3_calc(hr_list, historyArraySize, root);
  if (root[0].address != 0) {
    // debugPrint(" root[0].ref.count=${root[0].ref.count} ");
    for (var i = 0; i < root[0].ref.count; i++) {
      List<Map> stagingList = [];
      // debugPrint(" root[0].ref.summaries[i].cnt_acts=${root[0].ref.summaries[i].cnt_acts} ");
      for (var j = 0; j < root[0].ref.summaries[i].cnt_acts; j++) {
        var ea = root[0].ref.summaries[i].act_list[j];

        int begin = ea.begin;
        int end = ea.end;
        int type = 0;
        switch (ea.type) {
          case sleep_type_t.ENUM_SLEEP_STAGING_TYPE_WAKE:
            type = SleepType.WAKE;
            break;
          case sleep_type_t.ENUM_SLEEP_STAGING_TYPE_NREM1:
            type = SleepType.NREM1;
            break;
          case sleep_type_t.ENUM_SLEEP_STAGING_TYPE_NREM3:
            type = SleepType.NREM3;
            break;
          case sleep_type_t.ENUM_SLEEP_STAGING_TYPE_REM:
            type = SleepType.REM;
            break;
          case sleep_type_t.ENUM_SLEEP_STAGING_TYPE_NAP:
            type = SleepType.NAP;
            break;
          default:
            type = SleepType.NONE;
            break;
        }
        stagingList.add({"type": type, "startTime": begin, "endTime": end});
        // debugPrint("stagingList startTime ${formatDateTime(begin)} ");
      }
      resultArray.add({
        "startTime": root[0].ref.summaries[i].begin,
        "endTime": root[0].ref.summaries[i].end,
        "stagingList": stagingList
      });
      // debugPrint("stagingList end 睡眠开始时间 ${formatDateTime(root[0].ref.summaries[i].begin)} ");
    }
    _bindings.free_activities(root[0]);
  }

  pgffi.calloc.free(hr_list);
  pgffi.calloc.free(root);
  return resultArray;
}

/**
 * If the timestamp reported by the ring is abnormal, this function needs to be used to fix it
 */
List<Map> timeRepair(List historyArray) {
  List<Map> resultArray = [];
  int historyArraySize = historyArray.length;
  final historyDataPointer = pgffi.calloc<HistoryData>(historyArraySize);
  for (var i = 0; i < historyArraySize; i++) {
    historyDataPointer[i].chargeStatus = historyArray[i]["chargeStatus"];
    historyDataPointer[i].detectionMode = historyArray[i]["detectionMode"];
    historyDataPointer[i].heartRate = historyArray[i]["heartRate"];
    historyDataPointer[i].hrv = historyArray[i]["hrv"];
    historyDataPointer[i].motionDetectionCount =
        historyArray[i]["motionDetectionCount"];
    historyDataPointer[i].ox = historyArray[i]["ox"];
    historyDataPointer[i].reStep = historyArray[i]["reStep"];
    historyDataPointer[i].respiratoryRate = historyArray[i]["respiratoryRate"];
    historyDataPointer[i].step = historyArray[i]["step"];
    historyDataPointer[i].temperature =
        double.parse(historyArray[i]["temperature"]).toInt();
    historyDataPointer[i].timeStamp = historyArray[i]["timeStamp"];
    historyDataPointer[i].uuid = historyArray[i]["uuid"];
    historyDataPointer[i].wearStatus = historyArray[i]["wearStatus"];
  }
  _bindings.timeRepair(historyDataPointer, historyArraySize);
  for (var i = 0; i < historyArraySize; i++) {
    resultArray.add({
      "chargeStatus": historyDataPointer[i].chargeStatus,
      "detectionMode": historyDataPointer[i].detectionMode,
      "heartRate": historyDataPointer[i].heartRate,
      "hrv": historyDataPointer[i].hrv,
      "motionDetectionCount": historyDataPointer[i].motionDetectionCount,
      "ox": historyDataPointer[i].ox,
      "reStep": historyDataPointer[i].reStep,
      "respiratoryRate": historyDataPointer[i].respiratoryRate,
      "step": historyDataPointer[i].step,
      "temperature": historyDataPointer[i].temperature,
      "timeStamp": historyDataPointer[i].timeStamp,
      "uuid": historyDataPointer[i].uuid,
      "wearStatus": historyDataPointer[i].wearStatus,
    });
  }
  pgffi.calloc.free(historyDataPointer);

  return resultArray;
}

String formatDateTime(int timestamp, {bool isFull = true}) {
  // 将时间戳转换为 DateTime 对象
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

  // 提取年、月、日
  int year = dateTime.year;
  int month = dateTime.month;
  int day = dateTime.day;
  int hour = dateTime.hour;
  int minute = dateTime.minute;
  String result =
      isFull ? ' $year-$month-$day|$hour:$minute' : ' $year-$month-$day';
  return result;
}

const String _libName = 'smartring_plugin';

/// The dynamic library in which the symbols for [SmartringPluginBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    // return DynamicLibrary.open('$_libName.framework/$_libName');
   return DynamicLibrary.process();
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final SmartringPluginBindings _bindings = SmartringPluginBindings(_dylib);
