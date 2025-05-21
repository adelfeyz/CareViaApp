import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:smartring_flutter/src/controller/blood_glucose_controller.dart';
import 'package:smartring_flutter/src/hive/db/pressure_db.dart';
import 'package:smartring_flutter/src/testJSON.dart';
import 'package:smartring_flutter/src/util/timeUtil.dart';
import 'package:smartring_plugin/smartring_plugin.dart' as smartring_plugin;
import 'package:smartring_plugin/sdk/common/ble_protocol_constant.dart';
import 'package:smartring_plugin/sdk/core.dart';
import 'package:smartring_plugin/sdk/utils/LogUtil.dart';
import '../util/commonUtil.dart';
// import '../../sdk/common/ble_protocol_constant.dart';
// import '../../sdk/core.dart';
// import '../../sdk/utils/LogUtil.dart';
import '../bluetooth/bluetooth_manager.dart';
import '../common/constant.dart';
import '../hive/db/history_db.dart';
import '../hive/model/history_model.dart';
import '../http/httpManager.dart';
import '../model/health_model.dart';
import '../util/fileUtils.dart';
import 'dart:convert';

class BleData {
  HttpManager httpManager = HttpManager.getInstance();

  //health
  RxString oxValue = "".obs;
  RxString heartValue = "".obs;
  RxString hrvValue = "".obs;
  //battery
  var batteryValue = 0.obs;
  var batteryState = "".obs;
  var batteryPer = 0.obs;
  //deviceInfo1
  var devColor = "".obs;
  var devSize = 0.obs;
  var devAddress = "".obs;
  var devVersion = "".obs;
  var switchOem = false.obs;
  var chargingMode = 0.obs;
  var mainChipModel = "".obs;
  var productIteration = "".obs;
  var hasSportsMode = false.obs;
  var isSupportEcg = false.obs;
  var deviceType = 0.obs;
  //deviceInfo2
  var sn = "".obs;
  var bindStatus = "".obs;
  var samplingRate = 0.obs;
  //deviceInfo5
  var hrMeasurementTime = 0.obs;
  var oxMeasurementInterval = 0.obs;
  var oxMeasurementSwitch = 0.obs;

  //history
  final int MINUTE = 60 * 1000;
  final int HOUR = 60 * 60 * 1000;

  var historyUUIDList = [];

  List<Map> historyRawDataArray = [];
  List historyDataArray = [];
  List hrArray = [];
  List sleepArray = [];
  var historyStart = "".obs;
  List sleepTimePeriodArray = [];
  List sleepTimeArray = [];
  var sleepAnalysis = "".obs;
  var newSleepAnalysis = "".obs;
  var restingHeartRate = "".obs;
  var respiratoryRate = "".obs;
  var oxSaturation = "".obs;
  var hrImmersion = "".obs;
  //historyNum
  var endUUID = 0.obs;
  var startUUID = 0.obs;
  var numUUID = 0.obs;

  //step
  var sportStart = false;
  var stepCount = 0.obs;
  var stepAlgorithm = "".obs;

  var personalHeight = null;
  var calories = 0.0.obs;
  var strengthGrade = 0.obs;

  //oem
  var oemResult = "".obs;
  var isStartOem = false;

  //shutdown
  var shutdownRes = "".obs;

  //restart
  var restartRes = "".obs;

  //factoryReset
  var factoryResetRes = "".obs;

  //cleanHistorical
  var cleanHistoricalRes = "".obs;

  //timeSync
  var timeSyncRes = "".obs;

  //clean new history
  var cleanNewHistoryRes = "".obs;

  //deviceBind&unBind
  var deviceIsBind = false.obs;

  //deviceBindRes
  var deviceBindRes = "".obs;

  //deviceUnBindRes
  var deviceUnBindRes = "".obs;

  //stepRes
  var stepRes = "".obs;

  //Progress
  var progressVisit = false.obs;
  var progressValue = 0.0.obs;

  //Temperature
  var temperatureRes = "".obs;

  //empty
  var empty = "".obs;

  //sport
  Map sportValue = {
    "height": 0.obs,
    "timeInterval": 0.obs,
    "duration": 0.obs,
    "sportMode": 0.obs,
    "mode": 0.obs,
    "strengthGrade": 0.05.obs,
  };

  //user info
  Map userHealthInfo = {
    "height": 0.obs,
    "weight": 0.obs,
    "age": 0.obs,
    "family_history": 0.obs,
    "high_cholesterol": 0.obs,
    "sex": "".obs,
  };

  //user info
  Map userInfo = {
    "height": 0.obs,
    "weight": 0.obs,
    "age": 0.obs,
    "function": 0.obs,
    "sex": 0.obs,
  };

  //measure timing
  Map measureTiming = {
    "function": 0.obs,
    "type": 0.obs,
    "time1": 0.obs,
    "time1Interval": 0.obs,
    "time2": 0.obs,
    "time2Interval": 0.obs,
  };

  Map measureTimingValue = {}.obs;

  //measure timing
  Map exercise = {
    "function": 0.obs,
    "type": 0.obs,
    "poolSize": 0.obs,
    "exerciseTime": 0.obs,
  };

  //report exercise
  var reportSwitch = false.obs;

  //hr measurement settings
  Map hrMeasurementSettingValue = {
    "switch": 0.obs,
    // "startTime": [].obs,
    // "endTime": [].obs,
    "timeInterval": 0.obs,
    "disable": true.obs
  };

  //user info
  Map userInfoValue = {}.obs;

  //active data
  var activeData = "".obs;
  //report_exercise
  var reporting_exercise = "".obs;
  //repack
  var repackage = "".obs;

  //ecg
  List<int> waveRawData = [];
  List<int> waveData = [];
  bool dataCollectionStart = false;
  List<int> ecgDataBuffer = [];
  RxString ecgResponse = "".obs;
  bool enoughDate = false;
  var ecgUpdate = false.obs;
  var maxRR = 0;
  var minRR = 0;
  var hr = 0;
  var hrv = 0;
  var mood = 0;
  var respiratoryRateV = 0;
  var isTouch = false;
  var outEcgValue = "".obs;
  var ecgAlgorithmResult = "".obs;
  var noData = "".obs;
  var currentEcgMode = 0.obs;

  //temperature
  var ftcW = 0.0.obs;
  var ftcBase = 0.0.obs;
  var tempArr = <Map<String, dynamic>>[].obs;
  //pressure
  var stressDays = "".obs;

  List<HistoryDb> historyDbArray = [];
  RxMap<int, List<Map<String, dynamic>>> pressureArray =
      <int, List<Map<String, dynamic>>>{}.obs;
  var recoveryTime = "".obs;
  var stressTime = "".obs;
  RxList<Map<String, dynamic>> motionArray = <Map<String, dynamic>>[].obs;
  RxDouble pressureBaseLine = 0.0.obs;

  //irWave
  List<int> waveList = [];
  List<int> irWaveList = [];
  List<int> redWaveList = [];
  RxBool update = false.obs;

  //SR28
  var newHistoryShow = false.obs;
  var newAlgorithmHistory = <String>[].obs;
  var newHistoryProcess = "".obs;
  var ppgSwitch = false.obs;
  List<int> ppgDataList = [];
  List<Map<String, dynamic>> ppgData = [];
  String startTime = "";
  String endTime = "";
  RxString registerResult = "".obs;
  RxString uploadResult = "".obs;
  RxString ppgMeasureResult = "".obs;
  DateTime currentTime = DateTime.now();
  int historyCount = 0;
  List newHistoryData = [];
  List temperatureHistoryData = [];
  List excludedSwimmingActivityHistoryData = [];
  List dailyActivityHistoryData = [];
  List exerciseActivityHistoryData = [];
  List exerciseVitalSignsHistoryData = [];
  List swimmingExerciseHistoryData = [];
  List singleLapSwimmingHistoryData = [];
  List stepTemperatureActivityIntensityHistoryData = [];
  List sleepHistoryData = [];
  List newAlgorithmHistoryData = [];

