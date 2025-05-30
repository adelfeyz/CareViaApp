import 'package:flutter/material.dart';

import '../common/ble_protocol_constant.dart';

List healthList = [];
List rePackageList = [];
List stepList = [];
List temperatureList = [];
List historicalNumList = [];
List historicalDataList = [];
List deviceInfo1DataList = [];
List deviceInfo2DataList = [];
List deviceInfo5DataList = [];
List oemR1List = [];
List oemResultList = [];
List batteryDataAndStateList = [];
List irResourceList = [];
List greenOrIrList = [];
List ecgRawList = [];
List ecgAndPpgList = [];
List ecgAlgorithmList = [];
List ecgAlgorithmResultList = [];
List ecgFingerDetectList = [];
List userInfo = [];
List measurementTiming = [];
List newAlgorithmHistoryList = [];
List newAlgorithmHistoryNumList = [];
List excludedSwimmingActivityHistoryList = [];
List exerciseActivityHistoryList = [];
List swimmingExerciseHistoryList = [];
List singleLapSwimmingHistoryList = [];
List stepTemperatureActivityIntensityHistoryList = [];
List activeDataList = [];
List sleepHistoryList = [];
List dailyActivityHistoryList = [];
List ppgMeasurementList = [];
List exerciseVitalSignsHistoryList = [];
List getReportingExerciseList = [];
List temperatureHistoryList = [];
List ppgSetList = [];
List ppgDataList = [];
Map listenerMap = <int, List>{
  ReceiveType.Temperature: temperatureList,
  ReceiveType.HistoricalData: historicalDataList,
  ReceiveType.HistoricalData2: historicalDataList,
  ReceiveType.HistoricalData3: historicalDataList,
  ReceiveType.HistoricalNum: historicalNumList,
  ReceiveType.DeviceInfo1: deviceInfo1DataList,
  ReceiveType.DeviceInfo2: deviceInfo2DataList,
  ReceiveType.DeviceInfo5: deviceInfo5DataList,
  ReceiveType.BatteryDataAndState: batteryDataAndStateList,
  ReceiveType.RePackage: rePackageList,
  ReceiveType.Health: healthList,
  ReceiveType.Step: stepList,
  ReceiveType.OEMR1: oemR1List,
  ReceiveType.OEMResult: oemResultList,
  ReceiveType.IRresouce: irResourceList,
  ReceiveType.GreenOrIr: greenOrIrList,
  ReceiveType.EcgRaw: ecgRawList,
  ReceiveType.EcgAndPpg: ecgAndPpgList,
  ReceiveType.EcgAlgorithm: ecgAlgorithmList,
  ReceiveType.EcgAlgorithmResult: ecgAlgorithmResultList,
  ReceiveType.EcgFingerDetect: ecgFingerDetectList,
  ReceiveType.USER_INFO: userInfo,
  ReceiveType.SET_MEASUREMENT_TIMING: measurementTiming,
  ReceiveType.NEW_ALGORITHM_HISTORY: newAlgorithmHistoryList,
  ReceiveType.NEW_ALGORITHM_HISTORY_NUM: newAlgorithmHistoryNumList,
  ReceiveType.EXCLUDED_SWIMMING_ACTIVITY_HISTORY:
      excludedSwimmingActivityHistoryList,
  ReceiveType.EXERCISE_ACTIVITY_HISTORY: exerciseActivityHistoryList,
  ReceiveType.SWIMMING_EXERCISE_HISTORY: swimmingExerciseHistoryList,
  ReceiveType.SINGLE_LAP_SWIMMING_HISTORY: singleLapSwimmingHistoryList,
  ReceiveType.STEP_TEMPERATURE_ACTIVITY_INTENSITY_HISTORY:
      stepTemperatureActivityIntensityHistoryList,
  ReceiveType.ACTIVE_DATA: activeDataList,
  ReceiveType.SLEEP_HISTORY: sleepHistoryList,
  ReceiveType.DAILY_ACTIVITY_HISTORY: dailyActivityHistoryList,
  ReceiveType.PPG_MEASUREMENT: ppgMeasurementList,
  ReceiveType.EXERCISE_VITAL_SIGNS_HISTORY: exerciseVitalSignsHistoryList,
  ReceiveType.GET_REPORTING_EXERCISE: getReportingExerciseList,
  ReceiveType.TEMPERATURE_HISTORY: temperatureHistoryList,
  ReceiveType.PPG_SET: ppgSetList,
  ReceiveType.PPG_DATA:ppgDataList,
};

void registerListener(int type, dynamic listener) {
  unRegisterListener(type, listener);
  // debugPrint("registerListener type:$type,listenerMap[type]=${listenerMap[type]}");
  if (!listenerMap[type].contains(listener)) {
    // debugPrint(" registerListener $type $listener");
    listenerMap[type].add(listener);
  }
}

void unRegisterListener(int type, listener) {
  if (listener != null) {
    int index = listenerMap[type].indexOf(listener);
    if (index != -1) {
      listenerMap[type].removeAt(index);
    }
  }
}

void dispatchData(int type, data) {
  int receiveType = type;
  if (receiveType == ReceiveType.HistoricalData2 ||
      receiveType == ReceiveType.HistoricalData3) {
    receiveType = ReceiveType.HistoricalData;
  }
  if (receiveType == ReceiveType.USER_INFO_OR_SET_MEASUREMENT_TIMING_OR_PPG) {
    if (data["cmd"] == SendCMD.USER_INFO) {
      receiveType = ReceiveType.USER_INFO;
      data.remove("cmd");
    } else if (data["cmd"] == SendCMD.SET_MEASUREMENT_TIMING) {
      receiveType = ReceiveType.SET_MEASUREMENT_TIMING;
      data.remove("cmd");
    } else if (data["cmd"] == SendCMD.Ppg) {
      receiveType = ReceiveType.PPG_SET;
      data.remove("cmd");
    }
  }
  // debugPrint("type: $type, data: $data listenerMap[type]${listenerMap[type]}");
  for (var listener in listenerMap[receiveType]) {
    // debugPrint("listener: $listener");
    listener(data);
  }
}
