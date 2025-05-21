import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

enum HrMeasurement {
  MODE,
}

class HrMSettingDailog extends Dialog {
  final String title;
  final Map hrMeasurementSettingValue;
  final List<FMRadioModel> _hr_switch_datas = [];

  var modeGroupValue = 0.obs;
  var startTimeHour = -1;
  var startTimeMinute = -1;
  var startTimeSecond = -1;

  var endTimeHour = -1;
  var endTimeMinute = -1;
  var endTimeSecond = -1;

  final TextEditingController _timeIntervalController = TextEditingController();

  final TextEditingController _startTimeHourController =
      TextEditingController();
  final TextEditingController _startTimeMinuteController =
      TextEditingController();
  final TextEditingController _startTimeSecondController =
      TextEditingController();

  final TextEditingController _endTimeHourController = TextEditingController();
  final TextEditingController _endTimeMinuteController =
      TextEditingController();
  final TextEditingController _endTimeSecondController =
      TextEditingController();

  HrMSettingDailog(this.title, this.hrMeasurementSettingValue, {super.key}) {
    _timeIntervalController.addListener(() {
      // debugPrint(" _timeIntervalController=${_timeIntervalController.text} ");
      if (_timeIntervalController.text.isNotEmpty) {
        hrMeasurementSettingValue["timeInterval"].value =
            num.parse(_timeIntervalController.text);
      }else{
        hrMeasurementSettingValue["timeInterval"].value = -1;
      }
    });
    _startTimeHourController.addListener(() {
      // debugPrint(" _durationController=${_startTimeHourController.text} ");
      if (_startTimeHourController.text.isNotEmpty) {
        startTimeHour = num.parse(_startTimeHourController.text).toInt();
      }else{
        startTimeHour=-1;
      }
    });
    _startTimeMinuteController.addListener(() {
      // debugPrint(" _durationController=${_startTimeMinuteController.text} ");
      if (_startTimeMinuteController.text.isNotEmpty) {
        startTimeMinute = num.parse(_startTimeMinuteController.text).toInt();
      }else{
        startTimeMinute=-1;
      }
    });
    _startTimeSecondController.addListener(() {
      // debugPrint(" _durationController=${_startTimeSecondController.text} ");
      if (_startTimeSecondController.text.isNotEmpty) {
        startTimeSecond = num.parse(_startTimeSecondController.text).toInt();
      }else{
        startTimeSecond=-1;
      }
    });

    _endTimeHourController.addListener(() {
      // debugPrint(" _durationController=${_endTimeHourController.text} ");
      if (_endTimeHourController.text.isNotEmpty) {
        endTimeHour = num.parse(_endTimeHourController.text).toInt();
      }else{
        endTimeHour=-1;
      }
    });
    _endTimeMinuteController.addListener(() {
      // debugPrint(" _durationController=${_endTimeMinuteController.text} ");
      if (_endTimeMinuteController.text.isNotEmpty) {
        endTimeMinute = num.parse(_endTimeMinuteController.text).toInt();
      }else{
        endTimeMinute=-1;
      }
    });
    _endTimeSecondController.addListener(() {
      // debugPrint(" _durationController=${_endTimeSecondController.text} ");
      if (_endTimeSecondController.text.isNotEmpty) {
        endTimeSecond = num.parse(_endTimeSecondController.text).toInt();
      }else{
        endTimeSecond=-1;
      }
    });
    initData();
  }

  void initData() {
    _hr_switch_datas.add(FMRadioModel(0, "switch off", 0, HrMeasurement.MODE));
    _hr_switch_datas.add(FMRadioModel(1, "switch on", 1, HrMeasurement.MODE));

    hrMeasurementSettingValue["switch"].value = 0;
  }