  //bluetooth
  late RingManager ringManager;
  late BlueToothManager blueToothManager;
  late HealthModel healthModel;
  late HistoryModel historyModel;

  Future futureCancle = Future.value();

  //blood pressure
  static final BleData _instance = BleData._internal();

  //TextEditingController
  final TextEditingController hrMeasureTimeController = TextEditingController();
  int hrMeasureTime = 0;
  var channel =
      const BasicMessageChannel('ecgMessageChannel', StandardMessageCodec());

  BloodGlucoseController? bloodGlucoseController;

  factory BleData() {
    return _instance;
  }

  BleData._internal();

  historyListener(Map data) {
    debugPrint("historyListener data=$data");
    if (data.isNotEmpty) {
      var uuid = data['uuid'];
      if (uuid != endUUID.value) {
        historyStart.value = "Getting data started";
        double process = (uuid - startUUID.value) / numUUID.value;
        progressValue.value = process;
        historyRawDataArray.add(data);
      } else {
        historyRawDataArray.add(data);
        historyStart.value = "Finish";
        progressVisit.value = false;
        dealHistoryData(data['historyArray']);
      }
    }
  }

  void test() async {
    List<dynamic> data = await loadAndDecodeJson('assets/20240725.json');
    for (int i = 0; i < data.length; i++) {
      var item = data[i];
      if (item["heartRate"] >= 50 &&
          item["heartRate"] <= 175 &&
          item["wearStatus"] == 1 &&
          item["chargeStatus"] == 0) {
        sleepArray.add({
          "ts": item["timeStamp"],
          "hr": item["heartRate"],
          "hrv": item["hrv"],
          "motion": item["motionDetectionCount"],
          "steps": item["step"],
          "ox": item["ox"]
        });
      }
    }
    String result = await encodeListToJson(sleepArray);
    saveJsonDataToFile(result);
    debugPrint(
        "sleepArray length=${sleepArray.length} sleepArray=$sleepArray ");
  }

  void test1() async {
    List<dynamic> data =
        await loadAndDecodeJson('assets/wm_dump_06-11-2024-08-43.json');
    for (int i = 0; i < data.length; i++) {
      var item = data[i];
      if (item["heartRate"] >= 50 &&
          item["heartRate"] <= 175 &&
          item["wearStatus"] == 1 &&
          item["chargeStatus"] == 0) {
        sleepArray.add({
          "ts": item["timeStamp"],
          "hr": item["heartRate"],
          "hrv": item["hrv"],
          "motion": item["motionDetectionCount"],
          "steps": item["step"],
          "ox": item["ox"]
        });
      }
    }
    String result = await encodeListToJson(sleepArray);
    saveJsonDataToFile(result);
    debugPrint(
        "sleepArray length=${sleepArray.length} sleepArray=$sleepArray ");
  }

  void loadJsonToDB() async {
    LogUtil.init(title: "来自LogUtil", isDebug: true, limitLength: 800);
    List<dynamic> data = await loadAndDecodeJson('assets/20240725.json');
    LogUtil.d("data.length = ${data.length}");
    List<HistoryDb> historyDbArray = [];
    for (var i = 0; i < data.length; i++) {
      // data[i]["timeStamp"];
      LogUtil.d(
          "timeStamp = ${data[i]["timeStamp"]} heartRate=${data[i]["heartRate"]} motionDetectionCount=${data[i]["motionDetectionCount"]} detectionMode=${data[i]["detectionMode"]} wearStatus=${data[i]["wearStatus"]} chargeStatus=${data[i]["chargeStatus"]} uuid=${data[i]["uuid"]} hrv=${data[i]["hrv"]} temperature=${data[i]["temperature"]} step=${data[i]["step"]} ox=${data[i]["ox"]} rawHr=${data[i]["rawHr"]} sportsMode=${data[i]["sportsMode"]} respiratoryRate=${data[i]["respiratoryRate"]}");
      historyDbArray.add(HistoryDb(
          timeStamp: data[i]["timeStamp"],
          heartRate: data[i]["heartRate"],
          motionDetectionCount: data[i]["motionDetectionCount"],
          detectionMode: data[i]["detectionMode"],
          wearStatus: data[i]["wearStatus"],
          chargeStatus: data[i]["chargeStatus"],
          uuid: data[i]["uuid"],
          hrv: data[i]["hrv"],
          temperature: data[i]["temperature"],
          step: data[i]["step"],
          ox: data[i]["ox"],
          rawHr: data[i]["rawHr"],
          sportsMode: data[i]["sportsMode"],
          respiratoryRate: data[i]["respiratoryRate"]));
    }
    await historyModel.addAllHistory(historyDbArray);
    // debugPrint(
    //     "主界面处理的睡眠数据 length=${sleepArray.length} sleepArray=$sleepArray ");
    await healthModel.storeSleepData();
  }

  Future<void> registerDevice() async {
    if (sn.value.isEmpty) {
      sendBle(SendType.deviceInfo2);
      await Future.delayed(const Duration(seconds: 1));
    }
    await bloodGlucoseController
        ?.registerDevice(
            sn: sn.value,
            age: userHealthInfo["age"].value,
            gender: userHealthInfo["sex"].value,
            height: userHealthInfo["height"].value,
            weight: userHealthInfo["weight"].value,
            familyHistory: userHealthInfo["family_history"].value,
            highCholesterol: userHealthInfo["high_cholesterol"].value)
        .then((value) => registerResult.value = value);
  }

