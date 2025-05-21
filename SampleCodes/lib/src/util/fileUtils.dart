import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:get/get.dart';
import 'package:smartring_flutter/src/hive/model/history_model.dart';
import 'package:share_extend/share_extend.dart';
import 'package:smartring_flutter/src/hive/model/pressure_model.dart';
import 'package:smartring_plugin/smartring_plugin_bindings_generated.dart';

import '../hive/model/sleep_model.dart';
import '../http/httpManager.dart';

Map result = {"fileName": "".obs, "bytes": Uint8List(0).obs};

RingModel ringModel = RingModel.sr09n;
Future<void> getOtaBytes() async {
  FlutterDocumentPickerParams? params = FlutterDocumentPickerParams(
      // 允许选取的文件拓展类型，不加此属性则默认支持所有类型
      // allowedFileExtensions: ['pdf', 'xls', 'xlsx', 'jpg', 'png', 'jpeg'],
      );

  String? path = await FlutterDocumentPicker.openDocument(
    params: params,
  );
  String? fileName = path?.split('/').last;
  // debugPrint('path=$path');

  if (path != null) {
    File file = File(path);
    result["fileName"].value = fileName;
    result["bytes"].value = file.readAsBytesSync();
    // return {"fileName": fileName, "bytes": file.readAsBytesSync().toList()};
  }
}

Future<void> getOtaBytesFromWeb() async {
  String path = await fromWebDownloadOtaFile(ringModel);
  if (path != null) {
    File file = File(path);
    result["fileName"].value = ringModel.name;
    result["bytes"].value = file.readAsBytesSync();
    debugPrint(
        'path=$path result["bytes"].value=${result["bytes"].value.length}');
    // return {"fileName": fileName, "bytes": file.readAsBytesSync().toList()};
  }
}

void setOtaModel(RingModel model) {
  ringModel = model;
}

Future<String> fromWebDownloadOtaFile(RingModel ringModel) async {
  final httpManager = HttpManager.getInstance();
  await httpManager.downloadOtaFile(model: ringModel);
  return httpManager.getOtaFilePath();
}

Future<void> shareFile() async {
  HistoryModel historyModel = await HistoryModel.getInstance();
  String jsonString = await historyModel.getAllHistoryDataToJson();
  String formattedJsonString = jsonString.replaceAll('\n', '\n\t');
  // debugPrint('formattedJsonString=$formattedJsonString');
  Directory documentsDirectory =
      await path_provider.getApplicationDocumentsDirectory();
  String filePath = '${documentsDirectory.path}/data.json';
  // debugPrint('filePath=$filePath');
  File file = File(filePath);
  await file.writeAsString(formattedJsonString);

  await ShareExtend.share(filePath, 'file');
  // ShareFile(file.path);
}

Future<void> saveHistoryDataFile() async {
  HistoryModel historyModel = await HistoryModel.getInstance();
  String jsonString = await historyModel.getAllHistoryDataToJson();
  String formattedJsonString = jsonString.replaceAll('\n', '\n\t');
  // debugPrint('formattedJsonString=$formattedJsonString');
  Directory documentsDirectory =
      await path_provider.getApplicationDocumentsDirectory();
  String filePath = '${documentsDirectory.path}/history_data.json';
  // debugPrint('filePath=$filePath');
  File file = File(filePath);
  await file.writeAsString(formattedJsonString);
}

Future<void> saveSleepDataFile() async {
  SleepModel sleepModel = await SleepModel.getInstance();
  String jsonString = await sleepModel.getAllSleepDataToJson();
  String formattedJsonString = jsonString.replaceAll('\n', '\n\t');
  // debugPrint('formattedJsonString=$formattedJsonString');
  Directory documentsDirectory =
      await path_provider.getApplicationDocumentsDirectory();
  String filePath = '${documentsDirectory.path}/sleep_data.json';
  // debugPrint('filePath=$filePath');
  File file = File(filePath);
  await file.writeAsString(formattedJsonString);
}

Future<void> saveJsonDataToFile(String json) async {
  SleepModel sleepModel = await SleepModel.getInstance();
  String formattedJsonString = json.replaceAll('\n', '\n\t');
  // debugPrint('formattedJsonString=$formattedJsonString');
  Directory documentsDirectory =
      await path_provider.getApplicationDocumentsDirectory();
  String filePath = '${documentsDirectory.path}/test_data.json';
  // debugPrint('filePath=$filePath');
  File file = File(filePath);
  await file.writeAsString(formattedJsonString);
}

// Future<void> saveFile(DateTime dateTime) async {
//   // debugPrint('saveFile');
//   PressureModel pressureModel = await PressureModel.getInstance();
//   String jsonString = await pressureModel.getDataByPressureToJson(dateTime);
//   String formattedJsonString = jsonString.replaceAll('\n', '\n\t');
//   // debugPrint('formattedJsonString=$formattedJsonString');
//   Directory documentsDirectory =
//       await path_provider.getApplicationDocumentsDirectory();
//   String filePath = '${documentsDirectory.path}/data.json';
//   // debugPrint('filePath=$filePath');
//   File file = File(filePath);
//   await file.writeAsString(formattedJsonString);
// }
