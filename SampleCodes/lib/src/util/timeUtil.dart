

import 'package:intl/intl.dart';

String formatNowTime() {
  DateTime now = DateTime.now();
  // 使用 intl 包中的 DateFormat 类进行格式化
  DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  String formattedDateTime = formatter.format(now);
  return formattedDateTime;
}

String formatDateTime(DateTime dateTime) {
  // 使用 intl 包中的 DateFormat 类进行格式化
  DateFormat formatter = DateFormat('HH:mm:ss');
  String formattedDateTime = formatter.format(dateTime);
  return formattedDateTime;
}