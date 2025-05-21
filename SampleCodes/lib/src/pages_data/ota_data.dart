import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:smartring_plugin/sdk/ota/manager/suotaManager.dart'
    as suotaManager;
import 'package:smartring_plugin/sdk/core.dart';
import 'package:smartring_plugin/sdk/ota/common/common.dart';

import '../bluetooth/bluetooth_manager.dart';
import '../common/constant.dart';
import '../http/httpManager.dart';
import '../util/otaUtil.dart';
import 'package:device_info_plus/device_info_plus.dart';

class OtaData {
  static final OtaData _instance = OtaData._internal();

  factory OtaData() {
    return _instance;
  }

  OtaData._internal();

  int patchDataSize = DEFAULT_FILE_CHUNK_SIZE;
  String i2c_addr = DEFAULT_I2C_DEVICE_ADDRESS;
  String blockSize = DEFAULT_BLOCK_SIZE_VALUE;
  int selectedSCL = DEFAULT_SCL_GPIO_VALUE;
  int selectedSDA = DEFAULT_SDA_GPIO_VALUE;
  int selectedBank = DEFAULT_MEMORY_BANK;
  int selectedMISO = DEFAULT_MISO_VALUE;
  int selectedMISI = DEFAULT_MISI_VALUE;
  int selectedCS = DEFAULT_CS_VALUE;
  int selectedSCK = DEFAULT_SCK_VALUE;
  int fileChunkSize = DEFAULT_FILE_CHUNK_SIZE;
  late Uint8List bytes;

  static const String ACTION_BLUETOOTH_GATT_UPDATE = "BluetoothGattUpdate";
  static const String ACTION_PROGRESS_UPDATE = "ProgressUpdate";
  static const String ACTION_CONNECTION_STATE_UPDATE = "ConnectionState";
  static int DEFAULT_MTU = 23;
  int MEMORY_TYPE_SYSTEM_RAM = 1;
  int MEMORY_TYPE_RETENTION_RAM = 2;
  static int MEMORY_TYPE_SPI = 3;
  int MEMORY_TYPE_I2C = 4;
  int DEFAULT_MEMORY_TYPE = MEMORY_TYPE_SPI;
  int DEFAULT_MOSI_VALUE = 0;
  int MEMORY_TYPE_SUOTA_INDEX = 100;
  int MEMORY_TYPE_SPOTA_INDEX = 101;
  int STATE_DISCONNECTED = 0;
  final RegExp gpioStringPattern = RegExp(r'P(\d+)_(\d+)');
  bool disconnected = false;

  String fileName = "";
  Map errors = {};
  int step = -1;
  Map<String, dynamic> deviceInfo = {};

  int mtu = DEFAULT_MTU;
  bool mtuRequestSent = false;
  bool mtuReadAfterRequest = false;
  int l2capPsm = 0;
  List<dynamic> characteristicsQueue = [];

  bool hasError = false;
  Function processCallBack = (dynamic a, dynamic b, dynamic c) {};
  Function successCallBack = () {};
  Function writeFailCallBack = () {};
  Function initMTUCallback = () {};
  // Function initMemoryTypeCallBack = () {};
  bool canListener = true;
  bool isSendBlock = false;
  dynamic navigation = null;
  BlueToothManager? blueToothManager = null;

