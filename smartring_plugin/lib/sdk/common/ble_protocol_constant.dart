const BLE_HEAD = 0xFE;
const BLE_TOTAL_LEN = 20;

class ReceiveType {
  static const Temperature = 0x01;
  static const HistoricalNum = 0x02;
  static const HistoricalData = 0x03;
  static const HistoricalData2 = 0x04;
  static const HistoricalData3 = 0x05;
  static const DeviceInfo1 = 0x06;
  static const DeviceInfo2 = 0x07;
  static const BatteryDataAndState = 0x08;
  static const RePackage = 0x09;
  static const Health = 0x0a;
  static const Step = 0x0b;
  static const OEMR1 = 0x0c;
  static const OEMResult = 0x0d;
  static const IRresouce = 0x0e;
  static const DeviceInfo5 = 0x0f;
  static const GreenOrIr = 0xBD;
  static const EcgRaw = 0x10;
  static const EcgAndPpg = 0x11;
  static const EcgAlgorithm = 0x12;
  static const EcgAlgorithmResult = 0x13;
  static const EcgFingerDetect = 0x14;
  static const USER_INFO_OR_SET_MEASUREMENT_TIMING_OR_PPG = 0X15;
  static const NEW_ALGORITHM_HISTORY = 0X16;
  static const NEW_ALGORITHM_HISTORY_NUM = 0X17;
  static const EXCLUDED_SWIMMING_ACTIVITY_HISTORY = 0X18;
  //static const  SWIMMING_ACTIVITY_HISTORY= 0X19;
  static const EXERCISE_ACTIVITY_HISTORY = 0X1a;
  static const SWIMMING_EXERCISE_HISTORY = 0X1b;
  static const SINGLE_LAP_SWIMMING_HISTORY = 0X1c;
  static const ACTIVE_DATA = 0X1d; //活动数据
  static const SLEEP_HISTORY = 0X1f;
  static const DAILY_ACTIVITY_HISTORY = 0X20;
  static const PPG_MEASUREMENT = 0X21;
  static const EXERCISE_VITAL_SIGNS_HISTORY = 0X22;
  static const GET_REPORTING_EXERCISE = 0X23;
  static const TEMPERATURE_HISTORY = 0X24;
  static const USER_INFO = 0X25;
  static const SET_MEASUREMENT_TIMING = 0X26;
  static const STEP_TEMPERATURE_ACTIVITY_INTENSITY_HISTORY = 0X27;
  static const PPG_SET = 0X28;
  static const PPG_DATA = 0X29;
}

enum SendType {
  step,
  timeSyn,
  openSingleHealth,
  closeSingleHealth,
  openHealth,
  closeHealth,
  temperature,
  shutDown,
  restart,
  restoreFactorySettings,
  historicalNum,
  historicalData,
  cleanHistoricalData,
  deviceInfo1,
  deviceInfo2,
  deviceInfo5,
  batteryDataAndState,
  deviceBind,
  deviceUnBind,
  setHrTime,
  setHealthPara,
  setSportModeParameters,
  switchOEM,
  startOEMVerify,
  startOEMVerifyR2,
  setAESkey,
  setAESIv,
  setEcg,
  oxSetting,
  setEcgAndPPG,
  userInfo,
  setExercise,
  setNewAlgorithmHistoryNum,
  setNewAlgorithmHistory,
  setMeasurementTiming,
  setActiveData,
  cleanNewHistoryData,
  setReportingExercise,
  setPpg
}

