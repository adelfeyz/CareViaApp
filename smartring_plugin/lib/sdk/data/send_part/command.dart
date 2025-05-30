import 'dart:typed_data';

import './ble_protocol.dart';
import './ble_data.dart';


abstract class Command {
  Uint8List execute(data);
}

class CommandImpl extends Command {
  var cmd;
  var innerData;

  CommandImpl(this.cmd,{this.innerData});
  @override
  Uint8List execute(data) {
    var result = downlinkCommand(cmd, innerData!=null?dealMap[cmd](data:data,innerData:innerData):dealMap[cmd](data:data));
    // debugPrint("downlinkCommand  result=$result  ");
    return result;
  }
}
