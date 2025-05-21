

import 'package:flutter/material.dart';

double calculateAverage(List<num> list) {
  if (list.isEmpty) return 0.0;

  // 计算总和
  num sum = list.reduce((value, element) => value + element);

  // 计算平均值
  return sum / list.length;
}


// 判断两个时间戳之间的时间差是否超过三小时
bool isMoreThanThreeHours(int timeStamp1, int timeStamp2) {
  final differenceInMillis = (timeStamp2 - timeStamp1).abs(); // 计算时间差的绝对值
  final threeHoursInMillis = const Duration(hours: 3).inMilliseconds; // 将三小时转换为毫秒
  return differenceInMillis >= threeHoursInMillis; // 返回时间差是否大于或等于三小时的布尔值
}

// 将数字四舍五入到十分位
double roundToOneDecimalWithRounding(double num) {
  return double.parse(num.toStringAsFixed(1));
}

double calculateGridDensity(double millimeters, BuildContext context) {
 // 获取设备的像素密度比
  final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
  
  // 1英寸等于25.4毫米，因此1mm等于1/25.4英寸
  final double mmToInch = 1 / 25.4;
  
  // 在MDPI（160dpi）屏幕上，1英寸等于160px，因此1mm对应的px数
  final double mmToPxAtMdpi = mmToInch * 160;
  
  // 转换为当前设备上的dp值
  // 注意：devicePixelRatio实质上是物理像素与逻辑像素(dp)的比例，但直接用它来转换mm到dp需小心处理
  // 正确逻辑应基于设备dpi与dp的关系，考虑到dp设计基于160dpi标准，我们调整计算方法
  final double gridDensity = mmToPxAtMdpi / devicePixelRatio;
  
  return gridDensity/2;

}

String formatEcgData(List<dynamic> data) {
  return data.map((item) => '$item,1').join('\n');
}