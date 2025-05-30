import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

import '../data/models/raw_frame.dart';
import '../data/repositories/sync_state_repository.dart';
import 'history_processor.dart';

const kProcessRawTask = 'process_raw';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != kProcessRawTask) return Future.value(true);

    WidgetsFlutterBinding.ensureInitialized();

    // Initialise Hive in this isolate
    final docsDir = await getApplicationDocumentsDirectory();
    Hive.init(docsDir.path);
    Hive.registerAdapter(RawKindAdapter());
    Hive.registerAdapter(RawFrameAdapter());

    await SyncStateRepository.instance.init();

    final rawDirPath = '${docsDir.path}${Platform.pathSeparator}raw';
    final last = SyncStateRepository.instance.getLastUuid();
    final newMax = await HistoryProcessor.runOnce(lastUuid: last, rawDirPath: rawDirPath);
    if (newMax > last) {
      await SyncStateRepository.instance.setLastUuid(newMax);
    }
    await SyncStateRepository.instance.setLastProcessed(DateTime.now());

    return Future.value(true);
  });
} 