class SendCMD {
  static Map cmd = {
    "SportModeSettings": SportModeSettings,
    "TempHeartSettings": TempHeartSettings,
    "OXSettings": OXSettings,
    "TimeSyncSettings": TimeSyncSettings,
    "GetHealth": GetHealth,
    "Step": Step,
    "Temperature": Temperature,
    "ShutDown": ShutDown,
    "Restart": Restart,
    "RestoreFactorySettings": RestoreFactorySettings,
    "FactoryTest": FactoryTest,
    "HistoricalNum": HistoricalNum,
    "HistoricalData": HistoricalData,
    "CleanHistoricalData": CleanHistoricalData,
    "DeviceInfo1": DeviceInfo1,
    "DeviceInfo2": DeviceInfo2,
    "BatteryDataAndState": BatteryDataAndState,
    "OpenFlight": OpenFlight,
    "SetSOSpara": SetSOSpara,
    "WriteNum": WriteNum,
    "DeviceBindAndUnBind": DeviceBindAndUnBind,
    "SetHealthPara": SetHealthPara,
    "DeviceInfo3": DeviceInfo3,
    "DeviceInfo4": DeviceInfo4,
    "SwitchOem": SwitchOem,
    "SetSportModeParameters": SetSportModeParameters,
    "StartOemVerify": StartOemVerify,
    "StartOemVerifyR2": StartOemVerifyR2,
    "DeviceAuthorization": DeviceAuthorization,
    "DeviceFunSwitch": DeviceFunSwitch,
    "ADVPara": ADVPara,
    "LowBatteryThreshold": LowBatteryThreshold,
    "SetOemAesKey": SetOemAesKey,
    "SetOemAesIv": SetOemAesIv,
    "HeartRateTime": HeartRateTime,
    "DeviceInfo5": DeviceInfo5,
    "Ecg": Ecg,
    "EcgAndPPG": EcgAndPPG,
    "USER_INFO": USER_INFO,
    "SET_EXERCISE": SET_EXERCISE,
    "NEW_ALGORITHM_HISTORY_NUM": NEW_ALGORITHM_HISTORY_NUM,
    "NEW_ALGORITHM_HISTORY": NEW_ALGORITHM_HISTORY,
    "ACTIVE_DATA": ACTIVE_DATA,
    "CLEAN_NEW_HISTORY": CLEAN_NEW_HISTORY,
    "SET_REPORTING_EXERCISE": SET_REPORTING_EXERCISE,
    "SET_MEASUREMENT_TIMING": SET_MEASUREMENT_TIMING,
    "Ppg":Ppg
  };

  static const int SportModeSettings = 0x01;
  static const int TempHeartSettings = 0x02;
  static const int OXSettings = 0x03;
  static const int TimeSyncSettings = 0x04;
  static const int GetHealth = 0x05;
  static const int Step = 0x06;
  static const int Temperature = 0x07;
  static const int ShutDown = 0x08;
  static const int Restart = 0x09;
  static const int RestoreFactorySettings = 0x0a;
  static const int FactoryTest = 0x0b;
  static const int HistoricalNum = 0x0c;
  static const int HistoricalData = 0x0d;
  static const int CleanHistoricalData = 0x0e;
  static const int DeviceInfo1 = 0x0f;
  static const int DeviceInfo2 = 0x10;
  static const int BatteryDataAndState = 0x11;
  static const int OpenFlight = 0x12;
  static const int SetSOSpara = 0x13;
  static const int WriteNum = 0x14;
  static const int DeviceBindAndUnBind = 0x15;
  static const int SetHealthPara = 0x16;
  static const int DeviceInfo3 = 0x17;
  static const int DeviceInfo4 = 0x18;
  static const int SwitchOem = 0x19;
  static const int SetSportModeParameters = 0x20;
  static const int StartOemVerify = 0x1B;
  static const int StartOemVerifyR2 = 0x1C;
  static const int DeviceAuthorization = 0x30;
  static const int DeviceFunSwitch = 0x31;
  static const int ADVPara = 0x32;
  static const int LowBatteryThreshold = 0x33;
  static const int SetOemAesKey = 0x34;
  static const int SetOemAesIv = 0x35;
  static const int HeartRateTime = 0x3C;
  static const int DeviceInfo5 = 0x3D;
  static const int Ecg = 0x52;
  static const int EcgAndPPG = 0x53;
  static const int USER_INFO = 0x58; //用户信息
  static const int SET_EXERCISE = 0X59; //设置锻炼
  static const int NEW_ALGORITHM_HISTORY_NUM = 0X5A; //新算法历史数据数量
  static const int NEW_ALGORITHM_HISTORY = 0X5B; //新算法历史数据
  static const int ACTIVE_DATA = 0X5C; //活动数据
  static const int CLEAN_NEW_HISTORY = 0X5E; //清除新版历史数据
  static const int SET_REPORTING_EXERCISE = 0X5F; //设置上报锻炼期间的活动数据
  static const int SET_MEASUREMENT_TIMING = 0X60; //设置测量时间
  static const int Ppg = 0x63; //PPG测量
}

