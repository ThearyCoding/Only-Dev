import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

enum DownloadStatus { queued, downloading, completed, failed, paused, canceled }

extension DownloadStatusExtension on DownloadStatus {
  bool get isCompleted {
    switch (this) {
      case DownloadStatus.queued:
      case DownloadStatus.downloading:
      case DownloadStatus.paused:
        return false;
      case DownloadStatus.completed:
      case DownloadStatus.failed:
      case DownloadStatus.canceled:
        return true;
    }
  }
}

class DownloadRequest {
  final String url;
  final String path;
  var cancelToken = CancelToken();
  var forceDownload = false;

  DownloadRequest(this.url, this.path);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadRequest &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          path == other.path;

  @override
  int get hashCode => url.hashCode ^ path.hashCode;
}

class DownloadTask {
  final DownloadRequest request;
  ValueNotifier<DownloadStatus> status = ValueNotifier(DownloadStatus.queued);
  ValueNotifier<double> progress = ValueNotifier(0);

  DownloadTask(this.request);

  Future<DownloadStatus> whenDownloadComplete(
      {Duration timeout = const Duration(hours: 2)}) async {
    final completer = Completer<DownloadStatus>();

    if (status.value.isCompleted) {
      completer.complete(status.value);
      return completer.future;
    }

    late void Function() listener;
    listener = () {
      if (status.value.isCompleted) {
        if (!completer.isCompleted) {
          completer.complete(status.value);
        }
        status.removeListener(listener);
      }
    };

    status.addListener(listener);
    return completer.future.timeout(timeout, onTimeout: () {
      status.removeListener(listener);
      return status.value;
    });
  }
}

class DownloadManager {
  final Map<String, DownloadTask> _cache = <String, DownloadTask>{};
  final Queue<DownloadRequest> _queue = Queue();
  var dio = Dio();
  static const partialExtension = ".partial";
  static const tempExtension = ".temp";

  int maxConcurrentTasks = 2;
  int runningTasks = 0;

  static final DownloadManager _dm = DownloadManager._internal();

  DownloadManager._internal();

  factory DownloadManager({
    int? maxConcurrentTasks,
    Dio? dio,
  }) {
    if (maxConcurrentTasks != null) {
      _dm.maxConcurrentTasks = maxConcurrentTasks;
    }
    if (dio != null) {
      _dm.dio = dio;
    }
    return _dm;
  }

  void Function(int, int) createCallback(String url, int partialFileLength) =>
      (int received, int total) {
        if (total > 0) {
          getDownload(url)?.progress.value =
              (received + partialFileLength) / (total + partialFileLength);
        }
      };