  void init() async {
    healthModel = HealthModel();
    historyModel = healthModel.getHistoryModel();
    bloodGlucoseController = Get.find<BloodGlucoseController>();
    test();
    // test1();

    // httpManager.downloadOtaFile(model: RingModel.sr09n_t);

    // dealHistoryData1(data);
    // LogUtil.d("data = $data");
    // String result=await encodeListToJson(reData);
    // LogUtil.d("result = $result");
    // List<int> list = [100, -80, 601];
    // channel.send(Int8List.fromList(list));
    /**
     * ECG callback data
     */

    // shareFile();
    // saveFile(DateTime.now());
    // saveSleepDataFile();
    // saveHistoryDataFile();
    channel.setMessageHandler((message) {
      // debugPrint("message=$message type=${message.runtimeType}");
      if (message is Map) {
        // debugPrint("type=${message["type"]}");
        switch (message["type"]) {
          case "wave":
            waveRawData.add(message["data"] as int);
            if (waveRawData.length > 2200) {
              waveRawData.removeAt(0);
            }
            ecgUpdate.value = !ecgUpdate.value;
            break;
          case "HR":
            hr = message["value"];
            break;
          case "Mood Index":
            if (hrv != 0 && currentEcgMode.value != 2) {
              stopEcg();
            }
            mood = message["value"];
            break;
          case "RR":
            if (message["value"] > maxRR) {
              maxRR = message["value"];
            } else if (message["value"] < minRR && message["value"] > 300) {
              minRR = message["value"];
            } else if (minRR == 0 && message["value"] > 300) {
              minRR = message["value"];
            }
            break;
          case "HRV":
            if (mood != 0 && currentEcgMode.value != 2) {
              stopEcg();
            }
            hrv = message["value"];
            break;
          case "RESPIRATORY RATE":
            respiratoryRateV = message["value"];
            break;
        }
      }
      outEcgValue.value =
          "hr=$hr hrv=$hrv  mood=$mood  respiratoryRate=$respiratoryRateV minRR=$minRR maxRR=$maxRR";
      return Future(() => null);
    });
    ringManager = RingManager.instance;
    blueToothManager = BlueToothManager();
    blueToothManager.requestMtu(43);
    /**
     * Ring return data listening function
     */
    blueToothManager.notifityWriteListener(NOTIFY_UUID,
        (data, characteristic) async {
      // debugPrint("===============notifityWriteListener data=${data} dateType=${data.runtimeType}");
      ringManager.receiveData(data);
    }, onError: (error) {
      debugPrint("notifityWriteListener error=$error");
    });

    /**
     * Registration functions for callback interfaces of ecgRawData
     */
    ringManager.registerProcess(ReceiveType.EcgRaw, (data) async {
      if (isTouch) {
        if (!dataCollectionStart) {
          dataCollectionStart = true; // 初始化开始时间
          ecgDataBuffer = []; // 清空缓冲区
          enoughDate = false; // 标记数据是否足够绘制图表
        }
        if (ecgDataBuffer.length > 20000 && !enoughDate) {
          enoughDate = true;
          stopEcg();
        } else {
          ecgDataBuffer.addAll(data['ecgList']
              .map<int>((int item) => ringManager.convertToVoltage(item)));
        }
        await channel.send(data['ecgList']);
      } else {
        dataCollectionStart = false;
        enoughDate = false;
        ecgDataBuffer = [];
      }
    });

    /**
     * Registration functions for callback interfaces of EcgAlgorithm
     */
    ringManager.registerProcess(ReceiveType.EcgAlgorithm, (data) async {
      // debugPrint("===============EcgAlgorithm data=$data");
      if (isTouch) {
        waveData.addAll(data['ecgList']);
        if (waveData.length > 2200) {
          waveData.removeAt(0);
        }
        ecgUpdate.value = !ecgUpdate.value;
      }
    });

    ringManager.registerProcess(ReceiveType.EcgFingerDetect, (data) async {
      isTouch = data['fingerDetect'] == 1;
      if (!isTouch) {
        showToast(" your fingers not touch the device");
      }
    });

    /**
     * Registration functions for callback interfaces of EcgAlgorithmResult
     */
    ringManager.registerProcess(ReceiveType.EcgAlgorithmResult, (data) async {
      // debugPrint("===============EcgAlgorithmResult data=$data");
      String checkResult = "";
      switch (data["resultOfArrhythmia"]) {
        case EcgCheckResult.INCOMPLETE_NO_RESULT:
          checkResult = "Arrhythmic examination not completed with no results.";
          break;
        case EcgCheckResult.COMPLETE_NO_ABNORMALITY:
          checkResult =
              "Arrhythmic examination completed, no abnormal events found. ";
          break;
        case EcgCheckResult.INSUFFICIENT_DATA:
          if (data["low_amplitude"]) {
            checkResult =
                "The amplitude of the electrocardiogram is very low, please make sure the contact surface is clean, and then try again. ";
          } else if (data["significant_noise"]) {
            checkResult =
                "There is obvious noise in the electrocardiogram signal, please make sure the device is not held too tightly, and then try again. ";
          } else if (data["unstable_signal"]) {
            checkResult =
                "The electrocardiogram signal is unstable, please keep it still, and then try again. ";
          } else if (data["not_enough_data"]) {
            checkResult =
                "There is not enough data, please make sure you keep it still, and then try again";
          }
          break;
        case EcgCheckResult.BRADYCARDIA_DETECTED:
          checkResult =
              "Arrhythmic examination completed and bradycardia detected.";
          break;
        case EcgCheckResult.ATRIAL_FIBRILLATION_DETECTED:
          checkResult =
              "Arrhythmia detection completed, atrial fibrillation detected.";
          break;
        case EcgCheckResult.TACHYCARDIA_DETECTED:
          checkResult =
              "Arrhythmic examination completed, detected tachycardia. ";
          break;
        case EcgCheckResult.ABNORMALITY_DETECTED_UNSPECIFIED:
          checkResult =
              "Arrhythmic examination completed, with abnormalities. However, bradycardia, atrial fibrillation, and tachycardia cannot be confirmed";
          break;
      }
      String signalResult = "";
      switch (data["signalQuality"]) {
        case EcgSignalQuality.NOT_CONNECTED:
          signalResult =
              "This status indicates that the electrocardiogram signal is not present. The user is not connected to the ECG device.";
          break;
        case EcgSignalQuality.POOR_SIGNAL_QUALITY:
          signalResult =
              "This status indicates that the user is connected to the electrocardiogram device, but the electrocardiogram signal quality is poor and the heartbeat cannot be determined. This can" +
                  "It can be due to excessive noise on the electrocardiogram signal. No electrocardiogram algorithm can operate at this level of signal quality Okay.";
          break;
        case EcgSignalQuality.SIGNAL_WITH_NOISY_HEARTBEAT:
          signalResult =
              "This state indicates that the heartbeat can be determined in the electrocardiogram signal, but a large amount of noise has been detected in the signal. In this kind of" +
                  "User verification/identification cannot be performed at signal quality levels.";
          break;
        case EcgSignalQuality.CLEAR_SIGNAL:
          signalResult =
              "This state indicates that the heartbeat can be determined in the electrocardiogram signal, and the signal is clear enough without noise interference, suitable for" +
                  "Run all electrocardiogram algorithms.";
          break;
        default:
          break;
      }
      String connectResult = data["present"] == 1
          ? "User connected to electrocardiogram device"
          : "The user is not connected to the electrocardiogram device";
      String alive = data["alive"] == 1
          ? "User heartbeat detected"
          : "No user heartbeat detected";
      var avg_hr = data["avg_hr"];
      ecgAlgorithmResult.value =
          'heartRate=${data["heartRate"]}  checkResult=$checkResult \n rmssd=${data["rmssd"]} sdnn=${data["sdnn"]}  pressureIndex=${data["pressureIndex"]}'
          'bmr=${data["bmr"]} active_cal=${data["active_cal"]}  signalQuality=$signalResult  present=$connectResult  alive=$alive avg_hr=$avg_hr';
    });
    /**
     * Registration functions for callback interfaces of blood oxygen, electrocardiogram, and hrv
     */
    ringManager.registerProcess(ReceiveType.Health, (data) {
      if (data["oxValue"] != 25) {
        oxValue.value = data["oxValue"].toString();
      }
      heartValue.value = data["heartValue"].toString();
      hrvValue.value = data["hrvValue"].toString();
    });
    /**
     * Registration function for callback interface of battery data
     */
    ringManager.registerProcess(ReceiveType.BatteryDataAndState, (Map data) {
      if (data.isNotEmpty) {
        var isWireless = false;
        String bleName = blueToothManager.getDeviceName();
        if (bleName.isNotEmpty) {
          isWireless = !bleName.toUpperCase().contains('W') ? false : true;
        }
        var charging = data["status"] == 1;
        var result = charging ? "charging" : "uncharged";
        var battery_per = 0;
        if (data["batteryPer"] != null) {
          battery_per = data["batteryPer"];
        } else {
          battery_per = smartring_plugin.toBatteryLevel(
              data["batteryValue"], charging, isWireless);
        }
        batteryValue.value = data["batteryValue"];
        batteryState.value = result;
        batteryPer.value = battery_per;
      }
    });
    /**
     * Callback interface registration function for device information 1
     * Black 0x00, Silver 0x01, Gold 0x02, Rose Gold 0x03, Gold/Silver Mix 0x04, Purple/
     * Silver Mix Color 0x05, Rose Gold/Silver Mix Color 0x06, Brushed Silver 0x07, Black Matte 0x08
     */
    ringManager.registerProcess(ReceiveType.DeviceInfo1, (Map data) {
      if (data.isNotEmpty) {
        var color = "";
        if (data["color"] == 0) {
          color = "Deep Black";
        } else if (data["color"] == 1) {
          color = "Silver";
        } else if (data["color"] == 2) {
          color = "Gold";
        } else if (data["color"] == 3) {
          color = "Rose Gold";
        } else if (data["color"] == 4) {
          color = "Gold/Silver Mix";
        } else if (data["color"] == 5) {
          color = "Purple/Silver Mix Color";
        } else if (data["color"] == 6) {
          color = "Rose Gold/Silver Mix Color";
        } else if (data["color"] == 7) {
          color = "Brushed Silver";
        } else if (data["color"] == 8) {
          color = "Black Matte";
        }
        devColor.value = color;
        devSize.value = data["size"];
        devAddress.value = data["bleAddress"];
        devVersion.value = data["deviceVer"];
        switchOem.value = data["switchOem"];
        chargingMode.value = data["chargingMode"];
        mainChipModel.value = data["mainChipModel"];
        productIteration.value = data["productIteration"];
        hasSportsMode.value = data["hasSportsMode"];
        isSupportEcg.value = data["isSupportEcg"];
        deviceType.value = data["deviceType"];
        //deviceType:
        //0x10 : SR03
        //0x20 : SR09W 无线充电
        //0x21 : SR09N NFC充电
        //0x30 : SR23 NFC充电
        //0x40 : SR26
        debugPrint(
            "====== switchOem.value=${switchOem.value} isStartOem=$isStartOem =================");

        ///Only after the oem switch is turned on can oem certification be carried out
        if (switchOem.value && isStartOem) {
          isStartOem = false;
          oemVerify();
        }
        if (!isStartOem) {}
      }
    });
    /**
     * Callback interface registration function for device information 2
     */
    ringManager.registerProcess(ReceiveType.DeviceInfo2, (Map data) {
      if (data.isNotEmpty) {
        sn.value = data["sn"];
        bindStatus.value = data["bindStatus"];
        samplingRate.value = data["samplingRate"];
      }
    });
    ringManager.registerProcess(ReceiveType.DeviceInfo5, (Map data) {
      if (data.isNotEmpty) {
        hrMeasurementTime.value = data["hrMeasurementTime"];
        oxMeasurementInterval.value = data["oxMeasurementInterval"];
        oxMeasurementSwitch.value = data["oxMeasurementSwitch"];
      }
    });

    /**
     * Callback interface registration function for historical data
     */
    ringManager.registerProcess(ReceiveType.HistoricalData, historyListener);
    /**
     * Callback interface registration function for the number of historical data entries
     * When there is no historical data, numUUID=0 and ringManager.registerProcess(ReceiveType.HistoricalData,(data){}） no data will be returned
     */
    ringManager.registerProcess(ReceiveType.HistoricalNum, (Map data) {
      debugPrint('HistoricalNum data$data');
      if (data.isNotEmpty) {
        endUUID.value = data["maxUUID"];
        startUUID.value = data["minUUID"];
        numUUID.value = data["num"];
      }
    });
    /**
     * Callback interface registration function for OEM authentication results
     */
    ringManager.registerProcess(ReceiveType.OEMResult, (data) {
      oemResult.value = data ? "Verification successful" : "Verification fail";
    });
    /**
     * Callback interface registration function for finger temperature
     */
    ringManager.registerProcess(ReceiveType.Temperature, (data) {
      if (data.isNotEmpty) {
        temperatureRes.value = " Temperature :$data";
      }
    });
    /**
     * All Bluetooth commands sent, callback interface registration function for sending results, success or failure, and reasons for failure
     */
    ringManager.registerProcess(ReceiveType.RePackage, (data) {
      debugPrint(
          "cmd=${data['cmd']}  result=${data['result']}  reason=${data['reason']} ");
      repackage.value =
          "cmd:${data['cmd']} result:${data['result']} reason:${data['reason']} ";
    });

    /**
     * All Bluetooth commands sent, callback interface registration function for sending results, success or failure
     */
    ringManager.registerProcess(ReceiveType.RePackage, (data) {
      var result = data["result"];
      switch (data["cmd"]) {
        case SendCMD.DeviceBindAndUnBind:
          String title =
              deviceIsBind.value ? "Device binded" : "Device unbinded";
          String status = title + result;
          if (deviceIsBind.value) {
            deviceBindRes.value = status;
          } else {
            deviceUnBindRes.value = status;
          }
          break;
        case SendCMD.ShutDown:
          shutdownRes.value = "Shutdown $result";
          break;
        case SendCMD.Restart:
          restartRes.value = "Restart $result";
          break;
        case SendCMD.RestoreFactorySettings:
          // debugPrint(
          //     " ===========设备应答=========RestoreFactorySettings======================= $result");
          factoryResetRes.value = "FactoryReset $result";
          break;
        case SendCMD.CleanHistoricalData:
          cleanHistoricalRes.value = "Clear Historical Data $result";
          break;
        case SendCMD.TimeSyncSettings:
          timeSyncRes.value = "Time synchronization $result";
          break;
        case SendCMD.CLEAN_NEW_HISTORY:
          cleanNewHistoryRes.value = "Clear New History $result";
          break;
      }
    });
    /**
     * Receive PPG data callback interface registration function 
     */
    ringManager.registerProcess(ReceiveType.IRresouce, (data) {
      irWaveList.addAll(data);
      update.value = !update.value;
      if (irWaveList.length > 600) {
        irWaveList.removeRange(0, 8);
      }
    });

    ringManager.registerProcess(ReceiveType.GreenOrIr, (data) {
      irWaveList.addAll(data["irOrGreen"]);
      redWaveList.addAll(data["redOrGreen"]);
      update.value = !update.value;
      if (irWaveList.length > 600) {
        irWaveList.removeRange(0, 8);
      }
      if (redWaveList.length > 600) {
        redWaveList.removeRange(0, 8);
      }
    });

    hrMeasureTimeController.addListener(() {
      if (hrMeasureTimeController.text.isNumericOnly) {
        hrMeasureTime = int.parse(hrMeasureTimeController.text);
      }
    });

    //获取ppg数据
    ringManager.registerProcess(ReceiveType.EcgAndPpg, (data) {});

    ///////////////////////SR28 start//////////////////////////////////////
    newHistoryReceiveFinish() {
      List<String> array = [];
      final newHistoryDataString = newHistoryData.join('\n');
      final resultTemperatureString = temperatureHistoryData.join('\n');
      final resultExcludedSwimmingActivityString =
          excludedSwimmingActivityHistoryData.join('\n');
      final resultDailyActivityString = dailyActivityHistoryData.join('\n');
      final resultExerciseActivityString =
          exerciseActivityHistoryData.join('\n');
      final resultExerciseVitalSignsString =
          exerciseVitalSignsHistoryData.join('\n');
      debugPrint("swimmingExerciseHistoryData=$swimmingExerciseHistoryData");
      final resultSwimmingExerciseString =
          swimmingExerciseHistoryData.join('\n');
      final resultSingleLapSwimmingString =
          singleLapSwimmingHistoryData.join('\n');
      final resultSleepString = sleepHistoryData.join('\n');
      final resultStepTemperatureActivityIntensityString =
          stepTemperatureActivityIntensityHistoryData.join('\n');
      array.add(newHistoryDataString);
      array.add(resultTemperatureString);
      array.add(resultExcludedSwimmingActivityString);
      array.add(resultDailyActivityString);
      array.add(resultExerciseActivityString);
      array.add(resultExerciseVitalSignsString);
      array.add(resultSwimmingExerciseString);
      array.add(resultSingleLapSwimmingString);
      array.add(resultSleepString);
      array.add(resultStepTemperatureActivityIntensityString);
      newAlgorithmHistory.value = array;
      newHistoryProcess.value = "finish";
      newHistoryShow.value = true;
    }

    //user info callback interface registration function
    ringManager.registerProcess(ReceiveType.USER_INFO, (data) {
      userInfoValue.assignAll(data);
      debugPrint("userInfoValue=$userInfoValue");
    });

    //NEW_ALGORITHM_HISTORY
    ringManager.registerProcess(ReceiveType.NEW_ALGORITHM_HISTORY, (data) {
      debugPrint(
          "NEW_ALGORITHM_HISTORY data=$data historyCount=$historyCount  numUUID=${numUUID.value}  ");
      historyCount += 1;
      newHistoryProcess.value =
          "${data["uuid"] - startUUID.value + 1}/${numUUID.value}";
      newHistoryData.add(jsonEncode(data));
      if (historyCount == numUUID.value) {
        newHistoryReceiveFinish();
      }
    });

    //NEW_ALGORITHM_HISTORY_NUM
    ringManager.registerProcess(ReceiveType.NEW_ALGORITHM_HISTORY_NUM, (data) {
      if (data["num"] == 0) {}
      endUUID.value = data["maxUUID"];
      startUUID.value = data["minUUID"];
      numUUID.value = data["num"];
      historyCount = 0;
      newAlgorithmHistory.value = [];
      newHistoryShow.value = false;
      newHistoryData = [];
      temperatureHistoryData = [];
      excludedSwimmingActivityHistoryData = [];
      dailyActivityHistoryData = [];
      exerciseActivityHistoryData = [];
      exerciseVitalSignsHistoryData = [];
      swimmingExerciseHistoryData = [];
      singleLapSwimmingHistoryData = [];
      stepTemperatureActivityIntensityHistoryData = [];
      sleepHistoryData = [];
      newAlgorithmHistoryData = [];
    });

    //EXCLUDED_SWIMMING_ACTIVITY_HISTORY
    ringManager.registerProcess(ReceiveType.EXCLUDED_SWIMMING_ACTIVITY_HISTORY,
        (data) {
      debugPrint("EXCLUDED_SWIMMING_ACTIVITY_HISTORY data=$data ");
      historyCount += 1;
      excludedSwimmingActivityHistoryData.add(jsonEncode(data));
      if (historyCount == numUUID.value) {
        newHistoryReceiveFinish();
      }
    });

    //EXERCISE_ACTIVITY_HISTORY
    ringManager.registerProcess(ReceiveType.EXERCISE_ACTIVITY_HISTORY, (data) {
      debugPrint("EXERCISE_ACTIVITY_HISTORY data=$data ");
      historyCount += 1;
      exerciseActivityHistoryData.add(jsonEncode(data));
      if (historyCount == numUUID.value) {
        newHistoryReceiveFinish();
      }
    });

    //SWIMMING_EXERCISE_HISTORY
    ringManager.registerProcess(ReceiveType.SWIMMING_EXERCISE_HISTORY, (data) {
      debugPrint("SWIMMING_EXERCISE_HISTORY data=$data ");
      historyCount += 1;
      swimmingExerciseHistoryData.add(jsonEncode(data));
      if (historyCount == numUUID.value) {
        newHistoryReceiveFinish();
      }
    });

    //SINGLE_LAP_SWIMMING_HISTORY
    ringManager.registerProcess(ReceiveType.SINGLE_LAP_SWIMMING_HISTORY,
        (data) {
      debugPrint("SINGLE_LAP_SWIMMING_HISTORY data=$data ");
      historyCount += 1;
      singleLapSwimmingHistoryData.add(jsonEncode(data));
      if (historyCount == numUUID.value) {
        newHistoryReceiveFinish();
      }
    });

    //STEP_TEMPERATURE_ACTIVITY_INTENSITY_HISTORY
    ringManager.registerProcess(
        ReceiveType.STEP_TEMPERATURE_ACTIVITY_INTENSITY_HISTORY, (data) {
      debugPrint("STEP_TEMPERATURE_ACTIVITY_INTENSITY_HISTORY data=$data ");
      historyCount += 1;
      stepTemperatureActivityIntensityHistoryData.add(jsonEncode(data));
      if (historyCount == numUUID.value) {
        newHistoryReceiveFinish();
      }
    });

    //SLEEP_HISTORY
    ringManager.registerProcess(ReceiveType.SLEEP_HISTORY, (data) {
      debugPrint("SLEEP_HISTORY data=$data ");
      historyCount += 1;
      sleepHistoryData.add(jsonEncode(data));
      newAlgorithmHistoryData.add({
        "ts": data["sleep_timeStamp"],
        "type": data["timeStamp_type"],
        "bed_rest_duration": data["bed_time"],
        "awake_order": data["wake_index"]
      });
      if (historyCount == numUUID.value) {
        newHistoryReceiveFinish();
      }
    });

    //DAILY_ACTIVITY_HISTORY
    ringManager.registerProcess(ReceiveType.DAILY_ACTIVITY_HISTORY, (data) {
      debugPrint("DAILY_ACTIVITY_HISTORY data=$data ");
      historyCount += 1;
      dailyActivityHistoryData.add(jsonEncode(data));
      if (historyCount == numUUID.value) {
        newHistoryReceiveFinish();
      }
    });

    //ACTIVE_DATA
    ringManager.registerProcess(ReceiveType.ACTIVE_DATA, (data) {
      debugPrint("ACTIVE_DATA data=$data ");
      activeData.value = jsonEncode(data);
    });
    //PPG_MEASUREMENT
    ringManager.registerProcess(ReceiveType.PPG_MEASUREMENT, (data) {
      debugPrint("PPG_MEASUREMENT data=$data ");
    });

    //EXERCISE_VITAL_SIGNS_HISTORY
    ringManager.registerProcess(ReceiveType.EXERCISE_VITAL_SIGNS_HISTORY,
        (data) {
      debugPrint("EXERCISE_VITAL_SIGNS_HISTORY data=$data ");
      historyCount += 1;
      exerciseVitalSignsHistoryData.add(jsonEncode(data));
      if (historyCount == numUUID.value) {
        newHistoryReceiveFinish();
      }
    });

    //TEMPERATURE_HISTORY
    ringManager.registerProcess(ReceiveType.TEMPERATURE_HISTORY, (data) {
      historyCount += 1;
      temperatureHistoryData.add(jsonEncode(data));
      if (historyCount == numUUID.value) {
        newHistoryReceiveFinish();
      }
    });

    //GET_REPORTING_EXERCISE
    ringManager.registerProcess(ReceiveType.GET_REPORTING_EXERCISE, (data) {
      debugPrint("GET_REPORTING_EXERCISE data=$data ");
      reporting_exercise.value = jsonEncode(data);
    });

    //SET_MEASUREMENT_TIMING
    ringManager.registerProcess(ReceiveType.SET_MEASUREMENT_TIMING, (data) {
      debugPrint("SET_MEASUREMENT_TIMING data=$data ");
      measureTimingValue.assignAll(data);
    });

    ringManager.registerProcess(ReceiveType.PPG_SET, (data) {
      debugPrint("PPG_SET data=$data ");
    });

    ringManager.registerProcess(ReceiveType.PPG_DATA, (data) {
      if (startTime.isEmpty) {
        startTime = formatNowTime();
        currentTime = DateTime.now();
      }
      if (ppgDataList.length == 100) {
        if (ppgData.length > 240) {
          endTime = formatNowTime();
          //ppgData数组至少要240个数据才能进行计算
          sendBle(SendType.setPpg, {"on_off": 0});
          ppgSwitch.value = false;
        } else {
          currentTime = currentTime.add(const Duration(seconds: 1));
          ppgData.add({
            "ppg": List.from(ppgDataList),
            "timestamp":
                formatDateTime(currentTime)
          });
          ppgDataList.clear();
        }
      }
      ppgDataList.addAll(data["ppgList"]);
    });

    // loadJsonToDB();
  }

