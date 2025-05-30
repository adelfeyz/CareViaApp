var ringModel = "SR09";

void setRingModel(value) {
  ringModel = value;
}

const int TYPE = 1;
const int MEMORY_TYPE_EXTERNAL_I2C = 0x12;
const int MEMORY_TYPE_EXTERNAL_SPI = 0x13;

const String ACTION_BLUETOOTH_GATT_UPDATE = "BluetoothGattUpdate";
const String ACTION_PROGRESS_UPDATE = "ProgressUpdate";
const String ACTION_CONNECTION_STATE_UPDATE = "ConnectionState";
const int DEFAULT_MTU = 23;
const int DEFAULT_FILE_CHUNK_SIZE = 20;
const int MEMORY_TYPE_SYSTEM_RAM = 1;
const int MEMORY_TYPE_RETENTION_RAM = 2;
const int MEMORY_TYPE_SPI = 3;
const int MEMORY_TYPE_I2C = 4;
const int DEFAULT_MEMORY_TYPE = MEMORY_TYPE_SPI;

int get DEFAULT_MISO_VALUE => ringModel == "SR09" ? 3 : 5;
int get DEFAULT_MISI_VALUE => ringModel == "SR09" ? 0 : 6;
int get DEFAULT_CS_VALUE => ringModel == "SR09" ? 1 : 3;
int get DEFAULT_SCK_VALUE => ringModel == "SR09" ? 4 : 0;
// SR23 specific values
// const int DEFAULT_MISO_VALUE_SR23 = 5;
// const int DEFAULT_MISI_VALUE_SR23 = 6;
// const int DEFAULT_CS_VALUE_SR23 = 3;
// const int DEFAULT_SCK_VALUE_SR23 = 0;
const String DEFAULT_BLOCK_SIZE_VALUE = "240";
const int DEFAULT_MEMORY_BANK = 0;
const String DEFAULT_I2C_DEVICE_ADDRESS = "0x50";
const int DEFAULT_SCL_GPIO_VALUE = 2;
const int DEFAULT_SDA_GPIO_VALUE = 3;
const int MEMORY_TYPE_SUOTA_INDEX = 100;
const int MEMORY_TYPE_SPOTA_INDEX = 101;

const String ERROR_COMMUNICATION = "65535"; // ble communication error
const String ERROR_SUOTA_NOT_FOUND = "65534"; // suota service was not found

final RegExp gpioStringPattern = RegExp(r'P(\d+)_(\d+)');

const int END_SIGNAL = 0xfe000000;
const int REBOOT_SIGNAL = 0xfd000000;
