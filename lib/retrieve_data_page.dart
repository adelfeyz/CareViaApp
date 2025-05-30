import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'dart:convert';

import 'data/history_controller.dart';
import 'models/history_sample.dart';
import 'data/repositories/raw_data_repository.dart';
import 'data/models/raw_frame.dart';
import 'data/models/sleep_episode.dart';
import 'data/models/sleep_stage.dart';
import 'package:smartring_plugin/sdk/core.dart' as smartring_plugin;

class RetrieveDataPage extends StatefulWidget {
  const RetrieveDataPage({super.key});

  @override
  State<RetrieveDataPage> createState() => _RetrieveDataPageState();
}

class _RetrieveDataPageState extends State<RetrieveDataPage> {
  late final HistoryController _c;
  int _dbCount = 0;
  DateTime? _dbMin;
  DateTime? _dbMax;

  @override
  void initState() {
    super.initState();
    _c = Get.put(HistoryController());
    _c.fetchCount();
    computeDbStats();
  }

  Future<void> computeDbStats() async {
    final dir = Directory('${RawDataRepository.instance.rootPath}');
    if (!await dir.exists()) {
      setState(() {
        _dbCount = 0;
        _dbMin = null;
        _dbMax = null;
      });
      return;
    }
    int total = 0;
    DateTime? minD;
    DateTime? maxD;
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.hive'))
        .toList();
    for (final f in files) {
      final boxName = f.path.split(Platform.pathSeparator).last.replaceAll('.hive', '');
      final box = await Hive.openLazyBox(boxName, path: dir.path);
      total += box.length;
      try {
        final parts = boxName.split('_').last.split('-');
        if (parts.length == 3) {
          final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          minD = (minD == null || date.isBefore(minD!)) ? date : minD;
          maxD = (maxD == null || date.isAfter(maxD!)) ? date : maxD;
        }
      } finally {
        await box.close();
      }
    }
    setState(() {
      _dbCount = total;
      _dbMin = minD;
      _dbMax = maxD;
    });
  }

  String _fmt(DateTime? d) {
    if (d == null) return '-';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    Get.delete<HistoryController>();
    super.dispose();
  }

  Widget _infoCard() => Card(
        margin: const EdgeInsets.all(16),
        child: Obx(() => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total entries: ${_c.totalEntries.value}', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('minUUID: ${_c.minUuid.value}', style: const TextStyle(fontSize: 14)),
                          Text('maxUUID: ${_c.maxUuid.value}', style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('DB records: $_dbCount', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('Min date: ${_fmt(_dbMin)}', style: const TextStyle(fontSize: 14)),
                          Text('Max date: ${_fmt(_dbMax)}', style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            )),
      );

  Widget _downloadButton() => Obx(() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
          onPressed: _c.loading.value
              ? null
              : () async {
                  await _c.fetchData();
                  await computeDbStats();
                },
          icon: const Icon(Icons.download),
          label: const Text('Download'),
        ),
      ));

  Widget _list() => Obx(() {
        if (_c.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_c.samples.isEmpty) {
          return const Center(child: Text('No records downloaded yet'));
        }
        return ListView.builder(
          itemCount: _c.samples.length,
          itemBuilder: (_, i) => _tile(_c.samples[i]),
        );
      });

  Widget _tile(HistorySample s) => ListTile(
        leading: const Icon(Icons.data_usage),
        title: Text('${s.timestamp}  HR ${s.heartRate}'),
        subtitle: Text('SpO₂ ${s.oxygen} HRV ${s.hrv} Temp ${s.temperature.toStringAsFixed(1)}°C RR ${s.respiratoryRate}'),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historical Data'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'delete_redownload') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete all raw data?'),
                    content: const Text('This will delete all locally stored raw data (not device info) and re-download from the ring. Continue?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Delete & Redownload'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await RawDataRepository.instance.deleteAllRawData();
                  await _c.fetchData();
                  await computeDbStats();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Raw data deleted and re-downloaded.')),
                    );
                  }
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'delete_redownload',
                child: Text('Delete Raw Data & Redownload'),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _c.fetchCount();
          await computeDbStats();
        },
        child: Column(
          children: [
            _infoCard(),
            const Divider(height: 0),
            _downloadButton(),
            Expanded(child: _list()),
          ],
        ),
      ),
    );
  }
} 