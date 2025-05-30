import "dart:typed_data";
import "package:flutter/material.dart";

import '../common/common.dart';
import "../util/fileutil.dart" as FileUtil;

int imageBank = 0;
int MISO_GPIO = 0;
int MISI_GPIO = 0;
int CS_GPIO = 0;
int SCK_GPIO = 0;

int I2CDeviceAddress = 0;
int SCL_GPIO = 0;
int SDA_GPIO = 0;

bool lastBlock = false;
bool lastBlockSent = false;
bool preparedForLastBlock = false;
bool endSignalSent = false;
bool rebootsignalSent = false;
bool finished = false;
bool hasError = false;
Map<String, String> errors={};

int type = 0;
int memoryType = 0;
int blockCounter = 0;
int chunkCounter = -1;
int gpioMapPrereq = 0;
const int TYPE = 1;

int getMemParamsSPI() {
  return (MISO_GPIO << 24) | (MISI_GPIO << 16) | (CS_GPIO << 8) | SCK_GPIO;
}

int getMemParamsI2C() {
  return (I2CDeviceAddress << 16) | (SCL_GPIO << 8) | SDA_GPIO;
}

void setImageBank(int bank) {
  imageBank = bank;
}

int getImageBank() {
  return imageBank;
}

void setMemoryType(int type) {
  memoryType = type;
}

void setSpotaGpioMap(Function bleToWrite) {
  int memInfoData = 0;
  bool valid = false;

  switch (memoryType) {
    case MEMORY_TYPE_SPI:
      memInfoData = getMemParamsSPI();
      valid = true;
      break;
    case MEMORY_TYPE_I2C:
      memInfoData = getMemParamsI2C();
      valid = true;
      break;
  }

  if (valid) {
    bleToWrite(memInfoData);
  } else {
    debugPrint("Memory type not set.");
  }
}

void setPatchLength(Function bleToWrite) {
  int blocksize = getFileBlockSize();
  if (lastBlock) {
    blocksize = getNumberOfBytes() % getFileBlockSize();
    preparedForLastBlock = true;
  }
  bleToWrite(blocksize);
}

int getNumberOfBytes() {
  return FileUtil.getNumberOfBytes();
}

int getCrc() {
  return FileUtil.getCrc();
}

int getFileBlockSize() {
  return FileUtil.getFileBlockSize();
}

void sendEndSignal(Function updateUIAndBleWrite) {
  endSignalSent = true;
  updateUIAndBleWrite(END_SIGNAL);
}

void sendRebootSignal(Function bleToWrite) {
  bleToWrite(REBOOT_SIGNAL);
  rebootsignalSent = true;
}

void sendBlock(Function updateUIAndBleWrite) {
  double progress = (blockCounter + 1) / FileUtil.getNumberOfBlocks();
  if (!lastBlockSent) {
    List<Uint8List> block = FileUtil.getBlock(blockCounter);
    int i = ++chunkCounter;
    if (chunkCounter == 0) {
      // debugPrint("Current block: ${blockCounter + 1} of ${FileUtil.getNumberOfBlocks()}");
    }
    bool lastChunk = false;
    if (chunkCounter == block.length - 1) {
      chunkCounter = -1;
      lastChunk = true;
    }
    Uint8List chunk = block[i];
    int chunkNumber = (blockCounter * FileUtil.getChunksPerBlockCount()) + i + 1;
    updateUIAndBleWrite(chunkNumber, FileUtil.getTotalChunkCount(), chunk, progress);
    if (lastChunk) {
      if (FileUtil.getNumberOfBlocks() == 1) {
        lastBlock = true;
      }
      if (!lastBlock) {
        blockCounter++;
      } else {
        lastBlockSent = true;
      }
      if (blockCounter + 1 == FileUtil.getNumberOfBlocks()) {
        lastBlock = true;
      }
    }
  }
}

