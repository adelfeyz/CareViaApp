
//单例模式
import 'package:get/get.dart';
import 'package:smartring_flutter/src/controller/blood_glucose_controller.dart';

class GetXManager {
  
  static final GetXManager _instance=GetXManager._internal();
  static const String tempLineChartControllerTag = "TempLineChartController";
  static const String motionChartControllerTag = "motionChartController";
  static const String pressureChartControllerTag = "pressureChartController";

  static GetXManager get instance {
    return _instance;
  }

  GetXManager._internal();

  //获取控制器
  T getController<T extends GetxController>(String tag) {
    return Get.find<T>(tag: tag);
  }

  //添加控制器
  T putController<T extends GetxController>(T controller, {required String tag}) {
    return Get.put(controller, tag: tag);  
  }

  lazyPutController() {
    return Get.lazyPut(()=>BloodGlucoseController(),fenix: true);
  }

}