import 'package:flutter/material.dart';

import './handlerimpl.dart';
import '../../common/ble_protocol_constant.dart';

class ControlHandler {
  late HandlerImpl temperatureHandler;

  ControlHandler() {
    temperatureHandler = getHandlerImpl(
        ReceiveCMD["Temperature"]!, handlerType["Temperature"]!); //85
    var historicalNumHandler = getHandlerImpl(
        ReceiveCMD["HistoricalNum"]!, handlerType["HistoricalNum"]!); //81
    var historicalDataHandler = getHandlerImpl(
        ReceiveCMD["HistoricalData"]!, handlerType["HistoricalData"]!); //82
    var historicalData2Handler = getHandlerImpl(
        ReceiveCMD["HistoricalData2"]!, handlerType["HistoricalData2"]!); //91
    var historicalData3Handler = getHandlerImpl(
        ReceiveCMD["HistoricalData3"]!, handlerType["HistoricalData3"]!); //92
    var ecgRawHandler =
        getHandlerImpl(ReceiveCMD["EcgRaw"]!, handlerType["EcgRaw"]!); //94
    var ecgAndPpgHandler = getHandlerImpl(
        ReceiveCMD["EcgAndPpg"]!, handlerType["EcgAndPpg"]!); //95
    var ecgAlgorithmHandler = getHandlerImpl(
        ReceiveCMD["EcgAlgorithm"]!, handlerType["EcgAlgorithm"]!); //96
    var ecgAlgorithmResultHandler = getHandlerImpl(
        ReceiveCMD["EcgAlgorithmResult"]!,
        handlerType["EcgAlgorithmResult"]!); //97
    var ecgFingerDetectHandler = getHandlerImpl(
        ReceiveCMD["EcgFingerDetect"]!, handlerType["EcgFingerDetect"]!); //98
    var deviceInfo1Handler = getHandlerImpl(
        ReceiveCMD["DeviceInfo1"]!, handlerType["DeviceInfo1"]!); //87
    var deviceInfo2Handler = getHandlerImpl(
        ReceiveCMD["DeviceInfo2"]!, handlerType["DeviceInfo2"]!); //88
    var deviceInfo5Handler = getHandlerImpl(
        ReceiveCMD["DeviceInfo5"]!, handlerType["DeviceInfo5"]!); //8F
    // var deviceInfo3Handler = DeviceInfo3Handler(); //8B
    var batteryDataAndStateHandler = getHandlerImpl(
        ReceiveCMD["BatteryData"]!, handlerType["BatteryDataAndState"]!); //86
    var rePackageHandler = getHandlerImpl(
        ReceiveCMD["Repackage"]!, handlerType["RePackage"]!); //80
    var healthHandler =
        getHandlerImpl(ReceiveCMD["GetHealth"]!, handlerType["Health"]!); //83
    var stepHandler =
        getHandlerImpl(ReceiveCMD["Step"]!, handlerType["Step"]!); //84
    var oemR1Handler =
        getHandlerImpl(ReceiveCMD["OEMR1"]!, handlerType["OEMR1"]!); //8D
    var oemResultHandler = getHandlerImpl(
        ReceiveCMD["OEMResult"]!, handlerType["OEMResult"]!); //8E
    // var triggerSOSHandler = TriggerSOSHandler(); //89
    // var SOSInfoHandler = SOSInfoHandler(); //8A
    var iRresouceHandler = getHandlerImpl(
        ReceiveCMD["IRresouce"]!, handlerType["IRresouce"]!); //BB
    // var redLightHandler = RedLightHandler(); //BC
    var greenOrIrHandler = getHandlerImpl(
        ReceiveCMD["GreenOrIr"]!, handlerType["GreenOrIr"]!); //BD

    //USER_INFO_OR_SET_MEASUREMENT_TIMING_OR_PPG
    var user_info_or_set_measurement_timing_or_query_algorithm_handler =
        getHandlerImpl(
            ReceiveCMD["USER_INFO_OR_SET_MEASUREMENT_TIMING_OR_PPG"]!,
            handlerType["USER_INFO_OR_SET_MEASUREMENT_TIMING_OR_PPG"]!); //C0

    //NEW_ALGORITHM_HISTORY
    var new_algorithm_history_handler = getHandlerImpl(
        ReceiveCMD["NEW_ALGORITHM_HISTORY"]!,
        handlerType["NEW_ALGORITHM_HISTORY"]!); //C1

    //NEW_ALGORITHM_HISTORY_NUM
    var new_algorithm_history_num_handler = getHandlerImpl(
        ReceiveCMD["NEW_ALGORITHM_HISTORY_NUM"]!,
        handlerType["NEW_ALGORITHM_HISTORY_NUM"]!); //C2

    //EXCLUDED_SWIMMING_ACTIVITY_HISTORY
    var excluded_swimming_activity_history_handler = getHandlerImpl(
        ReceiveCMD["EXCLUDED_SWIMMING_ACTIVITY_HISTORY"]!,
        handlerType["EXCLUDED_SWIMMING_ACTIVITY_HISTORY"]!); //C3

    //EXERCISE_ACTIVITY_HISTORY
    var exercise_activity_history_handler = getHandlerImpl(
        ReceiveCMD["EXERCISE_ACTIVITY_HISTORY"]!,
        handlerType["EXERCISE_ACTIVITY_HISTORY"]!); //C5

    //SWIMMING_EXERCISE_HISTORY
    var swimming_exercise_history_handler = getHandlerImpl(
        ReceiveCMD["SWIMMING_EXERCISE_HISTORY"]!,
        handlerType["SWIMMING_EXERCISE_HISTORY"]!); //C6

    //SINGLE_LAP_SWIMMING_HISTORY
    var single_lap_swimming_history_handler = getHandlerImpl(
        ReceiveCMD["SINGLE_LAP_SWIMMING_HISTORY"]!,
        handlerType["SINGLE_LAP_SWIMMING_HISTORY"]!); //C7

    //ACTIVE_DATA
    var active_data_handler = getHandlerImpl(
        ReceiveCMD["ACTIVE_DATA"]!, handlerType["ACTIVE_DATA"]!); //C8

    //SLEEP_HISTORY
    var sleep_history_handler = getHandlerImpl(
        ReceiveCMD["SLEEP_HISTORY"]!, handlerType["SLEEP_HISTORY"]!); //C9

    //DAILY_ACTIVITY_HISTORY
    var daily_activity_history_handler = getHandlerImpl(
        ReceiveCMD["DAILY_ACTIVITY_HISTORY"]!,
        handlerType["DAILY_ACTIVITY_HISTORY"]!); //CA

    //PPG_MEASUREMENT
    var ppg_measurement_handler = getHandlerImpl(
        ReceiveCMD["PPG_MEASUREMENT"]!, handlerType["PPG_MEASUREMENT"]!); //CB

    //EXERCISE_VITAL_SIGNS_HISTORY
    var exercise_vital_signs_history_handler = getHandlerImpl(
        ReceiveCMD["EXERCISE_VITAL_SIGNS_HISTORY"]!,
        handlerType["EXERCISE_VITAL_SIGNS_HISTORY"]!); //CC

    //GET_REPORTING_EXERCISE
    var get_reporting_exercise_handler = getHandlerImpl(
        ReceiveCMD["GET_REPORTING_EXERCISE"]!,
        handlerType["GET_REPORTING_EXERCISE"]!); //CD

    //TEMPERATURE_HISTORY
    var temperature_history_handler = getHandlerImpl(
        ReceiveCMD["TEMPERATURE_HISTORY"]!,
        handlerType["TEMPERATURE_HISTORY"]!); //CE

    //PPG_DATA
    var ppg_data_handler =
        getHandlerImpl(ReceiveCMD["PPG_DATA"]!, handlerType["PPG_DATA"]!); //D0

    //STEP_TEMPERATURE_ACTIVITY_INTENSITY_HISTORY
    var step_temperature_activity_intensity_history_handler = getHandlerImpl(
        ReceiveCMD["STEP_TEMPERATURE_ACTIVITY_INTENSITY_HISTORY"]!,
        handlerType["STEP_TEMPERATURE_ACTIVITY_INTENSITY_HISTORY"]!); //D1

    temperatureHandler.setNextHandler(historicalNumHandler);
    historicalNumHandler.setNextHandler(historicalDataHandler);
    historicalDataHandler.setNextHandler(historicalData2Handler);
    historicalData2Handler.setNextHandler(historicalData3Handler);
    historicalData3Handler.setNextHandler(deviceInfo1Handler);
    deviceInfo1Handler.setNextHandler(deviceInfo2Handler);
    deviceInfo2Handler.setNextHandler(deviceInfo5Handler);
    deviceInfo5Handler.setNextHandler(batteryDataAndStateHandler);
    // deviceInfo3Handler.setNextHandler(batteryDataAndStateHandler);
    batteryDataAndStateHandler.setNextHandler(rePackageHandler);
    rePackageHandler.setNextHandler(healthHandler);
    healthHandler.setNextHandler(stepHandler);
    stepHandler.setNextHandler(oemR1Handler);
    oemR1Handler.setNextHandler(oemResultHandler);
    oemResultHandler.setNextHandler(iRresouceHandler);
    iRresouceHandler.setNextHandler(greenOrIrHandler);
    greenOrIrHandler.setNextHandler(ecgRawHandler);
    ecgRawHandler.setNextHandler(ecgAndPpgHandler);
    ecgAndPpgHandler.setNextHandler(ecgAlgorithmHandler);
    ecgAlgorithmHandler.setNextHandler(ecgAlgorithmResultHandler);
    ecgAlgorithmResultHandler.setNextHandler(ecgFingerDetectHandler);
    ecgFingerDetectHandler.setNextHandler(
        user_info_or_set_measurement_timing_or_query_algorithm_handler);
    user_info_or_set_measurement_timing_or_query_algorithm_handler
        .setNextHandler(new_algorithm_history_handler);
    new_algorithm_history_handler
        .setNextHandler(new_algorithm_history_num_handler);
    new_algorithm_history_num_handler
        .setNextHandler(excluded_swimming_activity_history_handler);
    excluded_swimming_activity_history_handler
        .setNextHandler(exercise_activity_history_handler);
    exercise_activity_history_handler
        .setNextHandler(swimming_exercise_history_handler);
    swimming_exercise_history_handler
        .setNextHandler(single_lap_swimming_history_handler);
    single_lap_swimming_history_handler.setNextHandler(active_data_handler);
    active_data_handler.setNextHandler(sleep_history_handler);
    sleep_history_handler.setNextHandler(daily_activity_history_handler);
    daily_activity_history_handler.setNextHandler(ppg_measurement_handler);
    ppg_measurement_handler
        .setNextHandler(exercise_vital_signs_history_handler);
    exercise_vital_signs_history_handler
        .setNextHandler(get_reporting_exercise_handler);
    get_reporting_exercise_handler.setNextHandler(temperature_history_handler);
    temperature_history_handler.setNextHandler(ppg_data_handler);
    ppg_data_handler
        .setNextHandler(step_temperature_activity_intensity_history_handler);

    // stepHandler.setNextHandler(iRresouceHandler);
    // triggerSOSHandler.setNextHandler(SOSInfoHandler);
    // SOSInfoHandler.setNextHandler(iRresouceHandler);

    // this.temperatureHandler = temperatureHandler;
  }

  HandlerImpl getHandlerImpl(int cmd, int type) {
    // debugPrint("  cmd: $cmd, type: $type");
    return HandlerImpl(cmd, type);
  }

  parseData(data) {
    temperatureHandler.handlerRequest(data);
  }
}
