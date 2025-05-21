import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../common/constant.dart';

class UuidManager {
  List characteristicUUIDList = [];
  List characteristicList = [];
  List<BluetoothCharacteristic> sotaReadCharacteristicList = [];
  List sotaUUIDArray = [
    SUOTA_VERSION_UUID,
    SUOTA_PATCH_DATA_CHAR_SIZE_UUID,
    SUOTA_MTU_UUID,
    SUOTA_L2CAP_PSM_UUID
  ];
  initData() {
    characteristicUUIDList.clear();
    characteristicList.clear();
    sotaReadCharacteristicList.clear();
  }

  void getUUID(List<BluetoothCharacteristic> list) {
    // debugPrint(" characteristicUUIDList ${characteristicUUIDList.length} ");
    for (var item in list) {
      String uuid = "";
      if (item.characteristicUuid.toString().length == 4) {
        uuid = '0000${item.characteristicUuid.toString().toUpperCase()}-0000-1000-8000-00805F9B34FB';
      } else {
        uuid = item.characteristicUuid.toString().toUpperCase();
      }
      if (!characteristicUUIDList.contains(uuid)) {
        // serviceUUIDList.add(item.serviceUuid.toString().toUpperCase());
        characteristicUUIDList.add(uuid);
        characteristicList.add(item);
        if (sotaUUIDArray
            .contains(item.characteristicUuid.toString().toUpperCase())) {
          sotaReadCharacteristicList.add(item);
        }
        // debugPrint(" ${item.serviceUuid} == ${item.characteristicUuid}");
      }
    }
  }

  void addOTAcharacteristic(String characteristicUuid) {
    var characteristic = getCharacteristic(characteristicUuid);
    if (characteristic != null) {
      sotaReadCharacteristicList.add(characteristic);
    }
  }

  BluetoothCharacteristic? getCharacteristic(String characteristicUuid) {
    // debugPrint(" getCharacteristic characteristicUuid=$characteristicUuid  characteristicUUIDList=${characteristicUUIDList.length} ");
    if (characteristicUUIDList.isEmpty) {
      return null;
    }
    int index = characteristicUUIDList.indexOf(characteristicUuid);
    // debugPrint(" index=$index");
    return characteristicList[index];
  }
}
