
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/navigator.dart';
import 'package:get/get.dart';
class OtaMiddleWare extends GetMiddleware{
  @override
  RouteSettings? redirect(String? route) {
    // TODO: implement redirect
    debugPrint("OtaMiddleWare");
    // return RouteSettings(name:"./");
    return null;
  }
}