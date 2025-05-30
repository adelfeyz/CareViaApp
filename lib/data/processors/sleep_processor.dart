import 'dart:convert';
import 'dart:async';
import 'package:carevia/data/models/raw_frame.dart';
import 'package:carevia/data/models/sleep_episode.dart';
import 'package:carevia/data/models/sleep_stage.dart';
import 'package:hive/hive.dart';
import 'package:smartring_plugin/smartring_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:flutter/material.dart';

class SleepProcessor {
  final Box<SleepEpisode> box;
  final _logger = Logger('SleepProcessor');
  final List<RawFrame> _frames = [];
  final _maxFrames = 1000; // Maximum frames to keep in memory
  final _minFramesForProcessing = 30; // Minimum frames needed for processing

  SleepProcessor(this.box);

  void addFrame(RawFrame frame) {
    // Accept frame without strict validation – some historical packets may
    // legitimately miss non-essential fields (e.g. sportsMode string).
    _frames.add(frame);
    
    // Keep only the most recent frames
    if (_frames.length > _maxFrames) {
      _frames.removeAt(0);
    }
  }

  Future<List<Map<String, dynamic>>?> processFrames() async {
    if (_frames.length < _minFramesForProcessing) {
      _logger.info('Not enough frames for processing: ${_frames.length} < $_minFramesForProcessing');
      return null;
    }

    try {
      // Convert frames to safe values for the algorithm
      final safeFrames = _frames.map((f) => f.getSafeValues()).toList();
      
      _logger.info('Processing ${safeFrames.length} frames');
      _logger.info('First frame: ${_frames.first.toJson()}');
      _logger.info('Last frame: ${_frames.last.toJson()}');

      // Call the sleep algorithm with safe values
      final result = await compute(sleepAlgorithm, safeFrames);
      
      // Clear processed frames
      _frames.clear();
      
      // Convert result to List<Map<String, dynamic>>
      return result.map((map) => Map<String, dynamic>.from(map)).toList();
    } catch (e, stackTrace) {
      _logger.severe('Error processing frames', e, stackTrace);
      return null;
    }
  }

  int get frameCount => _frames.length;

  ({DateTime start, DateTime end})? get timeRange {
    if (_frames.isEmpty) return null;
    return (
      start: DateTime.fromMillisecondsSinceEpoch(_frames.first.timeStamp),
      end: DateTime.fromMillisecondsSinceEpoch(_frames.last.timeStamp),
    );
  }

  void clear() {
    _frames.clear();
  }

  Future<List<SleepEpisode>> flush() async {
    final result = await processFrames();
    if (result == null) return [];

    final episodes = <SleepEpisode>[];
    for (final map in result) {
      try {
        final start = DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int);
        final end = DateTime.fromMillisecondsSinceEpoch(map['endTime'] as int);
        final stages = (map['stages'] as List).map((stage) {
          final stageStart = DateTime.fromMillisecondsSinceEpoch(stage['startTime'] as int);
          final stageEnd = DateTime.fromMillisecondsSinceEpoch(stage['endTime'] as int);
          final stageType = _parseStageType(stage['type'] as String);
          return SleepStage(
            start: stageStart,
            end: stageEnd,
            stage: stageType,
          );
        }).toList();

        final episode = SleepEpisode(
          start: start,
          end: end,
          deepMin: map['deepSleepMinutes'] as int,
          lightMin: map['lightSleepMinutes'] as int,
          remMin: map['remSleepMinutes'] as int,
          wakeMin: map['wakeMinutes'] as int,
          efficiency: map['efficiency'] as double,
          avgRespRate: map['avgRespRate'] as double,
          avgSpO2: map['avgSpO2'] as double,
          timeline: stages,
        );
        episodes.add(episode);
      } catch (e, stackTrace) {
        _logger.severe('Error creating sleep episode', e, stackTrace);
      }
    }
    return episodes;
  }

  StageType _parseStageType(String type) {
    switch (type.toLowerCase()) {
      case 'wake':
        return StageType.wake;
      case 'light':
        return StageType.light;
      case 'deep':
        return StageType.deep;
      case 'rem':
        return StageType.rem;
      default:
        return StageType.wake;
    }
  }
} 