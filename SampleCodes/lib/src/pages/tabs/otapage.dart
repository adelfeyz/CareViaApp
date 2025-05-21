import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartring_flutter/src/util/otaUtil.dart';
import '../../http/httpManager.dart';
import '../../util/fileUtils.dart' as FileUtils;
import '../../pages_data/ota_data.dart';

class OtaPage extends StatefulWidget {
  const OtaPage({super.key});

  @override
  State<OtaPage> createState() => _OtaPageState();
}

class _OtaPageState extends State<OtaPage> with SingleTickerProviderStateMixin {
  late OtaData otaData;
  RxBool isShowOtaBtn = false.obs;
  var progressValue;
  var chunkNumberVlue = 0.obs;
  var totalChunkCountValue = 0.obs;
  var isStartInit = false.obs;
  var selectedValue = RingModel.sr09n.obs;

  @override
  void initState() {
    super.initState();
    otaData = OtaData();
    initData();
    registerErrorListener(errorListener);
    otaData.initMtuCallback(() {
      Future.delayed(const Duration(seconds: 2), () {
        isShowOtaBtn.value = true;
        isStartInit.value = false;
      });
    });
    otaData.setWriteOTAFail((error) {
      debugPrint(" WriteOTAFail====$error  ");
    });
    otaData.setProgressCallBack((progress, chunkNumber, totalChunkCount) {
      progressValue = progress;
      chunkNumberVlue.value = chunkNumber;
      totalChunkCountValue.value = totalChunkCount;
      // debugPrint(
      //     "progress=${progress} chunkNumber=${chunkNumber} totalChunkCount=${totalChunkCount} ");
    });
    otaData.setSuccessCallBack(() {
      _initDialog();
    });
  }

  void initData() {
    progressValue = 0.0;
    isShowOtaBtn.value = false;
    chunkNumberVlue.value = 0;
    totalChunkCountValue.value = 0;
  }

  void _initDialog() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("OTA"),
            content: const Text("Device needs to be restarted"),
            actions: [
              TextButton(
                  onPressed: () {
                    initData();
                    otaData.sendRebootSignal();
                    Navigator.of(context).pop("ok");
                  },
                  child: const Text("OK")),
            ],
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
    unRegisterErrorListener(errorListener);
  }

  void errorListener(data) {
    debugPrint("   error====data=$data");
  }

  List<DropdownMenuItem<RingModel>>? _buildDropDownMenuItems() {
    return <RingModel>[
      RingModel.nexring03,
      RingModel.sr09,
      RingModel.sr09n,
      RingModel.sr23,
      RingModel.sr26,
    ].map<DropdownMenuItem<RingModel>>((RingModel value) {
      return DropdownMenuItem<RingModel>(
        value: value,
        child: Text(value.name),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Text("1. Select a local OTA file"),
              Obx(() => ElevatedButton(
                  onPressed: isStartInit.value
                      ? null
                      : () async {
                          isStartInit.value = true;
                          await FileUtils.getOtaBytes();
                          otaData.init();
                        },
                  child: const Text("OtaFileForLocal"))),
              Text("2. Select a network OTA file"),
              Obx(() => Center(
                    child: DropdownButton<RingModel>(
                      value: selectedValue.value, // 初始化显示的文本
                      items: _buildDropDownMenuItems(),
                      onChanged: (value) {
                        selectedValue.value = value!;
                        FileUtils.setOtaModel(value!);
                      },
                    ),
                  )),
              Obx(() => ElevatedButton(
                  onPressed: isStartInit.value
                      ? null
                      : () async {
                          isStartInit.value = true;
                          await FileUtils.getOtaBytesFromWeb();
                          otaData.init();
                        },
                  child: const Text("OtaFileFormWeb"))),
              Obx(() => Text(
                    " ${FileUtils.result["fileName"]}",
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  )),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Obx(() => Column(
              children: [
                Text(
                    "CurrentBlock:${chunkNumberVlue.value}/TotalBlock:${totalChunkCountValue.value}"),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.black, // 背景颜色
                    valueColor:
                        const AlwaysStoppedAnimation(Colors.red), // 进度动画颜色
                    value: progressValue, // 如果进度是确定的，那么可以设置进度百分比，0-1
                  ),
                )
              ],
            )),
        Obx(() => Visibility(
            visible: isShowOtaBtn.value,
            child: ElevatedButton(
                onPressed: () {
                  otaData.startUpdate(FileUtils.result["bytes"].value);
                  // Get.toNamed("/otadetail", arguments: {"title": "routes"});
                },
                child: const Text("startOTA"))))
      ],
    );
  }
}
