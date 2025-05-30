import 'dart:async';
import 'dart:isolate';
import 'dart:io';

import 'package:hive/hive.dart';

/// Public façade used by the main isolate to schedule one immediate pass of
/// raw-data processing. For now it only advances the max-uuid cursor; actual
/// algorithm workers will be plugged in later (step 5+).
class HistoryProcessor {
  /// Spawns an isolate that scans raw boxes for frames with uuid > [lastUuid].
  /// Returns the new maxUuid (or the same value if nothing new).
  static Future<int> runOnce({required int lastUuid, required String rawDirPath}) async {
    final receive = ReceivePort();
    await Isolate.spawn<_IsolateCfg>(_entryPoint, _IsolateCfg(rawDirPath, lastUuid, receive.sendPort));
    final result = await receive.first;
    receive.close();
    return result as int;
  }
}

// ---------------------------------------------------------------------------
// Isolate implementation
// ---------------------------------------------------------------------------

class _IsolateCfg {
  const _IsolateCfg(this.rawDirPath, this.fromUuid, this.resultPort);
  final String rawDirPath;
  final int fromUuid;
  final SendPort resultPort;
}

void _entryPoint(_IsolateCfg cfg) async {
  // Hive needs an init call inside every isolate.
  Hive.init(cfg.rawDirPath); // path only used for boxes opened with full path

  int maxUuid = cfg.fromUuid;

  final dir = Directory(cfg.rawDirPath);
  if (!(await dir.exists())) {
    cfg.resultPort.send(maxUuid);
    return;
  }

  final rawFiles = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.hive'))
      .toList();

  for (final file in rawFiles) {
    final boxName = file.path.split(Platform.pathSeparator).last.replaceAll('.hive', '');
    final box = await Hive.openLazyBox(boxName, path: cfg.rawDirPath);
    try {
      // keys are uuids (int). LazyBox.keys is Iterable<dynamic>
      final keys = box.keys.whereType<int>().where((k) => k > cfg.fromUuid);
      for (final key in keys) {
        if (key > maxUuid) maxUuid = key;
        // In step 5 we will actually load and pass the frame to processors.
      }
    } finally {
      await box.close();
    }
  }

  cfg.resultPort.send(maxUuid);
} 