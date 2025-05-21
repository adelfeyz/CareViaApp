var errorListener = [];

void registerErrorListener(listener) {
    if (!errorListener.contains(listener) ) {
        errorListener.add(listener);
    }
}

void unRegisterErrorListener(listener) {
    if (listener) {
        var index = errorListener.indexOf(listener);
        if (index != -1) {
          errorListener.remove(listener);
  
        }
    }
}

void dispatchErrorData  (data) {
    for (var listener in errorListener) {
        listener(data);
    }
}