  void resetPpg() {
    ppgData.clear();
    ppgDataList.clear();
    startTime = "";
    endTime = "";
  }

  void getNewSleepData() {
    if (sleepArray.isEmpty) {
      showToast("Please obtain historical data first");
      return;
    }
    final sleepResult =
        smartring_plugin.sleepNewAlgorithm(sleepArray, newAlgorithmHistoryData);
    sleepTimeArray = [];
    sleepTimePeriodArray = [];
    newSleepAnalysis.value = "";
    for (var i = 0; i < sleepResult.length; i++) {
      var data = sleepResult[i];
      var lightTime = 0;
      var deepTime = 0;
      var remTime = 0;
      var wakeTime = 0;
      var napTime = 0;
      var startTime = data["startTime"];
      var endTime = data["endTime"];
      var stagingList = data["stagingList"];
      for (var i = 0; i < stagingList.length; i++) {
        var staging = stagingList[i];
        switch (staging["type"]) {
          case smartring_plugin.SleepType.WAKE:
            wakeTime = staging["endTime"] - staging["startTime"] + wakeTime;
            break;
          case smartring_plugin.SleepType.NREM1:
            lightTime = staging["endTime"] - staging["startTime"] + lightTime;
            break;
          case smartring_plugin.SleepType.NREM3:
            deepTime = staging["endTime"] - staging["startTime"] + deepTime;
            break;
          case smartring_plugin.SleepType.REM:
            remTime = staging["endTime"] - staging["startTime"] + remTime;
            break;
          case smartring_plugin.SleepType.NAP:
            napTime = staging["endTime"] - staging["startTime"] + napTime;
            break;
        }
      }
      sleepTimeArray.add({
        "deepSleep":
            "deepTime= ${(deepTime ~/ HOUR)}h${((deepTime % HOUR) ~/ MINUTE)}m",
        "lightTime":
            "lightTime= ${(lightTime ~/ HOUR)}h${((lightTime % HOUR) ~/ MINUTE)}m",
        "remTime":
            "remTime= ${(remTime ~/ HOUR)}h${((remTime % HOUR) ~/ MINUTE)}m",
        "wakeTime":
            "wakeTime= ${(wakeTime ~/ HOUR)}h${((wakeTime % HOUR) ~/ MINUTE)}m",
        "napTime":
            "napTime= ${(napTime ~/ HOUR)}h${((napTime % HOUR) ~/ MINUTE)}m",
        "startTime": smartring_plugin.formatDateTime(startTime),
        "endTime": smartring_plugin.formatDateTime(endTime)
      });
      sleepTimePeriodArray.add({
        "sleepTimePeriod": {"startTime": startTime, "endTime": endTime}
      });
      newSleepAnalysis.value =
          "part$i ${smartring_plugin.formatDateTime(startTime)}-${smartring_plugin.formatDateTime(endTime)} deepTime= ${(deepTime ~/ HOUR)}h${((deepTime % HOUR) ~/ MINUTE)}m lightTime= ${(lightTime ~/ HOUR)}h${((lightTime % HOUR) ~/ MINUTE)}m remTime= ${(remTime ~/ HOUR)}h${((remTime % HOUR) ~/ MINUTE)}m wakeTime= ${(wakeTime ~/ HOUR)}h${((wakeTime % HOUR) ~/ MINUTE)}m napTime= ${(napTime ~/ HOUR)}h${((napTime % HOUR) ~/ MINUTE)}m ${newSleepAnalysis.value}";
      // smartring_plugin.formatDateTime(startTime);
      // smartring_plugin.formatDateTime(endTime);
    }
  }

