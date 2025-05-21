import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'data/history_controller.dart';
import 'models/history_sample.dart';

class RetrieveDataPage extends StatefulWidget {
  const RetrieveDataPage({super.key});

  @override
  State<RetrieveDataPage> createState() => _RetrieveDataPageState();
}

class _RetrieveDataPageState extends State<RetrieveDataPage> {
  late final HistoryController _c;

  @override
  void initState() {
    super.initState();
    _c = Get.put(HistoryController());
    _c.fetchCount(); // ask count on open
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total entries: ${_c.totalEntries.value}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('minUUID: ${_c.minUuid.value}', style: const TextStyle(fontSize: 14)),
                  Text('maxUUID: ${_c.maxUuid.value}', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _c.loading.value ? null : _c.fetchData,
                    icon: const Icon(Icons.download),
                    label: const Text('Download History'),
                  ),
                ],
              ),
            )),
      );

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
      appBar: AppBar(title: const Text('Historical Data')),
      body: Column(
        children: [
          _infoCard(),
          const Divider(height: 0),
          Expanded(child: _list()),
        ],
      ),
    );
  }
} 