//接收数据的CMD
const ReceiveCMD = {
  "Repackage": 0x80,
  "HistoricalNum": 0x81,
  "HistoricalData": 0x82,
  "GetHealth": 0x83,
  "Step": 0x84,
  "Temperature": 0x85,
  "BatteryData": 0x86,
  "DeviceInfo1": 0x87,
  "DeviceInfo2": 0x88,
  "OEMR1": 0x8D,
  "OEMResult": 0x8E,
  "DeviceInfo5": 0x8F,
  "HistoricalData2": 0x91,
  "HistoricalData3": 0x92,
  "EcgRaw": 0x94,
  "EcgAndPpg": 0x95,
  "EcgAlgorithm": 0x96,
  "EcgAlgorithmResult": 0x97,
  "EcgFingerDetect": 0x98,
  // TriggerSOS:0x89,
  // SOSInfo:0x8A,
  // DeviceInfo3:0x8B,
  "IRresouce": 0xBB,
  "RedLight": 0xBC,
  "GreenOrIr": 0xBD, //红外红光/两路绿光源数据上报
  "USER_INFO_OR_SET_MEASUREMENT_TIMING_OR_PPG": 0XC0,
  "NEW_ALGORITHM_HISTORY": 0XC1,
  "NEW_ALGORITHM_HISTORY_NUM": 0XC2,
  "EXCLUDED_SWIMMING_ACTIVITY_HISTORY": 0XC3,
  // SWIMMING_ACTIVITY_HISTORY: 0XC4,
  "EXERCISE_ACTIVITY_HISTORY": 0XC5,
  "SWIMMING_EXERCISE_HISTORY": 0XC6,
  "SINGLE_LAP_SWIMMING_HISTORY": 0XC7,
  "ACTIVE_DATA": 0XC8, //活动数据
  "SLEEP_HISTORY": 0XC9,
  "DAILY_ACTIVITY_HISTORY": 0XCA,
  "PPG_MEASUREMENT": 0XCB,
  "EXERCISE_VITAL_SIGNS_HISTORY": 0XCC,
  "GET_REPORTING_EXERCISE": 0XCD,
  "TEMPERATURE_HISTORY": 0XCE,
  "STEP_TEMPERATURE_ACTIVITY_INTENSITY_HISTORY":0XD1,
  "PPG_DATA":0XD0,
};

