import 'dart:async';
import '../models/health_sample.dart';

class RingLiveBuffer {
  static final RingLiveBuffer _i = RingLiveBuffer._();
  factory RingLiveBuffer() => _i;
  RingLiveBuffer._();

  // keep the last 5 minutes (300 samples if one per sec)
  final List<HealthSample> _fifo = [];

  final _stream = StreamController<List<HealthSample>>.broadcast();
  Stream<List<HealthSample>> get stream => _stream.stream;

  void add(HealthSample s) {
    _fifo.add(s);
    if (_fifo.length > 300) _fifo.removeAt(0);
    _stream.add(List.unmodifiable(_fifo));        // push immutable copy
  }

  void clear() {
    _fifo.clear();
    _stream.add([]);
  }
} 