  Future<void> uploadPpgData() async {
    await bloodGlucoseController
        ?.uploadPpgRecord(
            fasting: true,
            within2HrsMeal: false,
            startTime: startTime,
            endTime: endTime,
            ppgData: ppgData)
        .then((value) {
      uploadResult.value = value;
    });
  }

  Future<void> getBloodGlucoseData() async {
    //服务端计算血糖数据需要时间，延迟5秒后再获取计算结果
    Future.delayed(const Duration(seconds: 5), () async {
      await bloodGlucoseController?.getPpgResult().then((data) {
        if (data != null) {
          if (data['state'] == 0) {
            if (data['data'] != null) {
              ppgMeasureResult.value =
                  "lower_bound：${data['data']["measurement_data"]["lower_bound"]} upper_bound：${data['data']["measurement_data"]["upper_bound"]}";
            }else{
              ppgMeasureResult.value = "no data";
            }
          } else if (data['state'] == 1) {
            ppgMeasureResult.value = "sn not registered";
          }
        }
      });
    });
  }

  /////////////////////////SR28 end//////////////////////////////////////

  ///
  void getCloudEcg(bool requestSpe) async {
    String data = formatEcgData(ecgDataBuffer);
    await httpManager
        .cloudCalEcg(
            key: "2901f7613ac7403e9c5fbc0248b6d94f",
            sn: sn.value.toString(),
            mac: devAddress.value.toLowerCase(),
            secret: "ad58bea443d04368beb847510a37a99d",
            isSpe: requestSpe,
            data: data)
        .then((result) {
      debugPrint("getCloudEcg result=$result");
      if (result != null) {
        ecgResponse.value = jsonEncode(result);
      }
    });
  }

