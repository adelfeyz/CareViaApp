import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartring_flutter/src/http/httpManager.dart';

class BloodGlucoseController extends GetxController {
  String ltk = '';
  int lease = -1;
  String mid = '';
  HttpManager httpManager = HttpManager.getInstance();

  Future<dynamic> registerDevice(
      {required String sn,
      required int age,
      required String gender,
      required int height,
      required int weight,
      required int familyHistory,
      required int highCholesterol}) async {
    return await httpManager
        .registerDevice(
            sn: sn,
            age: age,
            gender: gender,
            height: height,
            weight: weight,
            familyHistory: familyHistory,
            highCholesterol: highCholesterol)
        .then((value) {
      Map<String, dynamic> data = jsonDecode(value);
      if (data['state'] == 0) {
        ltk = data['ltk'];
        lease = data['lease'];
        return "Registration successful";
      } else if (data['state'] == 1) {
        return "Upstream error";
      } else if (data['state'] == 2) {
        return "Invalid SN";
      }
    });
  }

  Future<dynamic> uploadPpgRecord({
    required bool fasting,
    required bool within2HrsMeal,
    required String startTime,
    required String endTime,
    required List<Map<String, dynamic>> ppgData,
  }) async {
    if (ltk.isEmpty || lease == -1) {
      debugPrint('Please register device first');
      return;
    }
    return await httpManager
        .uploadPpgRecord(
            fasting: fasting,
            within2HrsMeal: within2HrsMeal,
            startTime: startTime,
            endTime: endTime,
            ppgData: ppgData,
            ltk: ltk)
        .then((value) {
      Map<String, dynamic> data = jsonDecode(value);
      if (data['state'] == 0) {
        mid = data['mid'];
        return "Upload successful";
      } else if (data['state'] == 1) {
        return "Invalid lease";
      }
    });
  }

  Future<dynamic> getPpgResult() async {
    if (mid.isEmpty) {
      debugPrint('Please upload PPG measurement record first');
      return null;
    }
    return httpManager.getPpgResult(mid: mid).then((value) {
      Map<String, dynamic> data = jsonDecode(value);
      if (data['state'] == 0) {
        return data;
      } else if (data['state'] == 1) {
        return "SN not registered";
      }
    });
  }
}
