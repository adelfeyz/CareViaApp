abstract class Handler {
  Handler? nextHandler=null;
  int cmd;
  int type;

  Handler(this.cmd,this.type);

  setNextHandler(Handler handler) {
    nextHandler = handler;
  }

  handlerRequest(request);
}