const handlerType = {
  "Temperature": ReceiveType.Temperature,
  "HistoricalNum": ReceiveType.HistoricalNum,
  "HistoricalData": ReceiveType.HistoricalData,
  "HistoricalData2": ReceiveType.HistoricalData2,
  "HistoricalData3": ReceiveType.HistoricalData3,
  "DeviceInfo1": ReceiveType.DeviceInfo1,
  "DeviceInfo2": ReceiveType.DeviceInfo2,
  "DeviceInfo5": ReceiveType.DeviceInfo5,
  "BatteryDataAndState": ReceiveType.BatteryDataAndState,
  "RePackage": ReceiveType.RePackage,
  "Health": ReceiveType.Health,
  "Step": ReceiveType.Step,
  "OEMR1": ReceiveType.OEMR1,
  "OEMResult": ReceiveType.OEMResult,
  "IRresouce": ReceiveType.IRresouce,
  "GreenOrIr": ReceiveType.GreenOrIr,
  "EcgRaw": ReceiveType.EcgRaw,
  "EcgAndPpg": ReceiveType.EcgAndPpg,
  "EcgAlgorithm": ReceiveType.EcgAlgorithm,
  "EcgAlgorithmResult": ReceiveType.EcgAlgorithmResult,
  "EcgFingerDetect": ReceiveType.EcgFingerDetect,
  "USER_INFO_OR_SET_MEASUREMENT_TIMING_OR_PPG": ReceiveType.USER_INFO_OR_SET_MEASUREMENT_TIMING_OR_PPG,
  "NEW_ALGORITHM_HISTORY": ReceiveType.NEW_ALGORITHM_HISTORY,
  "NEW_ALGORITHM_HISTORY_NUM": ReceiveType.NEW_ALGORITHM_HISTORY_NUM,
  "EXCLUDED_SWIMMING_ACTIVITY_HISTORY": ReceiveType.EXCLUDED_SWIMMING_ACTIVITY_HISTORY,
  "EXERCISE_ACTIVITY_HISTORY": ReceiveType.EXERCISE_ACTIVITY_HISTORY,
  "SWIMMING_EXERCISE_HISTORY": ReceiveType.SWIMMING_EXERCISE_HISTORY,
  "SINGLE_LAP_SWIMMING_HISTORY": ReceiveType.SINGLE_LAP_SWIMMING_HISTORY,
  "ACTIVE_DATA": ReceiveType.ACTIVE_DATA,
  "SLEEP_HISTORY": ReceiveType.SLEEP_HISTORY,
  "DAILY_ACTIVITY_HISTORY": ReceiveType.DAILY_ACTIVITY_HISTORY,
  "PPG_MEASUREMENT": ReceiveType.PPG_MEASUREMENT,
  "EXERCISE_VITAL_SIGNS_HISTORY": ReceiveType.EXERCISE_VITAL_SIGNS_HISTORY,
  "GET_REPORTING_EXERCISE": ReceiveType.GET_REPORTING_EXERCISE,
  "TEMPERATURE_HISTORY": ReceiveType.TEMPERATURE_HISTORY,
  "STEP_TEMPERATURE_ACTIVITY_INTENSITY_HISTORY":ReceiveType.STEP_TEMPERATURE_ACTIVITY_INTENSITY_HISTORY,
  "PPG_SET":ReceiveType.PPG_SET,
  "PPG_DATA":ReceiveType.PPG_DATA,
};

class ECG_PPG_SAMPLE_RATE {
  // static const int ECG_PPG_SAMPLE_RATE_2048 = 1;
  static const int ECG_PPG_SAMPLE_RATE_1024 = 2;
  static const int ECG_PPG_SAMPLE_RATE_512 = 3;
  // static const int ECG_PPG_SAMPLE_RATE_256 = 4;
  // static const int ECG_PPG_SAMPLE_RATE_128 = 5;
  // static const int ECG_PPG_SAMPLE_RATE_64 = 6;
}

enum ClockFrequency {
  option0(0),
  option1(1);

  final int value;
  const ClockFrequency(this.value);
}

final Map<ClockFrequency, List<double>> _frequencyToSamplingRates = {
  ClockFrequency.option0: [64, 128, 256, 512, 1024, 2048],
  ClockFrequency.option1: [62.5, 125, 250, 500, 1000, 2000],
};

List<double> getSamplingRatesFor(ClockFrequency frequency) {
  return _frequencyToSamplingRates[frequency] ?? [];
}

class EcgCheckResult {
  static const int INCOMPLETE_NO_RESULT = 0;
  static const int COMPLETE_NO_ABNORMALITY = 1;
  static const int INSUFFICIENT_DATA = 2;
  static const int BRADYCARDIA_DETECTED = 3;
  static const int ATRIAL_FIBRILLATION_DETECTED = 4;
  static const int TACHYCARDIA_DETECTED = 5;
  static const int ABNORMALITY_DETECTED_UNSPECIFIED = 6;
}

class EcgSignalQuality {
  static const int NOT_CONNECTED = 0;
  static const int POOR_SIGNAL_QUALITY = 1;
  static const int SIGNAL_WITH_NOISY_HEARTBEAT = 2;
  static const int CLEAR_SIGNAL = 3;
}

const ecgUnreadable_reasons = 1;