  /// clean ppg wave
  void cleanWave() {
    irWaveList.clear();
    update.value = !update.value;
  }

  /// start ECG measurement
  void startEcg() async {
    channel.send("start");
    maxRR = 0;
    minRR = 0;
    mood = 0;
    hrv = 0;
    currentEcgMode.value = 0;
    sendBle(SendType.setEcg, {
      "samplingRate": ECG_PPG_SAMPLE_RATE.ECG_PPG_SAMPLE_RATE_512,
      "switch": 1,
      "clockFrequency": 0,
      "dispSrc": 0,
    });
  }

  /// stop ECG measurement
  void stopEcg() async {
    sendBle(SendType.setEcg, {
      "samplingRate": ECG_PPG_SAMPLE_RATE.ECG_PPG_SAMPLE_RATE_512,
      "switch": 0,
      "clockFrequency": 0,
      "dispSrc": 0,
    });
  }

  /// start ECG measurement
  void startAlgorithmEcg() async {
    currentEcgMode.value = 1;
    sendBle(SendType.setEcg, {
      "samplingRate": ECG_PPG_SAMPLE_RATE.ECG_PPG_SAMPLE_RATE_512,
      "switch": 1,
      "clockFrequency": 0,
      "dispSrc": 1,
    });
  }

  /// stop ECG measurement
  void stopAlgorithmEcg() async {
    sendBle(SendType.setEcg, {
      "samplingRate": ECG_PPG_SAMPLE_RATE.ECG_PPG_SAMPLE_RATE_512,
      "switch": 0,
      "clockFrequency": 0,
      "dispSrc": 1,
    });
  }

  /// start ECG measurement
  void startRawWithBsecurEcg() async {
    channel.send("start");
    currentEcgMode.value = 2;
    sendBle(SendType.setEcg, {
      "samplingRate": ECG_PPG_SAMPLE_RATE.ECG_PPG_SAMPLE_RATE_512,
      "switch": 1,
      "clockFrequency": 0,
      "dispSrc": 2,
    });
  }

  /// stop ECG measurement
  void stopRawWithBsecurEcg() async {
    sendBle(SendType.setEcg, {
      "samplingRate": ECG_PPG_SAMPLE_RATE.ECG_PPG_SAMPLE_RATE_512,
      "switch": 0,
      "clockFrequency": 0,
      "dispSrc": 2,
    });
  }

  ///Send cmd to the ring
  void sendBle(SendType type, [data]) async {
    try {
      var result = ringManager.sendBle(type, data);
      await blueToothManager.write(WRITE_UUID, result.toList());
      debugPrint("result return $result");
    } catch (e) {
      debugPrint("sendBle error= $e");
    }
  }

  ///Turn sports mode on or off
  void onSportMode() {
    if (sportValue["sportMode"].value == 1) {
      sportStart = true;
      Future.delayed(const Duration(seconds: 1), () {
        sendBle(SendType.setSportModeParameters, {
          "switch": sportValue["sportMode"].value,
          "timeInterval": sportValue["timeInterval"].value,
          "duration": sportValue["duration"].value,
          "mode": sportValue["mode"].value
        });
      });
      futureCancle = Future.delayed(
          Duration(milliseconds: sportValue["duration"].value * MINUTE + 2000),
          () {
        sportStart = false;
      });
    } else {
      sendBle(SendType.setSportModeParameters, {
        "switch": sportValue["sportMode"].value,
        "timeInterval": sportValue["timeInterval"].value,
        "duration": sportValue["duration"].value,
        "mode": sportValue["mode"].value
      });

      sportStart = false;
      futureCancle.timeout(const Duration(milliseconds: 0), onTimeout: () {
        debugPrint("[futureCancle]");
      });
    }
  }

  //Calculate calories for a time period by obtaining the number of steps
  //taken at the beginning and end of the time period from historical data,
  //and combining height and strengthGrade to calculate the calories burned during this time period
  void caloriesCalculation(startStep, endStep) {
    if (sportValue['height'].value != null) {
      var step = endStep - startStep;
      if (step > 0) {
        double height = sportValue['height'].value.toDouble();
        calories.value = smartring_plugin.caloriesCalculation(
            height, step, sportValue['strengthGrade'].value);
        // debugPrint("calories.value=${calories.value} ");
      }
    }
  }

