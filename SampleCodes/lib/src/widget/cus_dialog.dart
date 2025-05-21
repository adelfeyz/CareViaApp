import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

enum SPORT {
  MODE,
  TYPE,
  STRENGTH,
}

class CusDialog extends Dialog {
  final String title;
  final Map sportValue;
  final Function onConfirm;
  final List<FMRadioModel> _sport_mode_datas = [];
  final List<FMRadioModel> _sport_type_datas = [];
  final List<FMRadioModel> _sport_strengthGrade = [];

  var modeGroupValue = 0.obs;
  var typeGroupValue = 0.obs;
  var strengthGroupValue = 0.obs;

  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _timeIntervalController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  CusDialog(this.title, this.sportValue, this.onConfirm, {super.key}) {
    _heightController.addListener(() {
      debugPrint(" _heightController=${_heightController.text} ");
      if (_heightController.text.isNotEmpty) {
        sportValue["height"].value = num.parse(_heightController.text);
      }
    });
    _timeIntervalController.addListener(() {
      debugPrint(" _timeIntervalController=${_timeIntervalController.text} ");
      if (_timeIntervalController.text.isNotEmpty) {
        sportValue["timeInterval"].value =
            num.parse(_timeIntervalController.text);
      }
    });
    _durationController.addListener(() {
      debugPrint(" _durationController=${_durationController.text} ");
      if (_durationController.text.isNotEmpty) {
        sportValue["duration"].value = num.parse(_durationController.text);
      }
    });
    initData();
  }

  void initData() {
    _sport_mode_datas.add(FMRadioModel(0, "Sport mode off", 0, SPORT.MODE));
    _sport_mode_datas.add(FMRadioModel(1, "Sport mode on", 1, SPORT.MODE));
    _sport_type_datas.add(FMRadioModel(0, "Other sports", 0, SPORT.TYPE));
    _sport_type_datas.add(FMRadioModel(1, "Run", 1, SPORT.TYPE));

    _sport_strengthGrade
        .add(FMRadioModel(0, "Low intensity exercise", 0.05, SPORT.STRENGTH));
    _sport_strengthGrade.add(
        FMRadioModel(1, "Moderate intensity exercise", 0.08, SPORT.STRENGTH));
    _sport_strengthGrade
        .add(FMRadioModel(2, "High intensity exercise", 0.1, SPORT.STRENGTH));
    sportValue["sportMode"].value = 0;
    sportValue["mode"].value = 0;
    sportValue["strengthGrade"].value = 0.05;
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
                                controller: _heightController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  labelText: "height(cm)",
                                  hintText:
                                      "Please enter your height unit (cm)",
                                ),
                                keyboardType: TextInputType.number,
                              )),
                          SizedBox(
                              width: double.infinity,
                              child: TextField(
                                controller: _timeIntervalController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  labelText: "time interval(s)",
                                  hintText:
                                      "Record data time interval between 10 and 180 seconds",
                                ),
                                keyboardType: TextInputType.number,
                              )),
                          SizedBox(
                              width: double.infinity,
                              child: TextField(
                                controller: _durationController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  labelText: "duration(m)",
                                  hintText: "Duration 5-180 minutes",
                                ),
                                keyboardType: TextInputType.number,
                              )),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                                itemCount: _sport_mode_datas.length,
                                itemBuilder: (context, index) {
                                  FMRadioModel model = _sport_mode_datas[index];
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
                                itemCount: _sport_type_datas.length,
                                itemBuilder: (context, index) {
                                  FMRadioModel model = _sport_type_datas[index];
                                  return _buildRow(model);
                                },
                                scrollDirection: Axis.horizontal),
                          ),
                          const Divider(
                            color: Colors.black54,
                          ),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              itemCount: _sport_strengthGrade.length,
                              itemBuilder: (context, index) {
                                FMRadioModel model =
                                    _sport_strengthGrade[index];
                                return _buildRow(model);
                              },
                            ),
                          ),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                if (sportValue["height"].value != 0 &&
                                        sportValue["timeInterval"].value != 0 &&
                                        sportValue["duration"].value != 0 ||
                                    sportValue["sportMode"].value == 0) {
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
      case SPORT.MODE:
        groupValues = modeGroupValue;
        break;
      case SPORT.TYPE:
        groupValues = typeGroupValue;
        break;
      case SPORT.STRENGTH:
        groupValues = strengthGroupValue;
        break;
    }
    return Obx(() => Radio(
        value: model.index,
        groupValue: groupValues.value,
        onChanged: (index) {
          switch (model.type) {
            case SPORT.MODE:
              sportValue["sportMode"].value = model.value;
              modeGroupValue.value = index!;
              break;
            case SPORT.TYPE:
              sportValue["mode"].value = model.value;
              typeGroupValue.value = index!;
              break;
            case SPORT.STRENGTH:
              sportValue["strengthGrade"].value = model.value;
              strengthGroupValue.value = index!;
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