void onSuccess(Function updateUIAndBleSet) {
  finished = true;
  updateUIAndBleSet();
}

void onError(int errorCode, Function updateUI) {
  String? error = errors["errorCode"];
  debugPrint("Error: $errorCode $error");
  if (hasError) {
    return;
  }
  hasError = true;
  disconnect("onError");
  updateUI(errorCode, error);
}

void disconnect(String from) {}

Map initErrorMap() {
  errors = {
    "3": "Forced exit of SPOTA service.",
    "4": "Patch Data CRC mismatch.",
    "5": "Received patch Length not equal to PATCH_LEN characteristic value.",
    "6": "External Memory Error. Writing to external device failed.",
    "7": "Internal Memory Error. Not enough internal memory space for patch.",
    "8": "Invalid memory device.",
    "9": "Application error.",
    "1": "SPOTA service started instead of SUOTA.",
    "17": "Invalid image bank.",
    "18": "Invalid image header.",
    "19": "Invalid image size.",
    "20": "Invalid product header.",
    "21": "Same Image Error.",
    "22": "Failed to read from external memory device.",
    ERROR_COMMUNICATION: "Communication error.",
    ERROR_SUOTA_NOT_FOUND: "The remote device does not support SUOTA."
  };
  return errors;
}

int getSpotaMemDev() {
  int memTypeBase = -1;
  switch (memoryType) {
    case MEMORY_TYPE_SPI:
      memTypeBase = MEMORY_TYPE_EXTERNAL_SPI;
      break;
    case MEMORY_TYPE_I2C:
      memTypeBase = MEMORY_TYPE_EXTERNAL_I2C;
      break;
  }
  // debugPrint("getSpotaMemDev: ${((memTypeBase << 24) | imageBank)}, imageBank= $imageBank memoryType=$memoryType memTypeBase=$memTypeBase");
  return (memTypeBase << 24) | imageBank;
}

void setFileBlockSize(int fileBlockSize, int fileChunkSize) {
  int chunkSize = fileChunkSize;
  FileUtil.setFileBlockSize(fileBlockSize, chunkSize);
}

void setMISO_GPIO(int mMISO_GPIO) {
  MISO_GPIO = mMISO_GPIO;
}

void setMISI_GPIO(int mMOISI_GPIO) {
  MISI_GPIO = mMOISI_GPIO;
}

void setCS_GPIO(int mCS_GPIO) {
  CS_GPIO = mCS_GPIO;
}

void setSCK_GPIO(int mSCK_GPIO) {
  SCK_GPIO = mSCK_GPIO;
}

void setSCL_GPIO(int mSCL_GPIO) {
  SCL_GPIO = mSCL_GPIO;
}

void setSDA_GPIO(int mSDA_GPIO) {
  SDA_GPIO = mSDA_GPIO;
}

void setI2CDeviceAddress(int mI2CDeviceAddress) {
  I2CDeviceAddress = mI2CDeviceAddress;
}

bool isFinished() {
  return finished;
}

bool getError() {
  return hasError;
}

void reset() {
  lastBlock = false;
  lastBlockSent = false;
  preparedForLastBlock = false;
  endSignalSent = false;
  rebootsignalSent = false;
  finished = false;
  hasError = false;
  blockCounter = 0;
  chunkCounter = -1;
  gpioMapPrereq = 0;
  type = 0;
}

bool getLastBlock() {
  return lastBlock;
}

bool getLastBlockSent() {
  return lastBlockSent;
}

bool getEndSignalSent() {
  return endSignalSent;
}

int getGpioMapPrereq() {
  return gpioMapPrereq;
}

int addGpioMapPrereq() {
  return ++gpioMapPrereq;
}

bool getPreparedForLastBlock() {
  return preparedForLastBlock;
}

void setType(int t) {
  type = t;
}

void fileSetType(int type, Uint8List data) {
  FileUtil.setfType(type, data);
}

int getType() {
  return type;
}