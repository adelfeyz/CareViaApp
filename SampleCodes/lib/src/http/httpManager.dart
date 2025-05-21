import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:smartring_plugin/sdk/utils/LogUtil.dart';

import 'httpApi.dart';

enum RingModel {
  // sr09_t,
  // sr23_t,
  // sr26_t,
  // nexring03_t,
  // sr09n_t,
  nexring03,
  sr26,
  sr23,
  sr09,
  sr09n,
}

class HttpManager {
  static final HttpManager _instance = HttpManager._internal();
  static const otaUrl = '/ota/f/';
  static const o2mEcgUrl = '/o2m/ecg/';
  String _saveOtaFilePath = '';

  // 将枚举和字符串对应关系单独存放在一个映射中
  static const Map<RingModel, String> _ringModelMap = {
    RingModel.nexring03: 'bmV4cmluZzAz',
    RingModel.sr26: 'c3IyNg%3D%3D',
    RingModel.sr23: 'c3IyMw%3D%3D',
    RingModel.sr09: 'c3IwOQ%3D%3D',
    RingModel.sr09n: 'c3IwOW4%3D',
  };

  late HttpApi _httpApi;

  static HttpManager getInstance() {
    return _instance;
  }

  HttpManager._internal() {
    _httpApi = HttpApi()..init();
  }
  // 更新 getOtaUrl 方法，使用枚举参数并进行安全校验
  String getOtaUrl({required RingModel model}) {
    final value = _ringModelMap[model];
    if (value == null) {
      throw ArgumentError('Invalid RingModel provided: $model');
    }
    return otaUrl + value;
  }

  String getO2mEcgUrl({
    required String key,
    required String sn,
    required String mac,
    required String secret,
    required bool isSpe,
  }) {
    String sign = generateHmacMd5(sn, mac, secret);
    String type = isSpe ? 'spe' : 'arrhythmia';
    String url = '$o2mEcgUrl$type?_key=$key&sn=$sn&mac=$mac&_sign=$sign';
    return url;
  }

  String generateHmacMd5(String sn, String mac, String secret) {
    // 合并序列号和 MAC 地址
    String message = '$sn,$mac';

    // 创建 HMAC-MD5 哈希
    var hmac = Hmac(md5, utf8.encode(secret)); // 使用 MD5 创建 HMAC
    var digest = hmac.convert(utf8.encode(message)); // 计算哈希值

    // 转换为十六进制字符串
    return digest.toString();
  }

  Future<dynamic> downloadOtaFile({required RingModel model}) async {
    final url = getOtaUrl(model: model);
    final response = await _httpApi.get(url, queryParameters: null);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.data);
      Directory documentsDirectory =
          await path_provider.getApplicationDocumentsDirectory();
      String version = data['ver'];
      _saveOtaFilePath = '${documentsDirectory.path}/$version.img';
      bool isSuccess = false;
      if (data != null) {
        await _httpApi.download(
          data["uri"],
          _saveOtaFilePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              if (received == total) {
                isSuccess = true;
              }
            }
          },
        );
      } else {
        isSuccess = false;
      }
      debugPrint('downloadOtaFile success=$isSuccess');
    }
  }

  Future<dynamic> cloudCalEcg(
      {required String key,
      required String sn,
      required String mac,
      required String secret,
      required bool isSpe,
      required String data}) async {
    _httpApi.dio.options.headers = {
      "Content-Type": "text/plain",
      "Accept-Encoding": "gzip, deflate",
    };
    String url =
        getO2mEcgUrl(key: key, sn: sn, mac: mac, secret: secret, isSpe: isSpe);
    Response<dynamic> response = await _httpApi.dio.post(url, data: data);
    if (response.statusCode == 200) {
      return response.data;
    } else {
      debugPrint(
          'getWebEcgData failed${response.statusCode} ${response.statusMessage}');
      return null;
    }
  }

  //获取ota文件保存路径
  Future<String> getOtaFilePath() async {
    return _saveOtaFilePath;
  }

  //血糖注册设备
  Future<dynamic> registerDevice({
    required String sn,
    required int age,
    required String gender,
    required int weight,
    required int height,
    required int familyHistory,
    required int highCholesterol,
  }) async {
    String url = '/ppg/reg_psn';
    Map<String, dynamic> data = {
      'sn': sn,
      'age': age,
      'gender': gender,
      'weight': weight,
      'height': height,
      'family_history': familyHistory,
      'high_cholesterol': highCholesterol,
    };
    _httpApi.dio.options.headers = {
      "Content-Type": "application/x-www-form-urlencoded",
      "Accept-Encoding": "gzip, deflate",
    };
    Response<dynamic> response = await _httpApi.post(url, data: data);
    if (response.statusCode == 200) {
      return response.data;
    } else {
      debugPrint(
          'registerDevice failed${response.statusCode} ${response.statusMessage}');
      return null;
    }
  }

  //上传ppg测量记录
  Future<dynamic> uploadPpgRecord({
    required bool fasting,
    required bool within2HrsMeal,
    required String startTime,
    required String endTime,
    required List<Map<String, dynamic>> ppgData,
    required String ltk,
  }) async {
    String ltkData = Uri.encodeComponent(ltk);
    String url = '/ppg/new_smp?ltk=$ltkData';
    Map<String, dynamic> data = {
      'fasting': fasting,
      'within2HrsMeal': within2HrsMeal,
      'start': startTime,
      'end': endTime,
      'ppgData': ppgData,
    };
    _httpApi.dio.options.headers = {
      "Content-Type": "application/json",
      "Accept-Encoding": "gzip, deflate",
    };
    debugPrint('uploadPpgRecord data=$data');
    // debugPrint('uploadPpgRecord jsonEncode(data)=${jsonEncode(data)}');
    LogUtil.d('uploadPpgRecord jsonEncode(data)=$data');
    Response<dynamic> response = await _httpApi.post(url, data:data);
    if (response.statusCode == 200) {
      return response.data;
    } else {
      debugPrint(
          'uploadPpgRecord failed${response.statusCode} ${response.statusMessage}');
      return null;
    }
  }

  //获取ppg算法结果
  Future<dynamic> getPpgResult({required String mid})async{
    String midData = Uri.encodeComponent(mid);
    String url = '/ppg/anr_smp?mid=$midData';
    _httpApi.dio.options.headers = {
      "Content-Type": "application/x-www-form-urlencoded",
      "Accept-Encoding": "gzip, deflate",
    };
    Response<dynamic> response = await _httpApi.get(url, queryParameters: null);
    debugPrint('getPpgResult response=$response');
    if (response.statusCode == 200) {
      return response.data;
    } else {
      debugPrint(
          'getPpgResult failed${response.statusCode} ${response.statusMessage}');
      return null;
    }
  }

  //上传vo2数据，获取计算结果
}