  @override
  Widget build(BuildContext context) {
    // _showTimer(context);
    return Material(
      type: MaterialType.transparency,
      child: Center(
          child: Container(
        height: 730,
        width: 500,
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10),
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(title),
                  ),
                ],
              ),
            ),
            const Divider(),
            Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    // SizedBox(
                    //     width: double.infinity,
                    //     child: Row(
                    //       children: [
                    //         Expanded(
                    //             child: TextField(
                    //           controller: _startTimeHourController,
                    //           inputFormatters: [
                    //             FilteringTextInputFormatter.digitsOnly,
                    //             LengthLimitingTextInputFormatter(2),
                    //             Limit24TextInputFormatter()
                    //           ],
                    //           decoration: const InputDecoration(
                    //             labelText: "startTime hour",
                    //             hintText: "0 to 24",
                    //           ),
                    //           keyboardType: TextInputType.number,
                    //         )),
                    //         Expanded(
                    //             child: TextField(
                    //           controller: _startTimeMinuteController,
                    //           inputFormatters: [
                    //             FilteringTextInputFormatter.digitsOnly,
                    //             LengthLimitingTextInputFormatter(2),
                    //             Limit60TextInputFormatter()
                    //           ],
                    //           decoration: const InputDecoration(
                    //             labelText: "minute",
                    //             hintText: "0 to 60",
                    //           ),
                    //           keyboardType: TextInputType.number,
                    //         )),
                    //         Expanded(
                    //             child: TextField(
                    //           controller: _startTimeSecondController,
                    //           inputFormatters: [
                    //             FilteringTextInputFormatter.digitsOnly,
                    //             LengthLimitingTextInputFormatter(2),
                    //             Limit60TextInputFormatter()
                    //           ],
                    //           decoration: const InputDecoration(
                    //             labelText: "second",
                    //             hintText: "0 to 60",
                    //           ),
                    //           keyboardType: TextInputType.number,
                    //         ))
                    //       ],
                    //     )),
                    // SizedBox(
                    //     width: double.infinity,
                    //     child: Row(
                    //       children: [
                    //         Expanded(
                    //             child: TextField(
                    //           controller: _endTimeHourController,
                    //           inputFormatters: [
                    //             FilteringTextInputFormatter.digitsOnly,
                    //             LengthLimitingTextInputFormatter(2),
                    //             Limit24TextInputFormatter()
                    //           ],
                    //           decoration: const InputDecoration(
                    //             labelText: "end hour",
                    //             hintText: "0 to 24",
                    //           ),
                    //           keyboardType: TextInputType.number,
                    //         )),
                    //         Expanded(
                    //             child: TextField(
                    //           controller: _endTimeMinuteController,
                    //           inputFormatters: [
                    //             FilteringTextInputFormatter.digitsOnly,
                    //             LengthLimitingTextInputFormatter(2),
                    //             Limit60TextInputFormatter()
                    //           ],
                    //           decoration: const InputDecoration(
                    //             labelText: "minute",
                    //             hintText: "0 to 60",
                    //           ),
                    //           keyboardType: TextInputType.number,
                    //         )),
                    //         Expanded(
                    //             child: TextField(
                    //           controller: _endTimeSecondController,
                    //           inputFormatters: [
                    //             FilteringTextInputFormatter.digitsOnly,
                    //             LengthLimitingTextInputFormatter(2),
                    //             Limit60TextInputFormatter()
                    //           ],
                    //           decoration: const InputDecoration(
                    //             labelText: "second",
                    //             hintText: "0 to 60",
                    //           ),
                    //           keyboardType: TextInputType.number,
                    //         ))
                    //       ],
                    //     )),
                    SizedBox(
                        width: double.infinity,
                        child: TextField(
                          controller: _timeIntervalController,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                            Limit360TextInputFormatter(),
                          ],
                          decoration: const InputDecoration(
                            labelText: "time interval(s)",
                            hintText:
                                "5-360min",
                          ),
                          keyboardType: TextInputType.number,
                        )),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                          itemCount: _hr_switch_datas.length,
                          itemBuilder: (context, index) {
                            FMRadioModel model = _hr_switch_datas[index];
                            return _buildRow(model);
                          },
                          scrollDirection: Axis.horizontal),
                    ),
                    const Divider(
                      color: Colors.black54,
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // debugPrint(
                          //     "startTimeHour=${startTimeHour} startTimeMinute=${startTimeMinute} startTimeSecond=${startTimeSecond}");
                          // if(startTimeHour!=-1&&startTimeMinute!=-1&&startTimeSecond!=-1){
                          //   hrMeasurementSettingValue["startTime"].add(startTimeHour);
                          //   hrMeasurementSettingValue["startTime"].add(startTimeMinute);
                          //   hrMeasurementSettingValue["startTime"].add(startTimeSecond);
                          // }    
                          // if(endTimeHour!=-1&&endTimeMinute!=-1&&endTimeSecond!=-1){
                          //   hrMeasurementSettingValue["endTime"].add(endTimeHour);
                          //   hrMeasurementSettingValue["endTime"].add(endTimeMinute);
                          //   hrMeasurementSettingValue["endTime"].add(endTimeSecond);
                          // } 
                          // debugPrint(
                          //     "hrMeasurementSettingValue[startTime]=${hrMeasurementSettingValue["startTime"].value.length} hrMeasurementSettingValue[endTime]=${hrMeasurementSettingValue["endTime"].value} hrMeasurementSettingValue[timeInterval]=${hrMeasurementSettingValue["timeInterval"].value}  hrMeasurementSettingValue[switch].value=${hrMeasurementSettingValue["switch"].value}");
                          if (hrMeasurementSettingValue["switch"].value != 0 &&
                              hrMeasurementSettingValue["timeInterval"].value !=
                                  0 &&hrMeasurementSettingValue["timeInterval"].value>=5
                                  ) {
                            hrMeasurementSettingValue["disable"].value = false;
                          }
                          debugPrint(
                              "${hrMeasurementSettingValue["switch"].value} : ${hrMeasurementSettingValue["timeInterval"].value} ");
                          Navigator.pop(context);
                        },
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.blue[50])),
                        child: const Text("OK"),
                      ),
                    )
                  ],
                ))
          ],
        ),
      )),
    );
  }

  Row _buildRow(FMRadioModel model) {
    return Row(
      children: [_radio(model), Text("${model.text}")],
    );
  }

  _radio(FMRadioModel model) {
    var groupValues = 0.obs;
    switch (model.type) {
      case HrMeasurement.MODE:
        groupValues = modeGroupValue;
        break;
    }
    return Obx(() => Radio(
        value: model.index,
        groupValue: groupValues.value,
        onChanged: (index) {
          switch (model.type) {
            case HrMeasurement.MODE:
              hrMeasurementSettingValue["switch"].value = model.value;
              modeGroupValue.value = index!;
              break;
          }
          // debugPrint(index);
        }));
  }
}