  ///Historical data processing
  void dealHistoryData(List<Map> historyData) async {
    debugPrint("dealHistoryData historyData=$historyData ");
    debugPrint("dealHistoryData historyRawDataArray=$historyRawDataArray ");
    List<Map> reData = historyData;
    // debugPrint("dealHistoryData reData=$reData ");
    historyDataArray = [];
    sleepArray = [];
    hrArray = [];
    historyDbArray = [];
    // await historyModel.deleteHistory();
    debugPrint("dealHistoryData reData=${reData.length} ");
    for (var i = 0; i < reData.length; i++) {
      var data = reData[i];
      debugPrint("sportsMode=${data["sportsMode"]} ");
      historyDbArray.add(HistoryDb(
          timeStamp: data["timeStamp"],
          heartRate: data["heartRate"],
          motionDetectionCount: data["motionDetectionCount"],
          detectionMode: data["detectionMode"],
          wearStatus: data["wearStatus"],
          chargeStatus: data["chargeStatus"],
          uuid: data["uuid"],
          hrv: data["hrv"],
          temperature: data["temperature"].toDouble(),
          step: data["step"],
          ox: data["ox"],
          rawHr: data["rawHr"],
          sportsMode: data["sportsMode"],
          respiratoryRate: data["respiratoryRate"]));

      if (data["hrv"] > 0) {
        var wearStatus = data["wearStatus"] == 1 ? "wear" : "noWear";
        var chargeStatus = data["chargeStatus"] == 1 ? "charging" : "uncharged";
        var detectionModeStatus =
            data["detectionMode"] == 1 ? "BloodOxygenMode" : "HeartRateMode";
        historyDataArray.add({
          "timeStamp": data["timeStamp"],
          "heartRate": data["heartRate"],
          "motionDetectionCount": data["motionDetectionCount"],
          "detectionMode": detectionModeStatus,
          "wearStatus": wearStatus,
          "chargeStatus": chargeStatus,
          "uuid": data["uuid"],
          "hrv": data["hrv"],
          "temperature": data["temperature"],
          "step": data["step"],
          "ox": data["ox"],
          "rawHr": data["rawHr"],
          "sportsMode": data["sportsMode"],
          "batteryLevel": data["batteryLevel"],
        });
      }
      var isBadData = false;
      if (data["rawHr"] == null) {
        isBadData = false;
      } else if (data["rawHr"].length == 3 &&
          data["rawHr"][0] == 200 &&
          data["rawHr"][1] == 200 &&
          data["rawHr"][2] == 200) {
        isBadData = true;
      }
      // debugPrint("data[heartRate]=${data["heartRate"]}  data[wearStatus]=${data["wearStatus"]} data[chargeStatus]=${data["chargeStatus"]}");
      if (data["heartRate"] >= 50 &&
          data["heartRate"] <= 175 &&
          data["wearStatus"] == 1 &&
          data["chargeStatus"] == 0 &&
          !isBadData) {
        sleepArray.add({
          "ts": data["timeStamp"],
          "hr": data["heartRate"],
          "hrv": data["hrv"],
          "motion": data["motionDetectionCount"],
          "steps": data["step"],
          "ox": data["ox"]
        });
      }
      if (data["heartRate"] >= 60 &&
          data["heartRate"] <= 175 &&
          data["wearStatus"] == 1 &&
          data["chargeStatus"] == 0 &&
          !isBadData) {
        hrArray.add({
          "ts": data["timeStamp"],
          "hr": data["heartRate"],
        });
      }
    }
    debugPrint(" all========================= ");
    await historyModel.addAllHistory(historyDbArray);
    //删除历史记录
    // sendBle(SendType.cleanHistoricalData);
    debugPrint(
        "主界面处理的睡眠数据 length=${sleepArray.length} sleepArray=$sleepArray ");
    await healthModel.storeSleepData();
  }

  Future<void> getTemperature() async {
    final temperatureFluctuateData =
        await healthModel.getSleepTemperatureFluctuateData(
            DateTime.now().subtract(const Duration(days: 30)));

    if (temperatureFluctuateData != null) {
      //   var ftcW = temperatureFluctuateData["ftcW"];
      // debugPrint('temperatureFluctuateData["ftcW"]=${ftcW}');
      ftcW.value = (temperatureFluctuateData["ftcW"] * 100).round() / 100;
      tempArr.value = temperatureFluctuateData["temperatureArray"];
      ftcBase.value = temperatureFluctuateData["ftcBase"];
    }
  }

  Future<void> getPressure() async {
    final pressureBaseLineData = await healthModel
        .getPressureBaseLine(DateTime.now().subtract(const Duration(days: 30)));
    if (0 < pressureBaseLineData["downCount"] &&
        pressureBaseLineData["downCount"] < 5) {
      stressDays.value = "还有${pressureBaseLineData["downCount"]}天提供压力数据";
    } else {
      stressDays.value = "";
    }
    var baseLine = pressureBaseLineData["baseLine"];
    if (baseLine > 0) {
      await healthModel.storePressureZone();
      pressureArray.value = {};

      motionArray.value = [];
      healthModel
          .getPressureDataByDate(
              DateTime.now().subtract(const Duration(days: 30)))
          .then((array) {
        var _recoveryTime = 0;
        var _stressTime = 0;
        for (var element in array) {
          pressureArray.addAll(element.allZoneList);
          motionArray.addAll(element.allMotionList);
          _recoveryTime += element.recoveryZoneList.length;
          _stressTime += element.stressZoneList.length;

          pressureBaseLine.value = element.pressureBaseLine;
        }
        debugPrint("recoveryTime=$_recoveryTime stressTime=$_stressTime");
        if (_recoveryTime != 0) {
          var totalMinutes = _recoveryTime * 15;
          recoveryTime.value = formatMinutesToHours(totalMinutes);
        } else {
          recoveryTime.value = "";
        }
        if (_stressTime != 0) {
          var totalMinutes = _stressTime * 15;
          stressTime.value = formatMinutesToHours(totalMinutes);
        } else {
          stressTime.value = "";
        }
      });

      // debugPrint("recoveryTime=$recoveryTime stressTime=$stressTime");
    }
  }

  String formatMinutesToHours(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    // 格式化小时和分钟为两位数
    String formattedHours = (hours < 10 ? '0' : '') + hours.toString();
    String formattedMinutes = (minutes < 10 ? '0' : '') + minutes.toString();
    debugPrint(
        "formattedHours=$formattedHours formattedMinutes=$formattedMinutes");
    return '$formattedHours h $formattedMinutes m';
  }

