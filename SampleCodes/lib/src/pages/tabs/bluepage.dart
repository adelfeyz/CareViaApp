import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:smartring_plugin/sdk/core.dart';

import '../../bluetooth/bluetooth_manager.dart';
import '../../pages_data/health_data.dart';
import '../../permission/permission_manager.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class BluePage extends StatefulWidget {
  var tabIndex;

  BluePage({super.key, this.tabIndex});

  @override
  State<BluePage> createState() => _BluePageState();
}

class _BluePageState extends State<BluePage> {
  late BlueToothManager blueToothManager;
  late RxList deviceList;
  RxBool isScan = false.obs;
  late Function scanCallBack;
  late Function connectCallBack;
  BluetoothDevice? connectDevice;
  RxString scanDes = "scan".obs;
  RxBool isShowBtn = false.obs;
  RxBool isBleConnect = false.obs;

  @override
  void initState() {
    super.initState();
    requestBlePermissions();
    initBle();
  }

  void initBle() {
    blueToothManager = BlueToothManager();
    scanCallBack = (isScanning) {
      scanDes.value = isScanning ? "scanning" : "scan";
    };
    blueToothManager.addScanListener(scanCallBack);
    connectCallBack = (device, isConnect) async {
      connectDevice = device;
      isBleConnect.value = isConnect;
      isShowBtn.value = isConnect;
      if (isConnect) {
        BleData bleData = BleData();
        bleData.init();
        await bleData.startOem();
        Future.delayed(const Duration(seconds: 1), () {
          EasyLoading.dismiss();
          widget.tabIndex.value = 1;
        });
      } else {
        blueToothManager.startScan();
        widget.tabIndex.value = 0;
        debugPrint(
            "=================================================isConnect=$isConnect");
      }
    };
    blueToothManager.addConnectListener(connectCallBack);
  }

  List<Widget> blueList() {
    List<Widget> list = [];

    for (var element in deviceList) {
      if (connectDevice == element.device && isBleConnect.value) {
        var ring = RingManager.instance.parseBroadcastData(
            element.advertisementData.manufacturerData?.values.first,
            Platform.isAndroid);
        list.add(TextButton(
          onPressed: () async {
            try {
              EasyLoading.show(status: 'connect...');
              await blueToothManager.stopScan();
              await Future.delayed(const Duration(milliseconds: 1000));
              await blueToothManager.connect(element.device);
              
              blueToothManager.setDeviceName(element.advertisementData);
              Future.delayed(const Duration(seconds: 5), () {
                EasyLoading.dismiss();
              });
            } catch (e) {
              Future.delayed(const Duration(seconds: 5), () {
                EasyLoading.dismiss();
              });
            }
          },
          child: Wrap(
            spacing: 8.0, // 子元素之间的水平间距
            runSpacing: 4.0, // 行与行之间的垂直间距
            alignment: WrapAlignment.center, // 子元素的对齐方式，默认为 WrapAlignment.start
            direction: Axis.horizontal, // 方向，默认为水平方向（Axis.horizontal）
            children: <Widget>[
              Text(
                "DeviceName:${element.advertisementData.localName} Color:${ring["color"]} Size:${ring["size"]}  Mac:${element.device.remoteId} ",
              ),
              Visibility(
                  visible: isShowBtn.value,
                  child: TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.blue[400])),
                    child: const Text("Connected"),
                    onPressed: () async {
                      await blueToothManager.disConnect();
                      isShowBtn.value = false;
                    },
                  ))
              // 更多子Widget...
            ],
          ),
        ));
      } else {
        
        if (element.advertisementData.manufacturerData.values.isNotEmpty) {
          var ring = RingManager.instance.parseBroadcastData(
              element.advertisementData.manufacturerData.values.first,
              Platform.isAndroid);
              // debugPrint(" ring=${ring} element.advertisementData.manufacturerData.values.first=${element} ");
          list.add(TextButton(
            onPressed: () async {
              try {
                EasyLoading.show(status: 'connect...');
                await blueToothManager.stopScan();
                // debugPrint(" connect element=${element.runtimeType}");
                await Future.delayed(const Duration(milliseconds: 1000));
                await blueToothManager.connect(element.device);
                var localName = element.advertisementData.localName;
                blueToothManager.setDeviceName(localName);
                // debugPrint(" element.advertisementData.localName=${element.advertisementData.localName} ");
                // setRingModel(localName.toUpperCase().contains("SR09")?"SR09":"SR23");
                Future.delayed(const Duration(seconds: 5), () {
                  EasyLoading.dismiss();
                });
              } catch (e) {
                Future.delayed(const Duration(seconds: 5), () {
                  EasyLoading.dismiss();
                });
              }
            },
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: Text(
                  "DeviceName:${element.advertisementData.localName} Color:${ring["color"]} Size:${ring["size"]}  Mac:${element.device.remoteId} ${isBleConnect.value ? "" : ""}"),
            ),
          ));
        }
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: ElevatedButton(
              onPressed: () {
                blueToothManager.startScan();
                deviceList = blueToothManager.getDeviceList();
                isScan.value = true;
              },
              child: Obx(() => Text(scanDes.value))),
        ),
        Obx(() => Expanded(
              child: isScan.value
                  ? ListView(
                      children: blueList(),
                    )
                  : Text(""),
            ))
        // SizedBox(
        //       height: 500,
        //       child: isScan.value
        //           ? ListView(
        //               children: blueList(),
        //             )
        //           : Text(""),
        //     )),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    blueToothManager.removeScanListener(scanCallBack);
  }
}
