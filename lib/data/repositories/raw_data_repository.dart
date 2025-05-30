import 'dart:async';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../models/raw_frame.dart';

/// Centralised persistence for un-processed BLE frames.
///
/// • Each calendar day gets its own Hive LazyBox so that we can
///   purge old data by simply deleting whole files.
/// • Writes are fire-and-forget to keep the BLE callback thread free.
/// • A broadcast [stream] exposes newly appended frames so that the
///   processing layer can react without polling.
class RawDataRepository {
  RawDataRepository._internal();
  static final RawDataRepository instance = RawDataRepository._internal();

  /// Directory that holds all raw data *.hive* files.
  late final Directory _rootDir;

  /// Stream of frames that were just appended to disk.
  final _controller = StreamController<RawFrame>.broadcast();
  Stream<RawFrame> get stream => _controller.stream;

  String get rootPath => _rootDir.path;

  /// Initialize underlying storage. Call once during app start-up.
  Future<void> init() async {
    _rootDir = await _ensureRawDir();
  }

  /// Persist a [frame] to the Hive Box belonging to its [timeStamp] day.
  Future<void> append(RawFrame frame) async {
    final date = DateTime.fromMillisecondsSinceEpoch(frame.timeStamp);
    final box = await _boxFor(date);
    await box.put(frame.uuid, frame);
    _controller.add(frame); // fire event for processors/UI
  }

  /// Returns all frames whose uuid is > [sinceUuid] across **all** days.
  /// Uses lazy iteration so it is safe on memory.
  Stream<RawFrame> framesSince(int sinceUuid) async* {
    for (final file in _rootDir.listSync().whereType<File>()) {
      final boxName = file.path.split(Platform.pathSeparator).last.replaceAll('.hive', '');
      final box = await Hive.openLazyBox<RawFrame>(boxName);
      final keys = box.keys.whereType<int>().where((k) => k > sinceUuid);
      for (final key in keys) {
        yield await box.get(key) as RawFrame;
      }
      await box.close();
    }
  }

  /// Delete all raw data files and recreate the directory.
  Future<void> deleteAllRawData() async {
    // Close any raw_* boxes that are currently open.
    if (await _rootDir.exists()) {
      for (final file in _rootDir.listSync().whereType<File>()) {
        final boxName = file.path.split(Platform.pathSeparator).last.replaceAll('.hive', '');
        if (!boxName.startsWith('raw_')) continue;

        if (Hive.isBoxOpen(boxName)) {
          // Box is currently used in this isolate. Clear its contents so the
          // UI reflects the purge, but keep it open so Hive will handle the
          // .lock file when the box is eventually closed (avoids double-close
          // errors in other isolates).
          try {
            await Hive.box(boxName).clear();
          } catch (_) {
            // ignore
          }
        }
      }
    }

    // Delete the directory and recreate it.
    if (await _rootDir.exists()) {
      await _rootDir.delete(recursive: true);
    }
    await _rootDir.create(recursive: true);
  }

  // ---------------------------------------------------------------------------
  // Private implementation
  // ---------------------------------------------------------------------------

  Future<Directory> _ensureRawDir() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final rawDir = Directory('${docsDir.path}${Platform.pathSeparator}raw');
    if (!await rawDir.exists()) {
      await rawDir.create(recursive: true);
    }
    return rawDir;
  }

  Future<LazyBox<RawFrame>> _boxFor(DateTime date) async {
    final boxName = 'raw_${date.year}_${date.month}_${date.day}';
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openLazyBox<RawFrame>(boxName, path: _rootDir.path);
    }
    return Hive.lazyBox<RawFrame>(boxName);
  }
} 