import 'package:flutter/material.dart';

import './command.dart';
import '../../common/ble_protocol_constant.dart';
import '../../store/store.dart';

class ControlSend {
  static final ControlSend _instance = ControlSend._internal();

  factory ControlSend() {
    return _instance;
  }

  ControlSend._internal();

  get map => createMap();

  createMap() {
    var map = new Map();
    //时间同步命令
    var timeSynCommand = CommandImpl(SendCMD.TimeSyncSettings);
    map[SendType.timeSyn] = timeSynCommand;
    //计步
    var stepCommand = CommandImpl(SendCMD.Step);
    map[SendType.step] = stepCommand;
    //获取单心率 开
    // var openSingleHealthCommand =
    //     new CreateCommand(new Command.GetHealthCommand(true, false));
    // map.set(this.openSingleHealth, openSingleHealthCommand);
    var openSingleHealthCommand = CommandImpl(SendCMD.GetHealth,
        innerData: {"isOn": true, "isSingle": true});
    map[SendType.openSingleHealth] = openSingleHealthCommand;
    // console.log(`this.openSingleHealth=${this.openSingleHealth} openSingleHealthCommand=${openSingleHealthCommand}`);
    //获取单心率 关
    var closeSingleHealthCommand = CommandImpl(SendCMD.GetHealth,
        innerData: {"isOn": false, "isSingle": true});
    map[SendType.closeSingleHealth] = closeSingleHealthCommand;
    //获取心率血氧 开
    var openHealthCommand = CommandImpl(SendCMD.GetHealth,
        innerData: {"isOn": true, "isSingle": false});
    map[SendType.openHealth] = openHealthCommand;
    //获取心率血氧 关
    var closeHealthCommand = CommandImpl(SendCMD.GetHealth,
        innerData: {"isOn": false, "isSingle": false});
    map[SendType.closeHealth] = closeHealthCommand;
    //获取体温
    var temperatureCommand = CommandImpl(SendCMD.Temperature);
    map[SendType.temperature] = temperatureCommand;
    //关机命令
    var shutDownCommand = CommandImpl(SendCMD.ShutDown);
    map[SendType.shutDown] = shutDownCommand;
    //重启命令
    var restartCommand = CommandImpl(SendCMD.Restart);
    map[SendType.restart] = restartCommand;
    //恢复出厂设置
    var restoreFactorySettingsCommand =
        CommandImpl(SendCMD.RestoreFactorySettings);
    map[SendType.restoreFactorySettings] = restoreFactorySettingsCommand;
    // //工厂测试
    // var factoryTestCommand = new CreateCommand(new Command.FactoryTestCommand());
    // map.set(this.factoryTest, factoryTestCommand);
    //获取历史数据个数

    var historicalNumCommand = CommandImpl(SendCMD.HistoricalNum);
    map[SendType.historicalNum] = historicalNumCommand;
    //获取历史数据

    var historicalDataCommand = CommandImpl(SendCMD.HistoricalData);
    map[SendType.historicalData] = historicalDataCommand;
    //清空历史数据
    var cleanHistoricalDataCommand = CommandImpl(SendCMD.CleanHistoricalData);
    map[SendType.cleanHistoricalData] = cleanHistoricalDataCommand;
    //获取设备信息1
    var deviceInfo1Command = CommandImpl(SendCMD.DeviceInfo1);
    map[SendType.deviceInfo1] = deviceInfo1Command;
    //获取设备信息2

    var deviceInfo2Command = CommandImpl(SendCMD.DeviceInfo2);
    map[SendType.deviceInfo2] = deviceInfo2Command;
    //获取电池电量和充电状态

    var batteryDataAndStateCommand = CommandImpl(SendCMD.BatteryDataAndState);
    map[SendType.batteryDataAndState] = batteryDataAndStateCommand;
    //开启飞行模式
    // var openFlightCommand = new CreateCommand(new Command.OpenFlightCommand());
    // map.set(this.openFlight, openFlightCommand);
    //设置SOS参数
    // var setSOSparaCommand = new CreateCommand(new Command.SetSOSparaCommand());
    // map.set(this.setSOSpara, setSOSparaCommand);
    //设备写号
    // var writeNumCommand = new CreateCommand(new Command.WriteNumCommand());
    // map.set(this.writeNum, writeNumCommand);
    //设备绑定和解绑

    var deviceBindCommand =
        CommandImpl(SendCMD.DeviceBindAndUnBind, innerData: {"isBind": true});
    map[SendType.deviceBind] = deviceBindCommand;

    var deviceUnBindCommand =
        CommandImpl(SendCMD.DeviceBindAndUnBind, innerData: {"isBind": false});
    map[SendType.deviceUnBind] = deviceUnBindCommand;
    //心率血氧测量参数设置
    var setHealthParaCommand = CommandImpl(SendCMD.SetHealthPara);
    map[SendType.setHealthPara] = setHealthParaCommand;
    // //获取设备信息3
    // var deviceInfo3Command = new CreateCommand(new Command.DeviceInfo3Command());
    // map.set(this.deviceInfo3, deviceInfo3Command);
    // //获取设备信息4
    // var deviceInfo4Command = new CreateCommand(new Command.DeviceInfo4Command());
    // map.set(this.deviceInfo4, deviceInfo4Command);
    //设备授权设置 预留
    // var deviceAuthorizationCommand = new CreateCommand(new Command.DeviceAuthorizationCommand());
    // map.set(this.deviceAuthorization, deviceAuthorizationCommand);
    //设备功能开关设置 预留
    // var deviceFunSwitchCommand = new CreateCommand(new Command.DeviceFunSwitchCommand());
    // map.set(this.deviceFunSwitch, deviceFunSwitchCommand);
    //设置ADV-FUNC和ADV-SOS广播参数
    // var ADVParaCommand = new CreateCommand(new Command.ADVParaCommand());
    // map.set(this.ADVPara, ADVParaCommand);
    //低电量阈值 目前只在SR01上实现
    // var lowBatteryThresholdCommand = new CreateCommand(new Command.LowBatteryThresholdCommand());
    // map.set(this.lowBatteryThreshold, lowBatteryThresholdCommand);
    //设置心率测量时间

    var heartRateTimeCommand = CommandImpl(SendCMD.HeartRateTime);
    map[SendType.setHrTime] = heartRateTimeCommand;
    //设置OEM验证开关

    var switchOEMCommand = CommandImpl(SendCMD.SwitchOem);
    map[SendType.switchOEM] = switchOEMCommand;
    //OEM验证开始
    var startOEMVerifyCommand = CommandImpl(SendCMD.StartOemVerify);
    map[SendType.startOEMVerify] = startOEMVerifyCommand;
    //OEM验证开始下发R2

    var startOEMVerifyR2Command = CommandImpl(SendCMD.StartOemVerifyR2);
    map[SendType.startOEMVerifyR2] = startOEMVerifyR2Command;
    //设置AESkey

    var setAESKeyCommand = CommandImpl(SendCMD.SetOemAesKey);
    map[SendType.setAESkey] = setAESKeyCommand;
    //设置AES-IV

    var setAESIvCommand = CommandImpl(SendCMD.SetOemAesIv);
    map[SendType.setAESIv] = setAESIvCommand;
    //运动模式设置 （不要）
    // var SportModeSettingsCommand = new CreateCommand(new Command.SportModeSettingsCommand());
    // map.set(this.SportModeSettings, SportModeSettingsCommand);
    //运动模式参数设置

    var setSportModeParametersCommand =
        CommandImpl(SendCMD.SetSportModeParameters);
    map[SendType.setSportModeParameters] = setSportModeParametersCommand;
    //ECG
    var setEcg = CommandImpl(SendCMD.Ecg);
    map[SendType.setEcg] = setEcg;

    //ECG AND PPG
    var setEcgAndPPG = CommandImpl(SendCMD.EcgAndPPG);
    map[SendType.setEcgAndPPG] = setEcgAndPPG;
    //血氧测量设置
    var OxSettingCommand = CommandImpl(SendCMD.OXSettings);
    map[SendType.oxSetting] = OxSettingCommand;

    //设备信息5
    var deviceInfo5Command = CommandImpl(SendCMD.DeviceInfo5);
    map[SendType.deviceInfo5] = deviceInfo5Command;

    //设置用户信息
    var setUserInfoCommand = CommandImpl(SendCMD.USER_INFO);
    map[SendType.userInfo] = setUserInfoCommand;

    //设置锻炼
    var setExerciseCommand = CommandImpl(SendCMD.SET_EXERCISE);
    map[SendType.setExercise] = setExerciseCommand;

    //新算法历史数据数量
    var newAlgorithmHistoricalNumCommand =
        CommandImpl(SendCMD.NEW_ALGORITHM_HISTORY_NUM);
    map[SendType.setNewAlgorithmHistoryNum] = newAlgorithmHistoricalNumCommand;
    //新算法历史数据
    var newAlgorithmHistoricalDataCommand =
        CommandImpl(SendCMD.NEW_ALGORITHM_HISTORY);
    map[SendType.setNewAlgorithmHistory] = newAlgorithmHistoricalDataCommand;

    //活动数据
    var activityDataCommand = CommandImpl(SendCMD.ACTIVE_DATA);
    map[SendType.setActiveData] = activityDataCommand;

    //清除新版历史数据
    var clearNewAlgorithmHistoricalDataCommand =
        CommandImpl(SendCMD.CLEAN_NEW_HISTORY);
    map[SendType.cleanNewHistoryData] = clearNewAlgorithmHistoricalDataCommand;

    //设置上报锻炼期间的活动数据
    var setExerciseActiveDataCommand =
        CommandImpl(SendCMD.SET_REPORTING_EXERCISE);
    map[SendType.setReportingExercise] = setExerciseActiveDataCommand;

    //设置测量时间
    var setMeasureTimeCommand = CommandImpl(SendCMD.SET_MEASUREMENT_TIMING);
    map[SendType.setMeasurementTiming] = setMeasureTimeCommand;

    //ppg设置
    var ppgCommand = CommandImpl(SendCMD.Ppg);
    map[SendType.setPpg] = ppgCommand;

    return map;
  }

  send(key, [data]) {
    if (SendType.historicalNum == key ||
        SendType.setNewAlgorithmHistoryNum == key) {
      data = {"isAll": true, "uuid": 0xFFFFFF};
    } else if (SendType.historicalData == key ||
        SendType.setNewAlgorithmHistory == key) {
      data = {"isAll": true, "uuid": Store.getMinUUID()};
    }
    // debugPrint(" key=${key} map[key]=${map[key]} data=${data}");
    return map[key].execute(data);
  }
}
