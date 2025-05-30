import 'dart:async';

import 'package:workmanager/workmanager.dart';

import '../data/repositories/raw_data_repository.dart';
import 'background_worker.dart';

/// Listens for new raw frames and triggers the Workmanager processing task
/// with a small debounce so bursts result in only one schedule.
class BackgroundScheduler {
  BackgroundScheduler._();
  static final BackgroundScheduler instance = BackgroundScheduler._();

  static const _debounce = Duration(seconds: 5);

  Timer? _timer;
  late final StreamSubscription _sub;

  void start() {
    _sub = RawDataRepository.instance.stream.listen((_) {
      _timer?.cancel();
      _timer = Timer(_debounce, _enqueueTask);
    });
  }

  void dispose() {
    _timer?.cancel();
    _sub.cancel();
  }

  void _enqueueTask() {
    Workmanager().registerOneOffTask(
      'process_raw_${DateTime.now().millisecondsSinceEpoch}',
      kProcessRawTask,
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );
  }
} 