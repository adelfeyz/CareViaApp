import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

Future<String> loadJsonFromAssets(String assetsPath) async {
  return await rootBundle.loadString(assetsPath);
}

Future<List> loadAndDecodeJson(String assetsPath) async {
  String jsonData = await rootBundle.loadString(assetsPath);
  var jsonList = jsonDecode(jsonData);
  return jsonList;
}

Future<String> encodeListToJson(List list) async{
  return jsonEncode(list);
}
