import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

enum USER {
  FUN,
  TYPE,
}

class MeasureTimingDialog extends Dialog {
  final String title;
  final Map measureTimingValue;
  final Function onConfirm;
  final List<FMRadioModel> _fun_datas = [];
  final List<FMRadioModel> _type_datas = [];

  final funGroupValue = 0.obs;
  final typeGroupValue = 0.obs;

  final TextEditingController _time1Controller = TextEditingController();
  final TextEditingController _time1IntervalController =
      TextEditingController();
  final TextEditingController _time2Controller = TextEditingController();
  final TextEditingController _time2IntervalController =
      TextEditingController();
    final TextEditingController _time3IntervalController = TextEditingController();    
  MeasureTimingDialog(this.title, this.measureTimingValue, this.onConfirm,
      {super.key}) {
    _time1Controller.addListener(() {
      debugPrint(" _time1Controller=${_time1Controller.text} ");
      if (_time1Controller.text.isNotEmpty) {
        measureTimingValue["time1"].value = num.parse(_time1Controller.text);
      }
    });
    _time1IntervalController.addListener(() {
      debugPrint(" _time1IntervalController=${_time1IntervalController.text} ");
      if (_time1IntervalController.text.isNotEmpty) {
        measureTimingValue["time1Interval"].value =
            num.parse(_time1IntervalController.text);
      }
    });
    _time2Controller.addListener(() {
      debugPrint(" _time2Controller=${_time2Controller.text} ");
      if (_time2Controller.text.isNotEmpty) {
        measureTimingValue["time2"].value = num.parse(_time2Controller.text);
      }
    });
    _time2IntervalController.addListener(() {
      debugPrint(" _time2IntervalController=${_time2IntervalController.text} ");
      if (_time2IntervalController.text.isNotEmpty) {
        measureTimingValue["time2Interval"].value =
            num.parse(_time2IntervalController.text);
      }
    });
    _time3IntervalController.addListener(() {
      debugPrint(" _time3IntervalController=${_time3IntervalController.text} ");
      if (_time3IntervalController.text.isNotEmpty) {
        measureTimingValue["time3Interval"].value = num.parse(_time3IntervalController.text);
      }
    });
    initData();
  }

  void initData() {
    _fun_datas.add(FMRadioModel(0, "get", 0, USER.FUN));
    _fun_datas.add(FMRadioModel(1, "set", 1, USER.FUN));
    _type_datas.add(FMRadioModel(0, "heart rate", 0, USER.TYPE));
    _type_datas.add(FMRadioModel(1, "Blood oxygen", 1, USER.TYPE));

    measureTimingValue["function"].value = 0;
    measureTimingValue["type"].value = 0;
  }

  @override
  Widget build(BuildContext context) {
    // _showTimer(context);
    return Material(
        type: MaterialType.transparency,
        child: ListView(
          children: [
            Center(
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
                          SizedBox(
                              width: double.infinity,
                              child: TextField(
                                controller: _time1Controller,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  labelText: "time1",
                                  hintText: "Please enter time1 (10-120)s",
                                ),
                                keyboardType: TextInputType.number,
                              )),
                          SizedBox(
                              width: double.infinity,
                              child: TextField(
                                controller: _time1IntervalController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  labelText: "time1Interval",
                                  hintText:
                                      "Please enter time1 interval (0-65535)s",
                                ),
                                keyboardType: TextInputType.number,
                              )),
                          SizedBox(
                              width: double.infinity,
                              child: TextField(
                                controller: _time2Controller,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  labelText: "time2",
                                  hintText: "Please enter time2 (10-120)s",
                                ),
                                keyboardType: TextInputType.number,
                              )),
                          SizedBox(
                              width: double.infinity,
                              child: TextField(
                                controller: _time2IntervalController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  labelText: "time2Interval",
                                  hintText:
                                      "Please enter time2 interval (0-65535)s",
                                ),
                                keyboardType: TextInputType.number,
                              )),
                          SizedBox(
                              width: double.infinity,
                              child: TextField(
                                controller: _time3IntervalController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  labelText: "time3Interval",
                                  hintText:
                                      "Please enter time3 interval (0-255)minute",
                                ),
                                keyboardType: TextInputType.number,
                              )),    
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                                itemCount: _fun_datas.length,
                                itemBuilder: (context, index) {
                                  FMRadioModel model = _fun_datas[index];
                                  return _buildRow(model);
                                },
                                scrollDirection: Axis.horizontal),
                          ),
                          const Divider(
                            color: Colors.black54,
                          ),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                                itemCount: _type_datas.length,
                                itemBuilder: (context, index) {
                                  FMRadioModel model = _type_datas[index];
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
                                if ((measureTimingValue["time1"].value != 0 &&
                                        measureTimingValue["time1Interval"]
                                                .value !=
                                            0 &&
                                        measureTimingValue["time2"].value != 0 &&
                                        measureTimingValue["time2Interval"]
                                                .value !=
                                            0&&measureTimingValue["time3Interval"]
                                                .value !=
                                            0) ||
                                    measureTimingValue["function"] == 0) {
                                  onConfirm(true);
                                } else {
                                  onConfirm(false);
                                }
                                Navigator.pop(context);
                              },
                              style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                      Colors.blue[50])),
                              child: const Text("OK"),
                            ),
                          )
                        ],
                      ))
                ],
              ),
            )),
          ],
        ));
  }

  Row _buildRow(FMRadioModel model) {
    return Row(
      children: [_radio(model), Text("${model.text}")],
    );
  }

  _radio(FMRadioModel model) {
    var groupValues = 0.obs;
    switch (model.type) {
      case USER.FUN:
        groupValues = funGroupValue;
        break;
      case USER.TYPE:
        groupValues = typeGroupValue;
        break;
    }
    return Obx(() => Radio(
        value: model.index,
        groupValue: groupValues.value,
        onChanged: (index) {
          switch (model.type) {
            case USER.FUN:
              measureTimingValue["function"].value = model.value;
              funGroupValue.value = index!;
              break;
            case USER.TYPE:
              measureTimingValue["type"].value = model.value;
              typeGroupValue.value = index!;
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
