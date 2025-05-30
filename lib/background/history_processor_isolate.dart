import 'package:carevia/data/models/raw_frame.dart';
import 'package:carevia/data/models/sleep_episode.dart';
import 'package:carevia/data/processors/sleep_processor.dart';
import 'package:hive/hive.dart';

Future<void> _processHistory(List<RawFrame> frames) async {
  final box = await Hive.openBox<SleepEpisode>('sleep.hive');
  final processor = SleepProcessor(box);
  for (final frame in frames) {
    processor.accept(frame);
  }
  final episodes = processor.flush();
  // TODO: Notify main isolate of new episodes
} 