  Future<void> download(String url, String savePath, CancelToken cancelToken,
      {bool forceDownload = false}) async {
    late String partialFilePath;
    late File partialFile;
    try {
      var task = getDownload(url);

      if (task == null || task.status.value == DownloadStatus.canceled) {
        return;
      }
      setStatus(task, DownloadStatus.downloading);

      if (kDebugMode) {
        print('Downloading: $url -> $savePath');
      }
      var file = File(savePath);
      partialFilePath = savePath + partialExtension;
      partialFile = File(partialFilePath);

      var fileExist = await file.exists();
      var partialFileExist = await partialFile.exists();

      if (fileExist && !forceDownload) {
        if (kDebugMode) {
          print("File exists, download completed");
        }
        task.progress.value = 1.0;
        setStatus(task, DownloadStatus.completed);
      } else if (partialFileExist) {
        if (kDebugMode) {
          print("Partial file exists, resuming");
        }

        var partialFileLength = await partialFile.length();

        var response = await dio.download(url, partialFilePath + tempExtension,
            onReceiveProgress: createCallback(url, partialFileLength),
            options: Options(
              headers: {HttpHeaders.rangeHeader: 'bytes=$partialFileLength-'},
            ),
            cancelToken: cancelToken,
            deleteOnError: true);

        if (response.statusCode == HttpStatus.partialContent ||
            response.statusCode == HttpStatus.ok) {
          var ioSink = partialFile.openWrite(mode: FileMode.writeOnlyAppend);
          var tempF = File(partialFilePath + tempExtension);
          if (await tempF.exists()) {
            await ioSink.addStream(tempF.openRead());
            await tempF.delete();
          }
          await ioSink.close();
          await partialFile.rename(savePath);

          task.progress.value = 1.0;
          setStatus(task, DownloadStatus.completed);
        }
      } else {
        var response = await dio.download(url, partialFilePath,
            onReceiveProgress: createCallback(url, 0),
            cancelToken: cancelToken,
            deleteOnError: false);

        if (response.statusCode == HttpStatus.ok) {
          await partialFile.rename(savePath);
          task.progress.value = 1.0;
          setStatus(task, DownloadStatus.completed);
        }
      }
    } catch (e) {
      var task = getDownload(url);
      if (task != null) {
        if (task.status.value != DownloadStatus.canceled &&
            task.status.value != DownloadStatus.paused) {
          setStatus(task, DownloadStatus.failed);
          runningTasks--;

          if (_queue.isNotEmpty) {
            _startExecution();
          }
          return;
        } else if (task.status.value == DownloadStatus.paused) {
          try {
            final ioSink = partialFile.openWrite(mode: FileMode.writeOnlyAppend);
            final f = File(partialFilePath + tempExtension);
            if (await f.exists()) {
              await ioSink.addStream(f.openRead());
              await f.delete();
            }
            await ioSink.close();
          } catch (_) {}
        }
      }
    }

    runningTasks--;

    if (_queue.isNotEmpty) {
      _startExecution();
    }
  }

  void setStatus(DownloadTask? task, DownloadStatus status) {
    if (task != null) {
      task.status.value = status;
    }
  }

  Future<DownloadTask?> addDownload(String url, String savedDir) async {
    if (url.isNotEmpty) {
      if (savedDir.isEmpty) {
        savedDir = ".";
      }

      var isDirectory = await Directory(savedDir).exists();
      var downloadFilename = isDirectory
          ? savedDir + Platform.pathSeparator + getFileNameFromUrl(url)
          : savedDir;

      return _addDownloadRequest(DownloadRequest(url, downloadFilename));
    }
    return null;
  }

  Future<DownloadTask> _addDownloadRequest(
    DownloadRequest downloadRequest,
  ) async {
    if (_cache[downloadRequest.url] != null) {
      if (!_cache[downloadRequest.url]!.status.value.isCompleted &&
          _cache[downloadRequest.url]!.request == downloadRequest) {
        return _cache[downloadRequest.url]!;
      } else {
        _queue.remove(_cache[downloadRequest.url]?.request);
      }
    }

    final req = DownloadRequest(downloadRequest.url, downloadRequest.path);
    _queue.add(req);
    var task = DownloadTask(req);

    _cache[downloadRequest.url] = task;

    _startExecution();

    return task;
  }

  Future<void> pauseDownload(String url) async {
    if (kDebugMode) {
      print("Pause Download: $url");
    }
    var task = getDownload(url);
    if (task != null) {
      setStatus(task, DownloadStatus.paused);
      task.request.cancelToken.cancel();
      _queue.remove(task.request);
    }
  }

  Future<void> cancelDownload(String url) async {
    if (kDebugMode) {
      print("Cancel Download: $url");
    }
    var task = getDownload(url);
    if (task != null) {
      setStatus(task, DownloadStatus.canceled);
      _queue.remove(task.request);
      task.request.cancelToken.cancel();
    }
  }

  Future<void> resumeDownload(String url) async {
    if (kDebugMode) {
      print("Resume Download: $url");
    }
    var task = getDownload(url);
    if (task != null) {
      setStatus(task, DownloadStatus.downloading);
      task.request.cancelToken = CancelToken();
      _queue.add(task.request);
      _startExecution();
    }
  }

  Future<void> removeDownload(String url) async {
    await cancelDownload(url);
    _cache.remove(url);
  }

