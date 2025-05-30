class Store {
  static int maxUUID = 0;
  static int minUUID = 0;
  static setMinUUID(int min) {
    minUUID = min;
  }

  static setMaxUUID(int max) {
    maxUUID = max;
  }

  static getMinUUID() {
    return minUUID;
  }

  static getMaxUUID() {
    return maxUUID;
  }
}
