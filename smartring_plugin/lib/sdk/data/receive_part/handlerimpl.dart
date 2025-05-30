import 'package:flutter/material.dart';

import './handler.dart';
import './process.dart';
import '../../global/global.dart';

class HandlerImpl extends Handler {
  HandlerImpl(super.cmd, super.type);

  @override
  handlerRequest(request) {
    // debugPrint("request: ${request["cmd"]}  cmd: $cmd  type: $type");
    if (request["cmd"] == cmd) {
      //这里要对数据进行处理

      var data = parseAllData(request["data"], type);
      // debugPrint("data: $data type: $type");
      dispatchData(type, data);

      return;
    } else if (nextHandler != null) {
      // 如果当前处理者不能够处理该请求，则将请求传递给下一个处理者进行处理
      nextHandler!.handlerRequest(request);
    } else {
      // console.log(`No handler is available to handle the request ${request.cmd}`);
    }
  }
}