  DownloadTask? getDownload(String url) {
    return _cache[url];
  }

  Future<DownloadStatus> whenDownloadComplete(String url,
      {Duration timeout = const Duration(hours: 2)}) async {
    DownloadTask? task = getDownload(url);

    if (task != null) {
      return task.whenDownloadComplete(timeout: timeout);
    } else {
      return Future.error("Not found");
    }
  }

  List<DownloadTask> getAllDownloads() {
    return _cache.values.toList();
  }

  Future<void> addBatchDownloads(List<String> urls, String savedDir) async {
    for (var url in urls) {
      await addDownload(url, savedDir);
    }
  }

  List<DownloadTask?> getBatchDownloads(List<String> urls) {
    return urls.map((e) => _cache[e]).toList();
  }

  Future<void> pauseBatchDownloads(List<String> urls) async {
    for (var element in urls) {
      await pauseDownload(element);
    }
  }

  Future<void> cancelBatchDownloads(List<String> urls) async {
    for (var element in urls) {
      await cancelDownload(element);
    }
  }

  Future<void> resumeBatchDownloads(List<String> urls) async {
    for (var element in urls) {
      await resumeDownload(element);
    }
  }

  ValueNotifier<double> getBatchDownloadProgress(List<String> urls) {
    ValueNotifier<double> progress = ValueNotifier(0);
    var total = urls.length;

    if (total == 0) {
      return progress;
    }

    if (total == 1) {
      return getDownload(urls.first)?.progress ?? progress;
    }

    var progressMap = <String, double>{};

    for (var url in urls) {
      DownloadTask? task = getDownload(url);

      if (task != null) {
        progressMap[url] = 0.0;

        if (task.status.value.isCompleted) {
          progressMap[url] = 1.0;
          progress.value = progressMap.values.sum / total;
        }

        void progressListener() {
          progressMap[url] = task.progress.value;
          progress.value = progressMap.values.sum / total;
        }

        task.progress.addListener(progressListener);

        late void Function() statusListener;
        statusListener = () {
          if (task.status.value.isCompleted) {
            progressMap[url] = 1.0;
            progress.value = progressMap.values.sum / total;
            task.status.removeListener(statusListener);
            task.progress.removeListener(progressListener);
          }
        };

        task.status.addListener(statusListener);
      } else {
        total--;
      }
    }

    return progress;
  }

  Future<List<DownloadTask?>?> whenBatchDownloadsComplete(List<String> urls,
      {Duration timeout = const Duration(hours: 2)}) async {
    var completer = Completer<List<DownloadTask?>?>();

    var completed = 0;
    var total = urls.length;

    for (var url in urls) {
      DownloadTask? task = getDownload(url);

      if (task != null) {
        if (task.status.value.isCompleted) {
          completed++;

          if (completed == total) {
            completer.complete(getBatchDownloads(urls));
          }
        }

        late void Function() listener;
        listener = () {
          if (task.status.value.isCompleted) {
            completed++;

            if (completed == total) {
              if (!completer.isCompleted) {
                completer.complete(getBatchDownloads(urls));
              }
              task.status.removeListener(listener);
            }
          }
        };

        task.status.addListener(listener);
      } else {
        total--;

        if (total == 0) {
          completer.complete(null);
        }
      }
    }

    return completer.future.timeout(timeout);
  }

  void _startExecution() async {
    if (runningTasks >= maxConcurrentTasks || _queue.isEmpty) {
      return;
    }

    while (_queue.isNotEmpty && runningTasks < maxConcurrentTasks) {
      runningTasks++;
      if (kDebugMode) {
        print('Concurrent download workers: $runningTasks');
      }
      var currentRequest = _queue.removeFirst();

      download(
        currentRequest.url,
        currentRequest.path,
        currentRequest.cancelToken,
        forceDownload: currentRequest.forceDownload,
      );

      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  String getFileNameFromUrl(String url) {
    return url.split('/').last;
  }
}
