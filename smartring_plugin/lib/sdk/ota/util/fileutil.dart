import "dart:typed_data";


import "../common/common.dart";

int type = 0;
Uint8List bytes=Uint8List(0);
int crc = 0;
int bytesAvailable = 0;
int numberOfBlocks = -1;
int chunksPerBlockCount = 0;
int totalChunkCount = 0;
int fileBlockSize = 0;
int fileChunkSize = DEFAULT_FILE_CHUNK_SIZE;
List<List<Uint8List>> blocks = [];

void setfType(int t, Uint8List data) {
  type = t;
  bytesAvailable = data.length;
  if (type == TYPE) {
    bytes = Uint8List(bytesAvailable + 1);
    bytes.setRange(0, bytesAvailable, data);
    crc = calculateCrc();
    bytes[bytesAvailable] = crc;
  } else {
    bytes = Uint8List(bytesAvailable);
  }
}

int calculateCrc() {
  int crcCode = 0;
  for (int i = 0; i < bytesAvailable; i++) {
    int byteValue = bytes[i];
    crcCode ^= byteValue;
  }
  return crcCode;
}

void setFileBlockSize(int fbSize, int fcSize) {
  fileBlockSize = fbSize > fcSize ? fbSize : fcSize;
  fileChunkSize = fcSize;
  if (fileBlockSize > bytes.length) {
    fileBlockSize = bytes.length;
    if (fileChunkSize > fileBlockSize) {
      fileChunkSize = fileBlockSize;
    }
  }
  chunksPerBlockCount = fileBlockSize ~/ fileChunkSize + (fileBlockSize % fileChunkSize != 0 ? 1 : 0);
  numberOfBlocks = bytes.length ~/ fileBlockSize + (bytes.length % fileBlockSize != 0 ? 1 : 0);
  initBlocks();
}

void initBlocks() {
  if (type == TYPE) {
    initBlocksSuota();
  }
}

void initBlocksSuota() {
  totalChunkCount = 0;
  blocks = List<List<Uint8List>>.generate(numberOfBlocks, (index) => List<Uint8List>.generate(8, (index) => Uint8List(8)));
  int byteOffset = 0;

  for (int i = 0; i < numberOfBlocks; i++) {
    int blockSize = fileBlockSize;
    int numberOfChunksInBlock = chunksPerBlockCount;

    if (byteOffset + fileBlockSize > bytes.length) {
      blockSize = bytes.length % fileBlockSize;
      numberOfChunksInBlock = blockSize ~/ fileChunkSize + (blockSize % fileChunkSize != 0 ? 1 : 0);
    }

    int chunkNumber = 0;
    blocks[i] = List<Uint8List>.generate(numberOfChunksInBlock, (index) => Uint8List(numberOfChunksInBlock));

    for (int j = 0; j < blockSize; j += fileChunkSize) {
      int chunkSize = fileChunkSize;

      if (j + fileChunkSize > blockSize) {
        chunkSize = blockSize % fileChunkSize;
      }

      Uint8List chunk = bytes.sublist(byteOffset, byteOffset + chunkSize);
      blocks[i][chunkNumber] = chunk;
      byteOffset += chunkSize;
      chunkNumber++;
      totalChunkCount++;
    }
  }
}

List<Uint8List> getBlock(int index) {
  return blocks[index];
}

int getCrc() {
  return crc;
}

int getNumberOfBlocks() {
  return numberOfBlocks;
}

int getChunksPerBlockCount() {
  return chunksPerBlockCount;
}

int getTotalChunkCount() {
  return totalChunkCount;
}

int getFileBlockSize() {
  return fileBlockSize;
}

int getNumberOfBytes() {
  return bytes.length;
}