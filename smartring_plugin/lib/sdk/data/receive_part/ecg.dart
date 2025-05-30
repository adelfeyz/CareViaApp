import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class EcgManager {
  static final EcgManager _instance = EcgManager._internal();

  factory EcgManager() {
    return _instance;
  }

  EcgManager._internal();

  int ecgStageFlag = 0;
  int dataEcg = 0;
  List outputPkg = [];
  int pkgLen = 128;
  int pkgIndex = 0;
  bool outputArrayData = false;
  bool outputRawData = false;
  int ecgStep = 0;
  bool isFingerTouchOnSensor = false;
  List acArray = [];
  int start = 0;
  int AClength = 81;
  List sList = [];
  double interval = 1000 / 512;
  List positiveList = [];
  int maxNum = 0;
  int diffvalue = 0;
  int upIndex = 0;
  int oldIndex = 0;
  int currentDate = 0;
  int rrValue = 0;

  List dataList = [
    0.000011230602022823787,
    0.000017414054671167929,
    0.000019923116601339029,
    0.0000086332433303881605,
    -0.000023234294223847249,
    -0.000074908087367178455,
    -0.00013262618686504132,
    -0.00016801372487440915,
    -0.00014350264224290696,
    -0.000026029138045401449,
    0.00019336238080452125,
    0.00048049009747058258,
    0.00074899592149946974,
    0.00087041608237504694,
    0.0007080864927566608,
    0.00017096157468321493,
    -0.00072649684610744526,
    -0.0018207073366716922,
    -0.0027957666195870942,
    -0.0032380344734955551,
    -0.002749639848182966,
    -0.0010999707178020724,
    0.0016267992129106244,
    0.0049423355799648669,
    0.0079733462616849316,
    0.0096171774905760773,
    0.0088236521534882772,
    0.0049488034385252559,
    -0.0019105714761323122,
    -0.010708187744430818,
    -0.019457127225463881,
    -0.025502031040088011,
    -0.026032125516017003,
    -0.018739797612707099,
    -0.0024735689437121421,
    0.022285806500565011,
    0.053271460298298136,
    0.086674925719500168,
    0.11776860761519668,
    0.14178687635268927,
    0.15487303526751381,
    0.15487303526751381,
    0.14178687635268927,
    0.11776860761519668,
    0.086674925719500168,
    0.053271460298298136,
    0.022285806500565011,
    -0.0024735689437121421,
    -0.018739797612707099,
    -0.026032125516017003,
    -0.025502031040088011,
    -0.019457127225463881,
    -0.010708187744430818,
    -0.0019105714761323122,
    0.0049488034385252559,
    0.0088236521534882772,
    0.0096171774905760773,
    0.0079733462616849316,
    0.0049423355799648669,
    0.0016267992129106244,
    -0.0010999707178020724,
    -0.002749639848182966,
    -0.0032380344734955551,
    -0.0027957666195870942,
    -0.0018207073366716922,
    -0.00072649684610744526,
    0.00017096157468321493,
    0.0007080864927566608,
    0.00087041608237504694,
    0.00074899592149946974,
    0.00048049009747058258,
    0.00019336238080452125,
    -0.000026029138045401449,
    -0.00014350264224290696,
    -0.00016801372487440915,
    -0.00013262618686504132,
    -0.000074908087367178455,
    -0.000023234294223847249,
    0.0000086332433303881605,
    0.000019923116601339029,
    0.000017414054671167929,
    0.000011230602022823787,
  ];

  int startEcg() {
    outputArrayData = false;
    outputRawData = false; //可定义接口控制
    ecgStageFlag = 0;
    ecgStep = 1;
    start = 0;
    return ecgStep;
  }

  void stopEcg() {
    if (isFingerTouchOnSensor) {
      //代表正在测量中
      isFingerTouchOnSensor = false;
    }
    ecgStep = 0;
    ecgStageFlag = 0;
    start = 0;
  }

  int getStep() {
    return ecgStep;
  }

  getUnsignedByte(num) {
    if (num is int) {
      return num & 0xff;
    }
    debugPrint("The Data Is invalid");
    return Exception("IllegalParameter Exception");
  }

  double avg(List array) {
    int sum = array.reduce((value, element) => value + element);
    //封装求平均值函数
    int len = array.length;
    return sum / len;
  }

  double getAC(data) {
    double data_ = 0;
    acArray.add(data);
    if (acArray.length > AClength) {
      acArray.removeAt(0);
    }
    if (acArray.length == AClength) {
      data_ = avg(acArray) - acArray[((AClength - 1) ~/ 2)];
    }
    return data_;
  }

  List alist(data) {
    sList.add(data);
    if (sList.length > 82) {
      sList.removeAt(0);
    }
    return sList;
  }

  double filter(data) {
    double filterData = 0;
    List list = alist(data);
    if (list.length == 82) {
      for (int i = 0; i < list.length; i++) {
        filterData += dataList[i] * list[i];
      }
    }
    return filterData;
  }

  Map getMaxIndexAndValue(List arr) {
    var max = arr[0];
    //声明了个变量 保存下标值
    int index = 0;
    for (int i = 0; i < arr.length; i++) {
      if (max < arr[i]) {
        max = arr[i];
        index = i;
      }
    }
    return {
      "value_max": max,
      "index_max": index,
    };
  }

  /// 按分钟３０～１８０的心率，换算成ppi （６０／３０＊１０００每毫秒６０/180*1000）  最终ppi范围为３３３～２０００
  /// @param {*} value
  getPPI(value) {
    return value * interval;
  }

  int getHeartRate(double ppi) {
    return ((60 * 1000) / ppi).truncate();
  }

  int standardDeviation(arr) {
    var sampleAvg1 = (avg(arr) * 100).round() / 100;
    int len = arr.length;
    List temp =
        List.generate(len, (index) => 0); //定义一个临时空数组，用来存储每个数组元素与平均值的差的平方。
    for (int i = 0; i < len; i++) {
      var dev = double.parse(arr[i].toString()) - sampleAvg1; //计算数组元素与平均值的差
      // eslint-disable-next-line no-restricted-properties
      temp[i] = pow(dev, 2); //计算差的平方
    }
    double powSum = 0; //用来存储差的平方总和

    for (int j = 0; j < temp.length; j++) {
      if (temp[j].toString() != "" ) {
        powSum = double.parse(powSum.toString()) +
            double.parse(temp[j].toString()); //计算差的平方总和
      }
    }
    var stddev =
        (sqrt(double.parse(powSum.toString()) / double.parse(len.toString())) *
                    100)
                .round() /
            100; //用差的平方总和除以数组长度即可得到标准差
    return stddev.truncate();
  }

  int getHRV(List arr) {
    return ((standardDeviation(arr) / avg(arr)) * 1000).truncate();
  }

  List diff(List arr) {
    List list = [];
    for (int index = 0; index < arr.length - 1; index++) {
      var diff = arr[index + 1] - arr[index];
      list.add(diff);
    }
    return list;
  }

  calculateRMS(List arr) {
    var Squares = arr.map((val) => val * val);
    var Sum = Squares.reduce((acum, val) => acum + val);
    var Mean = Sum / arr.length;
    return sqrt(Mean);
  }

  sdnn(List arr) {
    return standardDeviation(arr);
  }

  rmssd(List arr) {
    List list = diff(arr);
    return (calculateRMS(list) * interval).truncate();
  }

  mean(List arr) {
    return (avg(arr)).truncate();
  }

  std(List arr) {
    return standardDeviation(arr);
  }

  sdnnIndex(List arr) {
    var list = diff(arr);
    return standardDeviation(list);
  }

  calPeak(data, totalList) {
    if (data <= 0) {
      if (positiveList.isNotEmpty) {
        // eslint-disable-next-line camelcase
        var maxIndex = getMaxIndexAndValue(positiveList);
        var value_max = maxIndex["value_max"];
        int index_max = maxIndex["index_max"];
        // let max = Math.max(...positiveList);
        // eslint-disable-next-line camelcase
        if (value_max > 3000) {
          //大于３０００才认为该数值为峰值

          if (maxNum != 0) {
            //第二个以后峰值
            // eslint-disable-next-line camelcase
            upIndex += index_max + 1;
            diffvalue = upIndex - oldIndex;
            oldIndex = upIndex;
            totalList.push(diffvalue * interval); //保存２个峰值之间的数据数差值
            // console.log(
            //     `currentDate:${currentDate}  Date.now():${Date.now()}  rrValue：${rrValue}`
            // );
            rrValue = DateTime.now().millisecondsSinceEpoch - currentDate;
            currentDate = DateTime.now().millisecondsSinceEpoch;
          } else {
            currentDate = DateTime.now().millisecondsSinceEpoch;

            //第一个峰值
            maxNum++;
            // eslint-disable-next-line camelcase
            upIndex =
                positiveList.length - index_max - 1; //计算当前峰值的时候，距离下一个峰值的数据个数
          }
        } else if (upIndex != 0) {
          upIndex += positiveList.length;
        }

        if (totalList.length == 10) {
          //计算１０个峰值差的平均值
          var ppi = avg(totalList);
          // const ppi = getPPI(avgValue);
          var hrValue = getHeartRate(ppi);
          var hrvValue = getHRV(totalList);
          var rmssdValue = rmssd(totalList);
          var sdnnValue = sdnn(totalList);
          var meanValue = mean(totalList);
          var stdValue = std(totalList);
          var sdnnIndexValue = sdnnIndex(totalList);

          // eslint-disable-next-line no-param-reassign
          totalList.removeAt(0);
          return {
            // eslint-disable-next-line radix
            "ppi": int.parse(ppi.toString()),
            "hr": hrValue,
            "hrv": hrvValue,
            "rmssd": rmssdValue,
            "sdnn": sdnnValue,
            "mean": meanValue,
            "std": stdValue,
            "sdnnIndex": sdnnIndexValue,
            "rr": rrValue,
          };
        }
      }

      if (upIndex != 0) {
        upIndex++;
      }
      // isPositiveData = false;
      positiveList = [];
    } else if (data > 0) {
      positiveList.add(data);
      // isPositiveData = true;
    }
  }

  

  dealEcg(raw) {
    // const byteLength = raw.byteLength;
    // let dataView = new DataView(raw);
    Int8List data = Int8List.fromList(raw);
    for (var item in data) {
      int dataRec = getUnsignedByte(item);
      if (ecgStageFlag == 0) {
        if (dataRec == 0xaa) {
          ecgStageFlag++;
        }
      } else if (ecgStageFlag == 1) {
        if (dataRec == 0xaa) {
          ecgStageFlag++;
        } else {
          ecgStageFlag = 0;
        }
      } else if (ecgStageFlag == 2) {
        if (dataRec == 0x12) {
          ecgStageFlag++;
        } else {
          ecgStageFlag = 0;
        }
      } else if (ecgStageFlag == 3) {
        if (dataRec == 0x02) {
          ecgStageFlag++;
          //包头
        } else {
          // console.log("  >>>>>>>>>>>>>>  ecgStageFlag =0=");
          ecgStageFlag = 0;
        }
      } else if (ecgStageFlag == 4) {
        // console.log("  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>dataRec=" + dataRec)
        if (dataRec == 0x00) {
          // console.log("  >>>>>>111>>>>isFingerTouchOnSensor=" + isFingerTouchOnSensor + "  outputRawData=" + outputRawData)
          //                    BleDevLog.e("CCL", "手指离开ECG传感器");
          if (isFingerTouchOnSensor && !outputRawData) {
            //手指由接触转未接触时，暂停计算
            // NskAlgoSdk.NskAlgoPause();
            // NskAlgoSdk.NskAlgoStop();
          }
          isFingerTouchOnSensor = false;
        } else if (dataRec == 0xc8) {
          //                    BleDevLog.e("CCL", "手指放在ECG传感器上");
          // console.log("  >>>>>>111>>>>isFingerTouchOnSensor=" + isFingerTouchOnSensor + "  outputRawData=" + outputRawData)
          pkgIndex = 0;
          if (!isFingerTouchOnSensor && !outputRawData) {
            //手指由未接触转接触时，开始计算
            // NskAlgoSdk.NskAlgoStart(false);
          }
          isFingerTouchOnSensor = true;
        }

        // postMessage(
        //     obtainMessage(
        //         Communication.ECG_FINGERDETECTIOＮ,
        //         "is finger touch",
        //         isFingerTouchOnSensor
        //     )
        // );

        ecgStageFlag++;
      } else if (ecgStageFlag >= 5 && ecgStageFlag <= 21) {
        ecgStageFlag++;
      } else if (ecgStageFlag >= 22 && ecgStageFlag <= 1045) {
        // 有效数据
        if (ecgStageFlag % 2 == 0) {
          // const view = new Uint8Array(raw)
          dataEcg = dataRec << 8;
          // console.log("  >>>>>(ecgStageFlag % 2 == 0>>>>>.dataEcg=" + dataEcg)
        } else {
          dataEcg = dataEcg + dataRec;
          // 调用算法
          if (dataEcg >= 32768) {
            dataEcg -= 65536;
          }
          // console.log("  >>>>>(ecgStageFlag % 2 != 0>>>>>outputRawData=" + outputRawData + "  isFingerTouchOnSensor=" + isFingerTouchOnSensor)
          if (outputRawData) {
            // console.log("  >>>>>>>><1045>>>>>>isFingerTouchOnSensor=" + isFingerTouchOnSensor +"   outputArrayData="+outputArrayData+ "  ecgStageFlag=" + ecgStageFlag+"  getCurrentDate="+getCurrentDate())
            if (isFingerTouchOnSensor) {
              //callback raw data
              if (outputArrayData) {
                // console.log("  >>>>>outputArrayData>>>>>pkgIndex=" + pkgIndex + "  outputPkg=" + outputPkg + "  pkgLen=" + pkgLen)
                if (pkgIndex % pkgLen == 0) {
                  pkgIndex = 0;
                  outputPkg = List.generate(pkgLen, (index) => 0);
                }
                outputPkg[pkgIndex] = dataEcg;
                pkgIndex++;
                if (pkgIndex == pkgLen) {
                  // postMessage(
                  //     obtainMessage(
                  //         Communication.ECG_DATA_RAW,
                  //         "output",
                  //         outputPkg
                  //     )
                  // );
                }
              } else {
                // postMessage(
                //     obtainMessage(
                //         Communication.ECG_DATA_RAW,
                //         "output",
                //         dataEcg
                //     )
                // );
              }
            }
          } else {
            // eslint-disable-next-line no-lonely-if
            if (isFingerTouchOnSensor) {
              var filterdata = filter(dataEcg);
              if (filterdata != 0) {
                var outData = getAC(filterdata);
                if (outData != 0) {
                  // postMessage(
                  //     obtainMessage(
                  //         Communication.ECG_DATA_FILTER,
                  //         "output",
                  //         { outData, start }
                  //         // new EcgFilterData(outData, start)
                  //     )
                  // );
                  start++;
                }
                // console.log("   >>>>>>>>>>>>>>>>>filterdata="+filterdata)
              }
            }
          }
          // ecgDataIndex++;
        }
        ecgStageFlag = ecgStageFlag == 1045 ? 0 : ecgStageFlag + 1;
      } else {
        ecgStageFlag = 0;
      }
    }
  }
}
