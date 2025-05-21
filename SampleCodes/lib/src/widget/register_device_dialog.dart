import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

enum USER { FAMILY, SEX, CHOLESTEROL }

class RegisterDeviceDialog extends Dialog {
  final String title;
  final Map userInfoValue;
  final Function onConfirm;
  final List<FMRadioModel> _fun_datas = [];
  final List<FMRadioModel> _sex_datas = [];
  final List<FMRadioModel> _cholesterol_datas = [];

  var funGroupValue = 0.obs;
  var sexGroupValue = 0.obs;
  var cholesterolGroupValue = 0.obs;

  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  RegisterDeviceDialog(this.title, this.userInfoValue, this.onConfirm,
      {super.key}) {
    _heightController.addListener(() {
      debugPrint(" _heightController=${_heightController.text} ");
      if (_heightController.text.isNotEmpty) {
        userInfoValue["height"].value = num.parse(_heightController.text);
      }
    });
    _weightController.addListener(() {
      debugPrint(" _weightController=${_weightController.text} ");
      if (_weightController.text.isNotEmpty) {
        userInfoValue["weight"].value = num.parse(_weightController.text);
      }
    });
    _ageController.addListener(() {
      debugPrint(" _ageController=${_ageController.text} ");
      if (_ageController.text.isNotEmpty) {
        userInfoValue["age"].value = num.parse(_ageController.text);
      }
    });
    initData();
  }

  void initData() {
    _fun_datas.add(FMRadioModel(0, "normal", 0, USER.FAMILY));
    _fun_datas.add(FMRadioModel(1, "family diabetes", 1, USER.FAMILY));
    _sex_datas.add(FMRadioModel(0, "male", "M", USER.SEX));
    _sex_datas.add(FMRadioModel(1, "female", "F", USER.SEX));
    _cholesterol_datas.add(FMRadioModel(0, "normal", 0, USER.CHOLESTEROL));
    _cholesterol_datas
        .add(FMRadioModel(1, "High Cholesterol", 1, USER.CHOLESTEROL));
    userInfoValue["family_history"].value = 0;
    userInfoValue["high_cholesterol"].value = 0;
    userInfoValue["sex"].value = "F";
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
                                  labelText: "height(mm)",
                                  hintText:
                                      "Please enter your height unit (mm)",
                                ),
                                keyboardType: TextInputType.number,
                              )),
                          SizedBox(
                              width: double.infinity,
                              child: TextField(
                                controller: _weightController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  labelText: "weight(kg)",
                                  hintText: "Please enter your weight (kg)",
                                ),
                                keyboardType: TextInputType.number,
                              )),
                          SizedBox(
                              width: double.infinity,
                              child: TextField(
                                controller: _ageController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  labelText: "age",
                                  hintText: "Please enter age",
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
                                itemCount: _sex_datas.length,
                                itemBuilder: (context, index) {
                                  FMRadioModel model = _sex_datas[index];
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
                                if ((userInfoValue["height"].value != 0 &&
                                    userInfoValue["weight"].value != 0)) {
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
      case USER.FAMILY:
        groupValues = funGroupValue;
        break;
      case USER.SEX:
        groupValues = sexGroupValue;
        break;
      case USER.CHOLESTEROL:
        groupValues = cholesterolGroupValue;
        break;
    }
    return Obx(() => Radio(
        value: model.index,
        groupValue: groupValues.value,
        onChanged: (index) {
          switch (model.type) {
            case USER.FAMILY:
              userInfoValue["family_history"].value = model.value;
              funGroupValue.value = index!;
              break;
            case USER.SEX:
              userInfoValue["sex"].value = model.value;
              sexGroupValue.value = index!;
              break;
            case USER.CHOLESTEROL:
              userInfoValue["high_cholesterol"].value = model.value;
              cholesterolGroupValue.value = index!;
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
