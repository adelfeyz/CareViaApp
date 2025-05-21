import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smartring_flutter/src/widget/ecg_dialog.dart';
import 'package:smartring_flutter/src/widget/exercise_dialog.dart';
import 'package:smartring_flutter/src/widget/hrMSetting_dialog.dart';
import 'package:smartring_flutter/src/widget/measure_timing_dialog.dart';
import 'package:smartring_flutter/src/widget/register_device_dialog.dart';
import 'package:smartring_plugin/sdk/common/ble_protocol_constant.dart';
import '../../pages_data/health_data.dart';
import '../../util/getxManager.dart';
import '../../widget/ecg_raw_wave.dart';
import '../../widget/cus_dialog.dart';
import '../../widget/ecg_algorithm_wave.dart';
import '../../widget/health_item.dart';
import '../../widget/hr_wave.dart';
import '../../widget/line_chart.dart';
import '../../widget/motion_chart.dart';
import '../../widget/pressure_chart.dart';
import '../../widget/userInfo_dialog.dart';
import '../../widget/new_history_dialog.dart';

class HealthPage extends StatefulWidget {
  var tabIndex;

  HealthPage({super.key, required this.tabIndex});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  late BleData bleData;

  @override
  void initState() {
    super.initState();
    bleData = BleData();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Obx(() => HealthItemWidget(
              data: bleData.registerResult.value,
              buttonTitle: "register the device(BloodGlucose 1)",
              onPressed: () {
                showDialog(
                    context: context,
                    builder: RegisterDeviceDialog(
                        "User Info", bleData.userHealthInfo, (isSuccess) {
                      debugPrint("isSuccess:$isSuccess");
                      if (isSuccess) {
                        bleData.registerDevice();
                      }
                    }).build);
              },
            )),
        Obx(() => HealthItemWidget(
            data: "${bleData.noData}",
            buttonTitle: "PPG switch(BloodGlucose 2)",
            onPressed: () {},
            child: Switch(
              value: bleData.ppgSwitch.value,
              onChanged: (value) {
                bleData.resetPpg();
                bleData.ppgSwitch.value = value; // 更新开关状态
                bleData.togglePpgSwitch();
              },
            ))),
        Obx(() => HealthItemWidget(
              data: bleData.uploadResult.value,
              buttonTitle: "PPG Upload server(BloodGlucose 3)",
              onPressed: () {
                bleData.uploadPpgData();
              },
            )),
        Obx(() => HealthItemWidget(
              data: bleData.ppgMeasureResult.value,
              buttonTitle: "BloodGlucose(BloodGlucose 4)",
              onPressed: () {
                bleData.getBloodGlucoseData();
              },
            )),    
        Obx(() => HealthItemWidget(
              data: "${bleData.userInfoValue}",
              buttonTitle: "UserInfo",
              onPressed: () {
                showDialog(
                    context: context,
                    builder: UserInfoDialog("User Info", bleData.userInfo,
                        (isSuccess) {
                      debugPrint("isSuccess:$isSuccess");
                      if (isSuccess) {
                        bleData.handlerUserInfo();
                      }
                    }).build);
              },
            )),
        Obx(() => HealthItemWidget(
              data: bleData.newHistoryProcess.value,
              buttonTitle: "newHistory",
              onPressed: () {
                bleData.sendBle(SendType.setNewAlgorithmHistoryNum);
                debugPrint("setNewAlgorithmHistoryNum");
                Future.delayed(const Duration(seconds: 1), () {
                  bleData.sendBle(SendType.setNewAlgorithmHistory);
                });
                bleData.newHistoryShow.listen((value) {
                  if (value) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return NewHistoryDialog(
                            visible: true,
                            onClose: () {
                              Navigator.of(context).pop();
                            },
                            data: bleData.newAlgorithmHistory,
                            title: "History Data",
                          );
                        });
                  }
                });
              },
            )),
        Obx(() => HealthItemWidget(
              data: " ${bleData.cleanNewHistoryRes.value}",
              buttonTitle: "Clean New History",
              onPressed: () {
                bleData.sendBle(SendType.cleanNewHistoryData);
              },
            )),
        Obx(() => HealthItemWidget(
              data: " ${bleData.newSleepAnalysis.value}",
              buttonTitle: "Get New Algorithm Sleep",
              onPressed: () {
                bleData.getNewSleepData();
              },
            )),
        Obx(() => HealthItemWidget(
              data: " activeData:${bleData.activeData.value}",
              buttonTitle: "activeData",
              onPressed: () {
                bleData.sendBle(SendType.setActiveData);
              },
            )),
        Obx(() => HealthItemWidget(
              data: "${bleData.measureTimingValue}",
              buttonTitle: "set/get measurement timing",
              onPressed: () {
                showDialog(
                    context: context,
                    builder: MeasureTimingDialog(
                        "Measurement Timing", bleData.measureTiming,
                        (isSuccess) {
                      debugPrint("isSuccess:$isSuccess");
                      if (isSuccess) {
                        bleData.handlerMeasureTiming();
                      }
                    }).build);
              },
            )),
        Obx(() => HealthItemWidget(
              data: "${bleData.exercise}",
              buttonTitle: "set exercise",
              onPressed: () {
                showDialog(
                    context: context,
                    builder: ExerciseDialog("Exercise", bleData.exercise,
                        (isSuccess) {
                      debugPrint("isSuccess:$isSuccess");
                      if (isSuccess) {
                        bleData.handlerExercise();
                      }
                    }).build);
              },
            )),
        Obx(
          () => HealthItemWidget(
            data: bleData.reporting_exercise.value,
            buttonTitle: "reporting exercise",
            onPressed: null,
            child: Switch(
              value: bleData.reportSwitch.value,
              onChanged: (value) {
                bleData.reportSwitch.value = value; // 更新开关状态
                bleData.toggleReportingExerciseSwitch();
              },
            ),
          ),
        ),
        Obx(() => HealthItemWidget(
              data:
                  "height:${bleData.sportValue['height']}cm,timeInterval:${bleData.sportValue['timeInterval']}s,sportType:${bleData.sportValue['mode'] == 1 ? "Run" : "Other Sport"} duration:${bleData.sportValue['duration']}m,sportMode:${bleData.sportValue['sportMode'] == 1 ? "On" : "Off"},strengthGrade:${bleData.sportValue['strengthGrade']}",
              buttonTitle: "SportMode",
              onPressed: () {
                showDialog(
                    context: context,
                    builder:
                        CusDialog("SportMode", bleData.sportValue, (isSuccess) {
                      debugPrint("isSuccess:$isSuccess");
                      if (isSuccess) {
                        bleData.onSportMode();
                      }
                    }).build);
              },
            )),
        Obx(() => HealthItemWidget(
            data:
                "Calories burned: ${bleData.calories.value} Cal", //health_data.dart Provided calorie calculation interface
            buttonTitle: "Calories",
            onPressed: null)),
        Obx(
          () => HealthItemWidget(
              direction: Axis.vertical,
              data: bleData.empty.value,
              buttonTitle: "Set Hr measure time",
              onPressed: () {
                bleData.setHrTime();
              },
              child: SizedBox(
                  width: 400,
                  child: TextField(
                    controller: bleData.hrMeasureTimeController,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      labelText: "measure time",
                      hintText: "Please enter a number between 10 and 180",
                    ),
                    keyboardType: TextInputType.number,
                  ))),
        ),
        Obx(() => HealthItemWidget(
              data:
                  " heartRate=${bleData.heartValue.value} hrv=${bleData.hrvValue.value}",
              buttonTitle: "Turn on hr",
              onPressed: () {
                bleData.sendBle(SendType.openSingleHealth);
              },
            )),
        HealthItemWidget(
          data: "",
          buttonTitle: "Turn off hr",
          onPressed: () {
            bleData.sendBle(SendType.closeSingleHealth);
          },
        ),
        Obx(() => HealthItemWidget(
              data:
                  "BloodOxygen=${bleData.oxValue} heartRate=${bleData.heartValue}",
              buttonTitle: "Turn on hr&ox",
              onPressed: () {
                bleData.sendBle(SendType.openHealth);
              },
            )),
        HealthItemWidget(
          data: "",
          buttonTitle: "Turn off hr&ox",
          onPressed: () {
            bleData.sendBle(SendType.closeHealth);
          },
        ),
        HrWave(
            waveData: bleData.irWaveList,
            update: bleData.update,
            paintColor: 0xFFFF9000),
        HrWave(
            waveData: bleData.redWaveList,
            update: bleData.update,
            paintColor: 0xFF009000),
        Obx(() => HealthItemWidget(
              data:
                  "batteryValue：${bleData.batteryValue.value}mV status:${bleData.batteryState.value} batteryPer:${bleData.batteryPer.value}",
              buttonTitle: "Battery Info",
              onPressed: () {
                bleData.sendBle(SendType.batteryDataAndState);
              },
            )),
        Obx(() => HealthItemWidget(
              data:
                  "color：${bleData.devColor} size:${bleData.devSize} bleAddress:${bleData.devAddress} deviceVer:${bleData.devVersion}  switchOem:${bleData.switchOem} chargingMode:${bleData.chargingMode} mainChipModel:${bleData.mainChipModel}  productIteration:${bleData.productIteration} hasSportsMode:${bleData.hasSportsMode} isSupportEcg:${bleData.isSupportEcg} deviceType:${bleData.deviceType}",
              buttonTitle: "Device Info 1 Data",
              onPressed: () {
                bleData.sendBle(SendType.deviceInfo1);
              },
            )),
        Obx(() => HealthItemWidget(
              data:
                  "sn：${bleData.sn} bindStatus:${bleData.bindStatus} samplingRate:${bleData.samplingRate} ",
              buttonTitle: "Device Info 2 Data",
              onPressed: () {
                bleData.sendBle(SendType.deviceInfo2);
              },
            )),
        Obx(() => HealthItemWidget(
              data:
                  "hrMeasurementTime：${bleData.hrMeasurementTime} oxMeasurementInterval:${bleData.oxMeasurementInterval} oxMeasurementSettingSwitch:${bleData.oxMeasurementSwitch} ",
              buttonTitle: "Device Info 5 Data",
              onPressed: () {
                bleData.sendBle(SendType.deviceInfo5);
              },
            )),
        Obx(() => HealthItemWidget(
              data: "",
              buttonTitle: "oxMeasurementSetting",
              onPressed: bleData.hrMeasurementSettingValue['disable'].value
                  ? null
                  : () {
                      bleData.setOxMeasurementSettings();
                    },
              child: SizedBox(
                  width: 120,
                  child: TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.blue[500])),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: HrMSettingDailog("Set Parameter",
                                    bleData.hrMeasurementSettingValue)
                                .build);
                      },
                      child: const Text("Set Parameter"))),
            )),
        Obx(() => HealthItemWidget(
              data: "${bleData.shutdownRes.value}  ",
              buttonTitle: "Shutdown",
              onPressed: () {
                bleData.sendBle(SendType
                    .shutDown); //After shutting down, it needs to be powered on and turned on
              },
            )),
        Obx(() => HealthItemWidget(
              data: "${bleData.timeSyncRes.value}  ",
              buttonTitle: "TimeSync",
              onPressed: () {
                bleData.sendBle(SendType
                    .timeSyn); //Suggest synchronizing the time every time you open the app
              },
            )),
        Obx(() => HealthItemWidget(
            data: "${bleData.deviceBindRes.value}  ",
            buttonTitle: "DeviceBind",
            onPressed: () {
              bleData.deviceUnBindRes.value = "";
              bleData.deviceIsBind.value = true;
              bleData.sendBle(SendType
                  .deviceBind); //After binding, the ring can receive Bluetooth broadcasts without the need for power connection
            })),
        Obx(() => HealthItemWidget(
            data: "${bleData.deviceUnBindRes.value}  ",
            buttonTitle: "DeviceUnBind",
            onPressed: () {
              bleData.deviceBindRes.value = "";
              bleData.deviceIsBind.value = false;
              bleData.sendBle(SendType.deviceUnBind);
            })),
        Obx(() => HealthItemWidget(
            data: "${bleData.restartRes.value}  ",
            buttonTitle: "Restart",
            onPressed: () {
              bleData.sendBle(SendType.restart);
            })),
        Obx(() => HealthItemWidget(
            data: "${bleData.factoryResetRes.value}  ",
            buttonTitle: "FactoryReset",
            onPressed: () {
              bleData.sendBle(SendType
                  .restoreFactorySettings); //After executing this command, the ring needs to be powered on before it can scan Bluetooth
            })),
        Obx(() => HealthItemWidget(
            data: "${bleData.cleanHistoricalRes.value}  ",
            buttonTitle: "CleanHistoricalData",
            onPressed: () {
              bleData.sendBle(SendType
                  .cleanHistoricalData); //It is recommended to clear the historical data after saving it to the database every time the app is opened
            })),
        Obx(() => HealthItemWidget(
            data: "${bleData.temperatureRes.value}  ",
            buttonTitle: "Finger Temperature",
            onPressed: () {
              bleData.sendBle(SendType.temperature);
            })),
        Obx(() => HealthItemWidget(
            visible: bleData.progressVisit.value,
            process: bleData.progressValue.value,
            listDate: bleData.historyRawDataArray.length > 0
                ? bleData.historyRawDataArray[
                    bleData.historyRawDataArray.length - 1]["historyArray"]
                : [],
            data:
                "${bleData.historyStart.value}  startUUID=${bleData.startUUID.value} endUUID=${bleData.endUUID.value} uuid=${bleData.historyUUIDList}",
            buttonTitle: "HistoryData",
            onPressed: () {
              bleData.historyUUIDList = [];
              bleData.historyRawDataArray = [];
              bleData.progressValue.value = 0.0;
              bleData.sendBle(SendType.historicalNum);
              Future.delayed(const Duration(seconds: 1), () {
                bleData.sendBle(SendType.historicalData);
                bleData.progressVisit.value = true;
              });
            })),
        Obx(() => HealthItemWidget(
            data: "${bleData.sleepAnalysis.value}  ",
            buttonTitle: "Sleep data",
            onPressed: () {
              bleData.getSleepData();
            })),
        Obx(() => HealthItemWidget(
            data: "${bleData.restingHeartRate.value}  ",
            buttonTitle: "Resting heart rate",
            onPressed: () {
              bleData.getRestingHeartRate();
            })),
        Obx(() => HealthItemWidget(
            data: "${bleData.respiratoryRate.value}  ",
            buttonTitle: "Respiratory rate",
            onPressed: () {
              bleData.getRespiratoryRate();
            })),
        Obx(() => HealthItemWidget(
            data: "${bleData.oxSaturation.value}  ",
            buttonTitle: "Ox saturation",
            onPressed: () {
              bleData.getOxSaturation();
            })),
        Obx(() => HealthItemWidget(
            data: "${bleData.hrImmersion.value}  ",
            buttonTitle: "Hr immersion",
            onPressed: () {
              bleData.getHrImmersion();
            })),
        Obx(() => HealthItemWidget(
            data: "${bleData.repackage.value}  ",
            buttonTitle: "Packet response information",
            onPressed: null)),
        HealthItemWidget(
            data: " ",
            buttonTitle: "Close OEM",
            onPressed: () {
              bleData.closeOem();
            }),
        HealthItemWidget(
            data: " ",
            buttonTitle: "Turn on ppg switch",
            onPressed: () {
              bleData.sendBle(SendType.setHealthPara, {
                "samplingRate": bleData.samplingRate.value,
                "switch": 1
              }); //Need to open bleData. sendBle (SendType. openHealth); Only then can there be data output
            }),
        HealthItemWidget(
            data: " ",
            buttonTitle: "Turn off ppg switch",
            onPressed: () {
              bleData.cleanWave();
              bleData.sendBle(SendType.setHealthPara,
                  {"samplingRate": bleData.samplingRate.value, "switch": 0});
            }),
        Obx(() => HealthItemWidget(
            data:
                "${bleData.currentEcgMode.value == 0 ? bleData.outEcgValue : bleData.noData} ",
            buttonTitle:
                "start Ecg", //Currently, the ring SR09 is not yet supported
            onPressed: () {
              bleData.startEcg();
            })),
        HealthItemWidget(
            data: " ",
            buttonTitle:
                "Stop Ecg", //Currently, the ring SR09 is not yet supported
            onPressed: () {
              bleData.stopEcg();
            }),
        HealthItemWidget(
          data: bleData.empty.value,
          buttonTitle: "Arrhythmia electrocardiogram from cloud",
          onPressed: () {
            bleData.ecgResponse.listen((value) {
              if (value.isNotEmpty) {
                showDialog(
                    context: context,
                    builder: (context) {
                      return EcgDialog(
                        visible: true,
                        onClose: () {
                          Navigator.of(context).pop();
                        },
                        data: bleData.ecgResponse.value,
                        title: "Arrhythmia Data",
                      );
                    });
              }
            });
            bleData.getCloudEcg(false);
          },
        ),
        HealthItemWidget(
          data: "",
          buttonTitle: "Spe electrocardiogram from cloud",
          onPressed: () {
            bleData.getCloudEcg(true);
            bleData.ecgResponse.listen((value) {
              if (value.isNotEmpty) {
                showDialog(
                    context: context,
                    builder: (context) {
                      return EcgDialog(
                        visible: true,
                        onClose: () {
                          Navigator.of(context).pop();
                        },
                        data: value,
                        title: "Spe Data",
                      );
                    });
              }
            });
          },
        ),
        Obx(() => bleData.currentEcgMode.value == 0
            ? EcgRawWave(
                bleData.waveRawData,
                bleData.ecgUpdate,
              )
            : Container()),
        Obx(() => HealthItemWidget(
            data:
                "${bleData.currentEcgMode.value == 1 ? bleData.ecgAlgorithmResult : bleData.noData} ",
            buttonTitle:
                "start Algorithm Ecg", //Currently, the ring SR09 is not yet supported
            onPressed: () {
              bleData.startAlgorithmEcg();
            })),
        HealthItemWidget(
            data: " ",
            buttonTitle:
                "Stop Algorithm Ecg", //Currently, the ring SR09 is not yet supported
            onPressed: () {
              bleData.stopAlgorithmEcg();
            }),
        Obx(() => bleData.currentEcgMode.value == 1
            ? EcgAlgorithmWave(
                bleData.waveData,
                bleData.ecgUpdate,
              )
            : Container()),
        Obx(() => HealthItemWidget(
            data:
                "${bleData.currentEcgMode.value == 2 ? bleData.ecgAlgorithmResult : bleData.noData} ",
            buttonTitle:
                "start Raw with B-Secur Ecg", //Currently, the ring SR09 is not yet supported
            onPressed: () {
              bleData.startRawWithBsecurEcg();
            })),
        HealthItemWidget(
            data: " ",
            buttonTitle:
                "Stop Raw with B-Secur Ecg", //Currently, the ring SR09 is not yet supported
            onPressed: () {
              bleData.stopRawWithBsecurEcg();
            }),
        Obx(() => bleData.currentEcgMode.value == 2
            ? EcgRawWave(
                bleData.waveRawData,
                bleData.ecgUpdate,
              )
            : Container()),
        TextButton(
            onPressed: () {
              bleData.getTemperature();

              TempLineChartController controller = GetXManager.instance
                  .getController(GetXManager.tempLineChartControllerTag);
              controller.updateData(bleData.tempArr);
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue[100])),
            child: const Text(
              "获取手指温度数据",
            )),
        Obx(() => Text("手指温度波动:${bleData.ftcW}  基线温度:${bleData.ftcBase}")),
        TempLineChart(),
        TextButton(
            onPressed: () {
              bleData.getPressure();
              MotionChartController motionController = GetXManager.instance
                  .getController(GetXManager.motionChartControllerTag);
              motionController.updateData(bleData.motionArray);
              PressureLineChartController pressureController = GetXManager
                  .instance
                  .getController(GetXManager.pressureChartControllerTag);
              pressureController.updateData(bleData.pressureArray);
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue[100])),
            child: const Text(
              "获取压力数据",
            )),
        Obx(() => Text("${bleData.stressDays}")),
        Obx(() =>
            Text("压力时间：${bleData.stressTime} 恢复时间：${bleData.recoveryTime}")),
        PressureLineChart(pressureBaseLine: bleData.pressureBaseLine),
        const Text("Daily exercise"),
        MotionChart(),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Spacer(),
          Container(
            width: 20,
            height: 20,
            color: const Color(0xff8a8a8a),
          ),
          const Text("ExtremelyLow"),
          const Spacer(),
          Container(
            width: 20,
            height: 20,
            color: const Color(0xff02679e),
          ),
          const Text("Low"),
          const Spacer(),
          Container(
            width: 20,
            height: 20,
            color: const Color(0xff7dcbf5),
          ),
          const Text("Medium"),
          const Spacer(),
          Container(
            width: 20,
            height: 20,
            color: const Color.fromARGB(255, 223, 219, 219),
          ),
          const Text("High"),
          const Spacer(),
        ]),
      ],
    );
  }
}
