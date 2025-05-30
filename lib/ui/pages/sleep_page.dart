import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:carevia/data/models/sleep_episode.dart';
import 'package:carevia/data/models/raw_frame.dart';
import 'package:carevia/data/repositories/raw_data_repository.dart';
import 'package:carevia/data/processors/sleep_processor.dart';
import 'package:carevia/data/history_controller.dart';
import 'package:get/get.dart';

class SleepPage extends StatelessWidget {
  const SleepPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Rebuild Sleep Data'),
              onPressed: () async {
                await _rebuildSleepDataFromRaw(context);
              },
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<SleepEpisode>('sleep.hive').listenable(),
              builder: (context, Box<SleepEpisode> box, _) {
                final episodes = box.values.toList();
                if (episodes.isEmpty) {
                  return const Center(
                    child: Text('No sleep data available.'),
                  );
                }
                final latest = episodes.last;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDateAndSyncRow(),
                      const SizedBox(height: 16),
                      _buildStageDistribution(latest),
                      const SizedBox(height: 16),
                      _buildKpiRow(latest),
                      const SizedBox(height: 16),
                      _buildPhysiologyRow(latest),
                      const SizedBox(height: 16),
                      _buildTrendTable(episodes),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _rebuildSleepDataFromRaw(BuildContext context) async {
    // First fetch historical data from the ring
    final historyController = Get.find<HistoryController>();
    await historyController.fetchData();

    final sleepBox = Hive.box<SleepEpisode>('sleep.hive');
    await sleepBox.clear();
    
    // Collect all raw frames from all raw boxes
    final rawDir = RawDataRepository.instance.rootPath;
    final dir = Directory(rawDir);
    if (!await dir.exists()) return;
    
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.hive'))
        .toList();
        
    final List<RawFrame> allFrames = [];
    for (final f in files) {
      final boxName = f.path.split(Platform.pathSeparator).last.replaceAll('.hive', '');
      final box = await Hive.openLazyBox<RawFrame>(boxName, path: dir.path);
      final keys = box.keys.whereType<int>();
      for (final key in keys) {
        final frame = await box.get(key) as RawFrame?;
        if (frame != null) {
          allFrames.add(frame);
        }
      }
      await box.close();
    }
    
    // Process all frames
    final processor = SleepProcessor(sleepBox);
    for (final frame in allFrames) {
      processor.addFrame(frame);
    }
    
    final episodes = await processor.flush();
    for (final episode in episodes) {
      await sleepBox.add(episode);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sleep data rebuilt from raw data.')),
    );
  }

  Widget _buildDateAndSyncRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Date: Today', style: TextStyle(fontSize: 16)),
        const Text('Last sync: 12:34 PM', style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildStageDistribution(SleepEpisode episode) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sleep Stages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStageBar('Wake', episode.wakeMin, Colors.red),
                ),
                Expanded(
                  child: _buildStageBar('Light', episode.lightMin, Colors.blue),
                ),
                Expanded(
                  child: _buildStageBar('Deep', episode.deepMin, Colors.green),
                ),
                Expanded(
                  child: _buildStageBar('REM', episode.remMin, Colors.purple),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // TODO: Navigate to staging table
              },
              child: const Text('View detailed stages'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageBar(String label, int minutes, Color color) {
    return Column(
      children: [
        Container(
          height: 100,
          color: color,
          child: Center(
            child: Text('$minutes min', style: const TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }

  Widget _buildKpiRow(SleepEpisode episode) {
    final totalMinutes = episode.lightMin + episode.deepMin + episode.remMin + episode.wakeMin;
    final actualSleepMinutes = episode.lightMin + episode.deepMin + episode.remMin;
    final efficiency = episode.efficiency * 100;
    return Row(
      children: [
        Expanded(
          child: _buildKpiCard('Time in Bed', '$totalMinutes min'),
        ),
        Expanded(
          child: _buildKpiCard('Actual Sleep', '$actualSleepMinutes min'),
        ),
        Expanded(
          child: _buildKpiCard('Efficiency', '${efficiency.toStringAsFixed(1)}%'),
        ),
      ],
    );
  }

  Widget _buildKpiCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysiologyRow(SleepEpisode episode) {
    return Row(
      children: [
        Expanded(
          child: _buildKpiCard('Avg Respiratory Rate', '${episode.avgRespRate.toStringAsFixed(1)} br/min'),
        ),
        Expanded(
          child: _buildKpiCard('Avg SpO₂', '${episode.avgSpO2.toStringAsFixed(1)}%'),
        ),
      ],
    );
  }

  Widget _buildTrendTable(List<SleepEpisode> episodes) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sleep Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: episodes.length,
              itemBuilder: (context, index) {
                final episode = episodes[index];
                final totalSleep = episode.lightMin + episode.deepMin + episode.remMin;
                return ListTile(
                  title: Text('${episode.start.day}/${episode.start.month}/${episode.start.year}'),
                  subtitle: Text('Total: $totalSleep min, Efficiency: ${(episode.efficiency * 100).toStringAsFixed(1)}%'),
                  trailing: Text('Resp: ${episode.avgRespRate.toStringAsFixed(1)}, SpO₂: ${episode.avgSpO2.toStringAsFixed(1)}'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 