import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/model_catalog.dart';

enum DownloadStatus { notDownloaded, downloading, downloaded, failed }

class ModelState {
  final DownloadStatus status;
  final double progress; // 0.0 - 1.0
  final String? error;
  const ModelState({
    this.status = DownloadStatus.notDownloaded,
    this.progress = 0.0,
    this.error,
  });

  ModelState copyWith({DownloadStatus? status, double? progress, String? error}) =>
      ModelState(
        status: status ?? this.status,
        progress: progress ?? this.progress,
        error: error,
      );
}

/// Manages downloading and tracking on-device models.
///
/// NOTE: This turn ships a *simulated* download so the whole UI/flow is
/// testable end-to-end. Next turn we swap `_simulateDownload` for a real
/// streamed file download + flutter_gemma model registration. The public
/// API here won't change, so the UI won't need edits.
class ModelManager {
  ModelManager._();
  static final ModelManager instance = ModelManager._();

  static const _kDownloadedPrefix = 'model_downloaded_';

  /// Per-model observable state, keyed by model id.
  final Map<String, ValueNotifier<ModelState>> _states = {};
  final Map<String, StreamSubscription?> _subs = {};

  ValueNotifier<ModelState> stateOf(String modelId) {
    return _states.putIfAbsent(modelId, () => ValueNotifier(const ModelState()));
  }

  /// Load persisted "downloaded" flags at startup.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    for (final m in ModelCatalog.models) {
      final done = prefs.getBool('$_kDownloadedPrefix${m.id}') ?? false;
      stateOf(m.id).value = ModelState(
        status: done ? DownloadStatus.downloaded : DownloadStatus.notDownloaded,
        progress: done ? 1.0 : 0.0,
      );
    }
  }

  bool isDownloaded(String modelId) =>
      stateOf(modelId).value.status == DownloadStatus.downloaded;

  Future<void> _markDownloaded(String modelId, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_kDownloadedPrefix$modelId', value);
  }

  /// Begin (simulated) download. Safe to call again to retry.
  Future<void> download(OnDeviceModel model) async {
    final notifier = stateOf(model.id);
    if (notifier.value.status == DownloadStatus.downloading) return;

    notifier.value = const ModelState(status: DownloadStatus.downloading, progress: 0.0);

    // --- Simulated progress (replace with real download next turn) ---
    _subs[model.id]?.cancel();
    var progress = 0.0;
    _subs[model.id] = Stream.periodic(const Duration(milliseconds: 350), (i) => i)
        .listen((_) async {
      progress += 0.06 + (0.04 * (model.sizeGb <= 1 ? 1.5 : 0.7));
      if (progress >= 1.0) {
        progress = 1.0;
        notifier.value = const ModelState(status: DownloadStatus.downloaded, progress: 1.0);
        await _markDownloaded(model.id, true);
        await _subs[model.id]?.cancel();
        _subs[model.id] = null;
      } else {
        notifier.value = ModelState(status: DownloadStatus.downloading, progress: progress);
      }
    });
  }

  Future<void> cancelDownload(String modelId) async {
    await _subs[modelId]?.cancel();
    _subs[modelId] = null;
    stateOf(modelId).value = const ModelState(status: DownloadStatus.notDownloaded, progress: 0.0);
  }

  Future<void> deleteModel(String modelId) async {
    await _subs[modelId]?.cancel();
    _subs[modelId] = null;
    await _markDownloaded(modelId, false);
    stateOf(modelId).value = const ModelState(status: DownloadStatus.notDownloaded, progress: 0.0);
  }
}