  ///Get sleep data
  void getSleepData() {
    if (sleepArray.isEmpty) {
      showToast("Please obtain historical data first");
      return;
    }
    debugPrint("getSleepData  sleepArray.length=${sleepArray.length}");
    final sleepResult = smartring_plugin.sleepAlgorithm(sleepArray);
    debugPrint("getSleepData  sleepResult=$sleepResult");
    sleepTimeArray = [];
    sleepTimePeriodArray = [];
    sleepAnalysis.value = "";
    for (var i = 0; i < sleepResult.length; i++) {
      var data = sleepResult[i];
      var lightTime = 0;
      var deepTime = 0;
      var remTime = 0;
      var wakeTime = 0;
      var napTime = 0;
      var startTime = data["startTime"];
      var endTime = data["endTime"];
      var stagingList = data["stagingList"];
      // debugPrint("i=$i  stagingList=$stagingList ");
      for (var i = 0; i < stagingList.length; i++) {
        var staging = stagingList[i];
        switch (staging["type"]) {
          case smartring_plugin.SleepType.WAKE:
            wakeTime = staging["endTime"] - staging["startTime"] + wakeTime;
            break;
          case smartring_plugin.SleepType.NREM1:
            lightTime = staging["endTime"] - staging["startTime"] + lightTime;
            break;
          case smartring_plugin.SleepType.NREM3:
            deepTime = staging["endTime"] - staging["startTime"] + deepTime;
            break;
          case smartring_plugin.SleepType.REM:
            remTime = staging["endTime"] - staging["startTime"] + remTime;
            break;
          case smartring_plugin.SleepType.NAP:
            napTime = staging["endTime"] - staging["startTime"] + napTime;
            break;
        }
      }
      sleepTimeArray.add({
        "deepSleep":
            "deepTime= ${(deepTime ~/ HOUR)}h${((deepTime % HOUR) ~/ MINUTE)}m",
        "lightTime":
            "lightTime= ${(lightTime ~/ HOUR)}h${((lightTime % HOUR) ~/ MINUTE)}m",
        "remTime":
            "remTime= ${(remTime ~/ HOUR)}h${((remTime % HOUR) ~/ MINUTE)}m",
        "wakeTime":
            "wakeTime= ${(wakeTime ~/ HOUR)}h${((wakeTime % HOUR) ~/ MINUTE)}m",
        "napTime":
            "napTime= ${(napTime ~/ HOUR)}h${((napTime % HOUR) ~/ MINUTE)}m",
        "startTime": smartring_plugin.formatDateTime(startTime),
        "endTime": smartring_plugin.formatDateTime(endTime)
      });
      sleepTimePeriodArray.add({
        "sleepTimePeriod": {"startTime": startTime, "endTime": endTime}
      });
      sleepAnalysis.value =
          "part$i ${smartring_plugin.formatDateTime(startTime)}-${smartring_plugin.formatDateTime(endTime)} deepTime= ${(deepTime ~/ HOUR)}h${((deepTime % HOUR) ~/ MINUTE)}m lightTime= ${(lightTime ~/ HOUR)}h${((lightTime % HOUR) ~/ MINUTE)}m remTime= ${(remTime ~/ HOUR)}h${((remTime % HOUR) ~/ MINUTE)}m wakeTime= ${(wakeTime ~/ HOUR)}h${((wakeTime % HOUR) ~/ MINUTE)}m napTime= ${(napTime ~/ HOUR)}h${((napTime % HOUR) ~/ MINUTE)}m ${sleepAnalysis.value}";
      // smartring_plugin.formatDateTime(startTime);
      // smartring_plugin.formatDateTime(endTime);
    }
  }

  void getRestingHeartRate() {
    if (hrArray.isEmpty) {
      showToast("Please obtain historical data first");
      return;
    }
    List restingHeartRateArray = smartring_plugin.restingHeartRate(hrArray);
    String result = "";
    for (var i = 0; i < restingHeartRateArray.length; i++) {
      var data = restingHeartRateArray[i];
      result =
          "part$i time:${smartring_plugin.formatDateTime(data["ts"], isFull: false)} restingHeartRate:${data["data"]} $result";
    }
    restingHeartRate.value = result;
  }

  void showToast(String content) {
    Fluttertoast.showToast(
      msg: content,
      toastLength: Toast.LENGTH_SHORT, // 或 Toast.LENGTH_LONG
      gravity: ToastGravity.BOTTOM, // Toast显示的位置，可以是TOP、CENTER、BOTTOM
      timeInSecForIosWeb: 1, // 仅对iOS和Web有效，持续时间（秒）
      backgroundColor: Colors.grey, // 背景颜色
      textColor: Colors.white, // 文本颜色
      fontSize: 16.0, // 文本大小
    );
  }

  void getRespiratoryRate() {
    if (sleepTimePeriodArray.isEmpty) {
      showToast(
          "Please obtain sleep data first, or there is no sleep data available");
      return;
    }
    List respiratoryRateArray =
        smartring_plugin.respiratoryRate(sleepTimePeriodArray, sleepArray);
    String result = "";
    for (var i = 0; i < respiratoryRateArray.length; i++) {
      var data = respiratoryRateArray[i];
      result =
          "part$i startTime:${smartring_plugin.formatDateTime(data["startTime"])} endTime:${smartring_plugin.formatDateTime(data["endTime"])} respiratoryRate:${data["respiratoryRate"]} $result";
    }
    respiratoryRate.value = result;
  }

  void getOxSaturation() {
    if (sleepTimePeriodArray.isEmpty) {
      showToast(
          "Please obtain sleep data first, or there is no sleep data available");
      return;
    }
    var oxSaturationArray =
        smartring_plugin.oxygenSaturation(sleepTimePeriodArray, sleepArray);
    String result = "";
    for (var i = 0; i < oxSaturationArray.length; i++) {
      var data = oxSaturationArray[i];
      result =
          "part$i startTime:${data["startTime"]} endTime:${data["endTime"]} oxygen:${data["oxygen"]} $result";
    }
    oxSaturation.value = result;
  }

  void getHrImmersion() {
    if (sleepTimePeriodArray.isEmpty) {
      showToast(
          "Please obtain sleep data first, or there is no sleep data available");
      return;
    }
    var hrImmersionArray = smartring_plugin.heartRateImmersion(
        sleepTimePeriodArray, sleepArray, hrArray);
    String result = "";
    for (var i = 0; i < hrImmersionArray.length; i++) {
      var data = hrImmersionArray[i];
      result =
          "part$i time:${data["time"]}  restingHeartRate:${data["restingHeartRate"].toStringAsFixed(1)} $result";
    }
    hrImmersion.value = result;
  }

  void setHrTime() {
    int time = hrMeasureTime < 10
        ? 10
        : hrMeasureTime > 180
            ? 180
            : hrMeasureTime;
    sendBle(SendType.setHrTime, {"time": time});
  }

  //血氧测量设置
  void setOxMeasurementSettings() {
    sendBle(SendType.oxSetting, {
      "switch": hrMeasurementSettingValue["switch"].value,
      "timeInterval": hrMeasurementSettingValue["timeInterval"].value,
    });
  }

  ///To start OEM certification, you need to first go to device information 1 to
  ///obtain the OEM switch status before deciding whether to proceed with OEM certification
  Future startOem() {
    return Future.delayed(const Duration(seconds: 2), () {
      isStartOem = true;
      sendBle(SendType.deviceInfo1);
    });
  }

  ///If oem is opened, it needs to be verified before closing
  Future closeOem() {
    return Future.delayed(const Duration(seconds: 1), () {
      sendBle(SendType.switchOEM, {"switch": 0});
    });
  }

  ///start oem verify
  void oemVerify() {
    ringManager.startOEMVerify((cmd, [data]) {
      // debugPrint(" startOEMVerify cmd=$cmd data=$data");
      var sendData = data;
      if (SendType.startOEMVerifyR2 == cmd) {
        sendData = smartring_plugin.aes128_decrypt(data["sn"], data["txt"]);
      }
      sendBle(cmd, sendData);
    });
  }

  //user info
  void handlerUserInfo() {
    sendBle(SendType.userInfo, {
      "height": userInfo["height"].value,
      "weight": userInfo["weight"].value,
      "age": userInfo["age"].value,
      "function": userInfo["function"].value,
      "sex": userInfo["sex"].value,
    });
  }

  //measure timing
  void handlerMeasureTiming() {
    sendBle(SendType.setMeasurementTiming, {
      "function": measureTiming["function"].value,
      "type": measureTiming["type"].value,
      "time1": measureTiming["time1"].value,
      "time1Interval": measureTiming["time1Interval"].value,
      "time2": measureTiming["time2"].value,
      "time2Interval": measureTiming["time2Interval"].value,
      "time3Interval": measureTiming["time3Interval"].value,
    });
  }

  void handlerExercise() {
    sendBle(SendType.setExercise, {
      "function": exercise["function"].value,
      "type": exercise["type"].value,
      "poolSize": exercise["poolSize"].value,
      "exerciseTime": exercise["exerciseTime"].value,
    });
  }

  void toggleReportingExerciseSwitch() {
    sendBle(SendType.setReportingExercise, {
      "on_off": reportSwitch.value ? 1 : 0,
    });
  }

  void togglePpgSwitch() {
    sendBle(SendType.setPpg, {
      "on_off": ppgSwitch.value ? 1 : 0,
    });
  }

  void bleScan() {
    blueToothManager.startScan();
  }
}
