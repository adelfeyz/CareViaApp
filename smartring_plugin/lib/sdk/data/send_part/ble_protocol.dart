import 'dart:typed_data';

import '../../common/ble_protocol_constant.dart';

String getMacFromAdvertising(Map<String, dynamic> data) {
  List<int>? manufacturerData =
      data['advertising']?['manufacturerData']?['data'];
  if (manufacturerData == null) {
    return '';
  }
  return swapEndianWithColon(manufacturerData);
}

String swapEndianWithColon(List<int> str) {
  String format = '';
  int len = str.length;
  for (int j = 2; j <= len; j += 2) {
    format += str
        .sublist(len - j, len - (j - 2))
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join('');
    if (j != len) {
      format += ':';
    }
  }
  return format.toUpperCase();
}

// void parseData(List<int> data) {
//   if (data is! List<int>) {
//     throw ArgumentError('data must be an instance of List<int>');
//   }
//   if (data.length != BLE_TOTAL_LEN) {
//     throw ArgumentError('Incorrect package length != 20');
//   }
//   var view = ByteData.view(Uint8List.fromList(data).buffer);
//   var header = view.getInt8(0);
//   if (header != BLE_HEAD) {
//     throw ArgumentError('This header is error');
//   }
//   var cmd = view.getInt8(1);
// }

Uint8List downlinkCommand(int cmd, List<int> data) {
  if (data.length != 17) {
    throw ArgumentError('This data length != 17');
  }
  var buffer = Uint8List(BLE_TOTAL_LEN);
  var view = ByteData.view(buffer.buffer);
  view.setUint8(0, BLE_HEAD);
  view.setUint8(1, cmd);
  for (var index = 0; index < data.length; index++) {
    var i = 2 + index;
    view.setUint8(i, data[index]);
  }
  var crc = calCRC(view, 19);
  view.setUint8(19, crc);
  return buffer;
}

int calCRC(ByteData data, int len) {
  var xor = 0;
  for (var index = 0; index < len; index++) {
    xor ^= data.getUint8(index);
  }
  return xor;
}
