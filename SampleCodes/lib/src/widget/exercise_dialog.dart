import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

enum EXERCISE {
  FUN,
  TYPE,
  POOL_SIZE,
}

class ExerciseDialog extends Dialog {
  final String title;
  final Map exerciseValue;
  final Function onConfirm;
  final List<FMRadioModel> _fun_datas = [];
  final List<FMRadioModel> _type_datas = [];
  final List<FMRadioModel> _pool_size_datas = [];

  final funGroupValue = 0.obs;
  final typeGroupValue = 0.obs;
  final poolSizeGroupValue = 0.obs;

  final TextEditingController _trainingTimeController = TextEditingController();

  ExerciseDialog(this.title, this.exerciseValue, this.onConfirm,
      {super.key}) {
    _trainingTimeController.addListener(() {
      debugPrint(" _trainingTimeController=${_trainingTimeController.text} ");
      if (_trainingTimeController.text.isNotEmpty) {
        exerciseValue["exerciseTime"].value =
            num.parse(_trainingTimeController.text);
      }
    });

    initData();
  }

  void initData() {
    _fun_datas.add(FMRadioModel(0, "off", 0, EXERCISE.FUN));
    _fun_datas.add(FMRadioModel(1, "on", 1, EXERCISE.FUN));
    _fun_datas.add(FMRadioModel(2, "pause", 2, EXERCISE.FUN));
    _fun_datas.add(FMRadioModel(3, "continue", 3, EXERCISE.FUN));
    _type_datas.add(FMRadioModel(0, "other", 0, EXERCISE.TYPE));
    _type_datas.add(FMRadioModel(1, "run", 1, EXERCISE.TYPE));
    _type_datas.add(FMRadioModel(2, "walk", 2, EXERCISE.TYPE));
    _type_datas.add(FMRadioModel(3, "SwimmingPoolSwimming", 3, EXERCISE.TYPE));
    _type_datas.add(FMRadioModel(4, "OpenWaterSwimming", 4, EXERCISE.TYPE));
    _type_datas.add(FMRadioModel(5, "IndoorCycling", 5, EXERCISE.TYPE));
    _type_datas.add(FMRadioModel(6, "OutdoorCycling", 6, EXERCISE.TYPE));
    _type_datas.add(FMRadioModel(7, "yoga", 7, EXERCISE.TYPE));
    _type_datas.add(FMRadioModel(8, "mindful", 8, EXERCISE.TYPE));
    _pool_size_datas.add(FMRadioModel(0, "unknown", 0, EXERCISE.POOL_SIZE));
    _pool_size_datas.add(FMRadioModel(1, "25m", 1, EXERCISE.POOL_SIZE));
    _pool_size_datas.add(FMRadioModel(2, "50m", 2, EXERCISE.POOL_SIZE));
    _pool_size_datas.add(FMRadioModel(3, "other", 3, EXERCISE.POOL_SIZE));
    exerciseValue["function"].value = 0;
    exerciseValue["type"].value = 0;
    exerciseValue["poolSize"].value = 0;
  }

  @override
  Widget build(BuildContext context) {
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
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                                itemCount: _pool_size_datas.length,
                                itemBuilder: (context, index) {
                                  FMRadioModel model = _pool_size_datas[index];
                                  return _buildRow(model);
                                },
                                scrollDirection: Axis.horizontal),
                          ),
                          const Divider(
                            color: Colors.black54,
                          ),
                          SizedBox(
                              width: double.infinity,
                              child: TextField(
                                controller: _trainingTimeController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  labelText: "training time",
                                  hintText:
                                      "Please enter training time (1-65535)m",
                                ),
                                keyboardType: TextInputType.number,
                              )),
                         
                          Center(
                            child: TextButton(
                              onPressed: () {
                                if (exerciseValue["exerciseTime"].value != 0 ) {
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
      case EXERCISE.FUN:
        groupValues = funGroupValue;
        break;
      case EXERCISE.TYPE:
        groupValues = typeGroupValue;
        break;
      case EXERCISE.POOL_SIZE:
        groupValues = poolSizeGroupValue;
    }
    return Obx(() => Radio(
        value: model.index,
        groupValue: groupValues.value,
        onChanged: (index) {
          switch (model.type) {
            case EXERCISE.FUN:
              exerciseValue["function"].value = model.value;
              funGroupValue.value = index!;
              break;
            case EXERCISE.TYPE:
              exerciseValue["type"].value = model.value;
              typeGroupValue.value = index!;
              break;
            case EXERCISE.POOL_SIZE:
              exerciseValue["poolSize"].value = model.value;
              poolSizeGroupValue.value = index!;
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