class FMRadioModel extends Object {
  int index;
  String text;
  var value;
  var type;

  FMRadioModel(this.index, this.text, this.value, this.type);
}

class Limit24TextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    int? parsedValue;
    try {
      parsedValue = int.parse(newValue.text);
    } catch (e) {
      if (newValue.text.isEmpty) {
        return newValue;
      } else {
        return oldValue;
      }
    }

    // 检查是否在0-24范围内
    if (parsedValue != null && parsedValue >= 0 && parsedValue <= 24) {
      return newValue.copyWith(
          text: parsedValue.toString(), selection: newValue.selection);
    } else {
      // 如果不在范围内，则保持上一次有效值不变
      return oldValue;
    }
  }
}

class Limit60TextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    int? parsedValue;
    try {
      parsedValue = int.parse(newValue.text);
    } catch (e) {
      if (newValue.text.isEmpty) {
        return newValue;
      } else {
        return oldValue;
      }
    }

    // 检查是否在0-24范围内
    if (parsedValue != null && parsedValue >= 0 && parsedValue <= 60) {
      return newValue.copyWith(
          text: parsedValue.toString(), selection: newValue.selection);
    } else {
      // 如果不在范围内，则保持上一次有效值不变
      return oldValue;
    }
  }
}


class Limit360TextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    int? parsedValue;
    try {
      parsedValue = int.parse(newValue.text);
    } catch (e) {
      if (newValue.text.isEmpty) {
        return newValue;
      } else {
        return oldValue;
      }
    }

    // 检查是否在5-360范围内
    if (parsedValue != null && parsedValue <= 360) {
      return newValue.copyWith(
          text: parsedValue.toString(), selection: newValue.selection);
    } else {
      // 如果不在范围内，则保持上一次有效值不变
      return oldValue;
    }
  }
}