  late DeviceInfoPlugin deviceInfoPlugin;
  late AndroidDeviceInfo androidDeviceInfo;
  late RingManager ringManager;
  void init() async {
    errors = suotaManager.initErrorMap();
    blueToothManager = BlueToothManager();
    deviceInfoPlugin = DeviceInfoPlugin();
    ringManager = RingManager.instance;
    if (Platform.isAndroid) {
      androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    }

    await blueToothManager!.notifityWriteListener(SPOTA_SERV_STATUS_UUID,
        (data,characteristic) async {
      debugPrint(" Ota====notifityWriteListener data=${characteristic.serviceUuid}");
      final value = data[0];
      // debugPrint("handleUpdateValue=${value}");

      var step = -1;
      var error = -1;
      var status = -1;
      var isSuota = suotaManager.getType() == suotaManager.TYPE;

      // SUOTA image started
      if (value == 0x10) {
        step = 3;
      }
      // Successfully sent a block, send the next one
      else if (value == 0x02) {
        step = isSuota ? 5 : 8;
      }
      // SPOTA service status
      else if (!isSuota && (value == 0x01 || value == 0x03)) {
        status = value;
      } else {
        error = value;
      }

      if (step >= 0 || error >= 0 || status >= 0) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (step == 5 && isSendBlock) {
          return;
        }
        otaStep({
          "action": ACTION_BLUETOOTH_GATT_UPDATE,
          "step": step,
          "error": error,
          "status": status,
        });
        if (step == 5) {
          isSendBlock = true;
        }
      }

      // ringManager.receiveData(data);
    }, onError: (error) {
      debugPrint("Ota====notifityWriteListener error=$error");
    });
    _initData();
    otaStep({"action": ACTION_BLUETOOTH_GATT_UPDATE, "step": 0});
  }

  int gpioStringToInt(String gpioValue) {
    RegExp match = gpioStringPattern;
    var pe = match.allMatches(gpioValue);
    //  for (var element in pe) {
    //    element[0];
    //  }
    if (pe.isNotEmpty) {
      String? group1 = pe.elementAt(0)[0];
      String? group2 = pe.elementAt(1)[0];
      if (group1 != null && group1 != "" && group2 != null && group2 != "") {
        try {
          return ((int.parse(group1, radix: 10) & 0x0f) << 4) |
              (int.parse(group2, radix: 10) & 0x0f);
        } catch (ignored) {}
      }
    }
    return 0;
  }

  void otaStep(intent) {
    switch (intent["action"]) {
      case ACTION_CONNECTION_STATE_UPDATE:
        connectionStateChanged(intent.state);
        break;
      case ACTION_BLUETOOTH_GATT_UPDATE:
        processStep(intent);
        break;
      case ACTION_PROGRESS_UPDATE:
        break;
    }
  }

  void connectionStateChanged(connectionState) {
    if (connectionState == STATE_DISCONNECTED) {
      disconnected = true;
      blueToothManager?.disConnect();
    }
  }

  void onError(errorCode) {
    var error = errors["$errorCode"];
    debugPrint(" errorCode=$errorCode error=$error  hasError=$hasError");
    //console.log("Error: " + errorCode +" errorCode?.includes"+`${errorCode==242}`);
    if (hasError || errorCode == 133 || errorCode == 242) {
      return;
    }
    hasError = true;

    blueToothManager?.disConnect();
    dispatchErrorData(error);
  }

  processStep(intent) async {
    var newStep = intent["step"] ?? -1;
    var error = intent["error"] ?? -1;
    // console.log(`processStep intent(newStep=${newStep}, error: ${error})`);
    // debugPrint(
    //     "processStep newStep=$newStep error=$error  intent[error]${intent["error"]}");
    if (error != -1) {
      onError(error);
      return;
    }

    if (newStep >= 0) {
      step = newStep;
    } else {
      var index = intent["characteristic"] ?? -1;
      // debugPrint("processStrp index=$index");
      if (index != -1) {
        var value = intent["value"];
      } else {
        if (intent["hasSuotaVersion"] != null && intent["hasSuotaVersion"]) {
          var version = intent["suotaVersion"];
          // console.log("SUOTA version: " + version);
          deviceInfo["version"] = version;
          // debugPrint(" processStep version=$version");
        } else if (intent["hasSuotaPatchDataSize"] != null &&
            intent["hasSuotaPatchDataSize"]) {
          patchDataSize = intent["suotaPatchDataSize"];
          deviceInfo["suotaPatchDataSize"] = patchDataSize;
          // console.log("SUOTA patch data size: " + patchDataSize);
          updateFileChunkSize();
          // debugPrint("processStep SUOTA patch data size: $patchDataSize");
        } else if (intent["hasSuotaMtu"] != null && intent["hasSuotaMtu"]) {
          var oldMtu = mtu;
          mtu = intent["suotaMtu"];
          deviceInfo["suotaMtu"] = mtu;
          //console.log("SUOTA MTU: " + mtu);
          updateFileChunkSize();
          // debugPrint("processStep SUOTA MTU: $mtu");
          if (mtuRequestSent && !mtuReadAfterRequest && mtu != oldMtu) {
            mtuReadAfterRequest = true;
            if (Platform.isAndroid) {
              var manufacturer = androidDeviceInfo.manufacturer;
              // console.log(` manufacturer=${manufacturer}`)
              // debugPrint("processStep manufacturer: $manufacturer");
              if (manufacturer.contains("Xiaomi") &&
                  File("/system/lib/libbtsession.so").existsSync()) {
                // console.log("Workaround for Xiaomi MTU issue. Read MTU again.");
                blueToothManager?.addOTAcharacteristics(SUOTA_MTU_UUID);
              }
            }
          }
        } else if (intent["hasSuotaL2capPsm"] != null &&
            intent["hasSuotaL2capPsm"]) {
          l2capPsm = intent["suotaL2capPsm"];
          deviceInfo["suotaL2capPsm"] = l2capPsm;
          // debugPrint("processStep L2CAP PSM: $l2capPsm");
          // console.log("SUOTA L2CAP PSM: " + l2capPsm);
        }
      }

      // debugPrint(
      //     "processStep  mtu=$mtu  patchDataSize=$patchDataSize  Platform.isAndroid=${Platform.isAndroid}");
      if (Platform.isAndroid &&
          androidDeviceInfo.version.sdkInt >= 21 &&
          !mtuRequestSent &&
          characteristicsQueue.isEmpty &&
          mtu == DEFAULT_MTU &&
          mtu < patchDataSize + 3) {
        // console.log("Sending MTU request  patchDataSize" + patchDataSize);
        // debugPrint("Sending MTU request  patchDataSize =$patchDataSize");
        mtuRequestSent = true;
        blueToothManager?.requestMtu(patchDataSize + 3).then((value) {
          var intent = {"hasSuotaMtu": true, "suotaMtu": patchDataSize + 3};
          processStep(intent);
        }).catchError((error) {
          debugPrint("requestMtu error=$error");
        });
      }
      // console.log(`====================== readNextCharacteristic`)
      Future.delayed(const Duration(milliseconds: 500), () {
        debugPrint("processStep readNextCharacteristic");
        readNextCharacteristic();
      });
    }

    //  console.log("step " + step);
    // debugPrint("step =$step  Platform.isAndroid=${Platform.isAndroid}");
    switch (step) {
      case 0:
        if (Platform.isAndroid) {
          await blueToothManager?.refreshCache();
        }
        mtu = DEFAULT_MTU;
        patchDataSize = DEFAULT_FILE_CHUNK_SIZE;
        fileChunkSize = DEFAULT_FILE_CHUNK_SIZE;
        hasError = false;
        mtuRequestSent = false;
        // debugPrint("step =$step  readNextCharacteristic");
        // bleModule.queueReadSuotaInfo();
        await readNextCharacteristic();
        step = -1;
        break;

      case 1:

        if (Platform.isAndroid && androidDeviceInfo.version.sdkInt >= 21) {
          // console.log("Connection parameters update request (high)");
          blueToothManager?.requestConnectionPriority()?.then((value) async {
            suotaManager.reset();
            await enableNotifications();
            suotaManager.setType(suotaManager.TYPE);
          }).catchError((error) {
            debugPrint("requestConnectionPriority   error =${error}");
          });
        } else {
          suotaManager.reset();
          await enableNotifications();
          suotaManager.setType(suotaManager.TYPE);
        }

        break;

      case 2:
        // initMemoryTypeCallBack(fileName);
        // console.log(`Firmware CRC: ${suotaManager.getCrc() & 0xff}`);
        var fwSizeMsg =
            "Upload size: ${suotaManager.getNumberOfBytes()}  bytes";
        //console.log(fwSizeMsg);
        var chunkSizeMsg = "Chunk size: $fileChunkSize bytes";
        //console.log(chunkSizeMsg);
        // uploadStart = new Date().getTime();
        setSpotaMemDev();
        break;

      case 3:
        // console.log(`type=3 gpioMapPrereq=${suotaManager.getGpioMapPrereq()} `)
        if (suotaManager.addGpioMapPrereq() == 2) {
          // console.log(`type=3 进入 suotaManager.getGpioMapPrereq()=${suotaManager.getGpioMapPrereq()} `)
          suotaManager.setSpotaGpioMap((memInfoData) {
            var buffer = Uint8List(4).buffer;
            var dataView = ByteData.view(buffer);
            dataView.setUint32(0, memInfoData, Endian.little);
            blueToothManager
                ?.write(
                    SPOTA_GPIO_MAP_UUID, List<int>.from(buffer.asUint8List()))
                .then((value) {
              var intent = {"step": 4};
              processStep(intent);
            }).catchError((error) {
              debugPrint("write SPOTA_GPIO_MAP_UUID error=${error} ");
            });
          });
        }
        break;

      case 4:
        setPatchLength();
        break;

      case 5:
        // console.log(` suotaManager.lastBlockSent=${suotaManager.getLastBlockSent()} suotaManager.endSignalSent=${suotaManager.getEndSignalSent()}`)
        if (!suotaManager.getLastBlock()) {
          await sendBlock();
        } else {
          if (!suotaManager.getPreparedForLastBlock() &&
              suotaManager.getNumberOfBytes() %
                      suotaManager.getFileBlockSize() !=
                  0) {
            setPatchLength();
          } else if (!suotaManager.getLastBlockSent()) {
            await sendBlock();
          } else if (!suotaManager.getEndSignalSent()) {
            debugPrint("  getEndSignalSent");
            suotaManager.sendEndSignal((end_signal) {
              var buffer = Uint8List(4).buffer;
              var dataView = ByteData.view(buffer);
              dataView.setUint32(0, end_signal, Endian.little);
              debugPrint("  getEndSignalSent  end_signal=$end_signal");
              blueToothManager
                  ?.write(
                      SPOTA_MEM_DEV_UUID, List<int>.from(buffer.asUint8List()))
                  .then((value) {
                var intent = {"step": 5};
                processStep(intent);
              });
            });
          } else {
            // console.log(` ===========onSuccess================ `)
            suotaManager.onSuccess(() {
              Future.delayed(const Duration(seconds: 1), () {
                successCallBack();
              });
            });
          }
        }
        break;
    }
  }

  Future<void> readNextCharacteristic() async {
    try {
      await blueToothManager
          ?.readNextCharacteristic(readNextCharacteristicResult);
    } catch (e) {
      debugPrint("readNextCharacteristic error=$e");
    }
  }

  void setPatchLength() {
    suotaManager.setPatchLength((blocksize) {
      Uint8List(2);
      var buffer = Uint8List(2).buffer;
      var dataView = ByteData.view(buffer);
      dataView.setUint16(0, blocksize, Endian.little);
      blueToothManager
          ?.write(SPOTA_PATCH_LEN_UUID, List<int>.from(buffer.asUint8List()))
          .then((value) {
        var step = suotaManager.getType() == suotaManager.TYPE ? 5 : 7;
        // console.log(` suotaManager.getType()=${suotaManager.getType()} suotaManager.TYPE=${suotaManager.TYPE}`)
        var intent = {"step": step};
        processStep(intent);
      }).catchError((error) {
        writeFailCallBack(error);
      });
    });
  }

  void setSpotaMemDev() {
    var memType = suotaManager.getSpotaMemDev();
    var buffer = Uint8List(4).buffer;
    var dataView = ByteData.view(buffer);
    dataView.setUint32(0, memType, Endian.little);
    debugPrint(
        " setSpotaMemDev memType=$memType  List<int>.from(buffer.asInt32List())=${List<int>.from(buffer.asUint8List())}");
    // console.log(`getSpotaMemDev memType=${memType}  Array.from(new Uint8Array(buffer)=${Array.from(new Uint8Array(buffer))}`);
    blueToothManager
        ?.write(SPOTA_MEM_DEV_UUID, List<int>.from(buffer.asUint8List()))
        .then((value) {
      debugPrint("  setSpotaMemDev  发送数据成功 ");
      if (step == 2 || step == 3) step = 3;
      processStep({"step": step});
    }).catchError((error) {
      writeFailCallBack(error);
    });
  }

  Future<void> enableNotifications() async {
    await Future.delayed(const Duration(milliseconds: 500), () {
      var intent = {"step": 2};
      processStep(intent);
    });
  }

  void updateFileChunkSize() {
    fileChunkSize = min(patchDataSize, mtu - 3);
    // console.log(`File chunk size set to fileChunkSize=${fileChunkSize}`)
  }

  void readNextCharacteristicResult(Map result) {
    var sendUpdate = true;
    var index = -1;
    var step = -1;
    var intent = {};
    var suotaInfo = null;

    if (result["characteristicUUID"] ==
        ORG_BLUETOOTH_CHARACTERISTIC_MANUFACTURER_NAME_STRING) {
      index = 0;
    } else if (result["characteristicUUID"] ==
        ORG_BLUETOOTH_CHARACTERISTIC_MODEL_NUMBER_STRING) {
      index = 1;
    } else if (result["characteristicUUID"] ==
        ORG_BLUETOOTH_CHARACTERISTIC_FIRMWARE_REVISION_STRING) {
      index = 2;
    } else if (result["characteristicUUID"] ==
        ORG_BLUETOOTH_CHARACTERISTIC_SOFTWARE_REVISION_STRING) {
      index = 3;
    } else if (result["characteristicUUID"] == SUOTA_VERSION_UUID) {
      intent["hasSuotaVersion"] = true;
      intent["suotaVersion"] = result["dataView"].getUint8(0);
      suotaInfo = true;
    } else if (result["characteristicUUID"] ==
        SUOTA_PATCH_DATA_CHAR_SIZE_UUID) {
      intent["hasSuotaPatchDataSize"] = true;
      intent["suotaPatchDataSize"] =
          result["dataView"].getUint16(0, Endian.little);
      suotaInfo = true;
    } else if (result["characteristicUUID"] == SUOTA_MTU_UUID) {
      intent["hasSuotaMtu"] = true;
      intent["suotaMtu"] = result["dataView"].getUint16(0, Endian.little);
      suotaInfo = true;
    } else if (result["characteristicUUID"] == SUOTA_L2CAP_PSM_UUID) {
      intent["hasSuotaL2capPsm"] = true;
      intent["suotaL2capPsm"] = result["dataView"].getUint16(0, Endian.little);
      suotaInfo = true;
    }
    // SPOTA
    else if (result["characteristicUUID"] == SPOTA_MEM_INFO_UUID) {
      step = 5;
    } else {
      sendUpdate = false;
    }
    debugPrint(
        " sendUpdate=$sendUpdate  result[characteristicUUID]=${result["characteristicUUID"]}");
    if (sendUpdate) {
      // Log.d(TAG, "onCharacteristicRead: " + index);

      if (index >= 0) {
        intent["characteristic"] = index;
        intent["value"] = result["str"];
      } else if (suotaInfo) {
      } else {
        //TODO step -1 5
        intent["step"] = step;
        //console.log(` dataView=${dataView.length} `)
        intent["value"] = result["dataView"].getUint32(0, Endian.little);
      }
      debugPrint("readNextCharacteristic  result=$result  intent=$intent");
      //console.log(`=============================== onCharacteristicRead index=${index}  intent=${JSON.stringify(intent)}`)
      processStep(intent);
    }
    if (result["isLast"]) {
      initMTUCallback();
    }
    // console.log(`readNextCharacteristic isLast=${isLast}  characteristicUUID=${characteristicUUID}  index=${index} step=${step} sendUpdate=${sendUpdate}`)
  }
  // .catch(error => {
  //     bleModule.disconnected();
  //     // if (navigation) {
  //     //     navigation.popToTop()
  //     // }
  //    // console.log(`readNextCharacteristic error=${error}`)
  // });

  Future<void> sendBlock() async {
    suotaManager.sendBlock((chunkNumber, totalChunkCount, chunk, progress) {
      processCallBack(progress, chunkNumber, totalChunkCount);

      List<int> bytes = List<int>.from(chunk);
      debugPrint("sendBlock length ${bytes.length} ");
      blueToothManager
          ?.writeWithoutResponse(SPOTA_PATCH_DATA_UUID, bytes)
          .then((value) {
        Future.delayed(const Duration(milliseconds: 300), () {
          Map intent = {"step": 5};
          processStep(intent);
        });
      }).catchError((error) {
        if (writeFailCallBack != null) {
          writeFailCallBack(error);
        }
      });
    });
  }

  void _initData() {
    // debugPrint("_ringModel=${ringModel}  DEFAULT_MISO_VALUE =$DEFAULT_MISO_VALUE  DEFAULT_MISI_VALUE=$DEFAULT_MISI_VALUE  DEFAULT_CS_VALUE=$DEFAULT_CS_VALUE  DEFAULT_SCK_VALUE=$DEFAULT_SCK_VALUE    ");
    suotaManager.setImageBank(DEFAULT_MEMORY_BANK);
    suotaManager.setMISO_GPIO(DEFAULT_MISO_VALUE);
    suotaManager.setMISI_GPIO(DEFAULT_MISI_VALUE);
    suotaManager.setCS_GPIO(DEFAULT_CS_VALUE);
    suotaManager.setSCK_GPIO(DEFAULT_SCK_VALUE);
    suotaManager.setMemoryType(MEMORY_TYPE_SPI);
  }

  void handleBankChange(itemValue) {
    // setSelectedBank(itemValue);
    suotaManager.setImageBank(itemValue);
  }

  void handleMisoChange(itemValue) {
    suotaManager.setMISO_GPIO(itemValue);
  }

  void startUpdate(bytes) {
    // suotaManager.setMemoryType(suotaManager.memoryType);
    suotaManager.setType(suotaManager.TYPE);
    if (suotaManager.memoryType == MEMORY_TYPE_I2C) {
      try {
        int i2cAddr = int.parse(DEFAULT_I2C_DEVICE_ADDRESS);

        suotaManager.setI2CDeviceAddress(i2cAddr);
      } catch (nfe) {
        // showDialog("I2C Parameter Error,Invalid I2C device address.");
        return;
      }
    }
    int fileBlockSize = 1;
    if (suotaManager.getType() == suotaManager.TYPE) {
      try {
        fileBlockSize = (int.parse(blockSize.toString())).abs();
      } catch (nfe) {
        fileBlockSize = 0;
      }
      if (fileBlockSize == 0) {
        // showDialog("Invalid block size,The block size cannot be zero.");
        debugPrint("Invalid block size,The block size cannot be zero.");
        return;
      }
    }

    suotaManager.fileSetType(suotaManager.TYPE, bytes);
    suotaManager.setFileBlockSize(fileBlockSize, getFileChunkSize());
    var intent = {"action": ACTION_BLUETOOTH_GATT_UPDATE, "step": 1};
    otaStep(intent);
  }

  int getFileChunkSize() {
    int mtus = mtu - 3;
    fileChunkSize = patchDataSize < mtus ? patchDataSize : mtus;
    return fileChunkSize;
  }

  // void setNavigation(nav) {
  //   navigation = nav;
  // }

  // void setFileName(fn) {
  //   fileName = fn;
  // }

  void sendRebootSignal() {
    suotaManager.sendRebootSignal((reboot_signal) {
      var buffer = Uint8List(4).buffer;
      var dataView = ByteData.view(buffer);
      dataView.setUint32(0, reboot_signal, Endian.little);
      blueToothManager
          ?.write(SPOTA_MEM_DEV_UUID, List<int>.from(buffer.asUint8List()))
          .then((value) {})
          .catchError((error) {
        writeFailCallBack(error);
      });
    });
  }

  void setProgressCallBack(callback) {
    processCallBack = callback;
  }

  void setSuccessCallBack(callback) {
    successCallBack = callback;
  }

  void setWriteOTAFail(callback) {
    writeFailCallBack = callback;
  }

  void setDeviceInfoCallBack(callback) {
    callback(deviceInfo);
  }

  // void setInitMemoryType(callback) {
  //   initMemoryTypeCallBack = callback;
  // }

  void initMtuCallback(callback) {
    initMTUCallback = callback;
  }

 
}
