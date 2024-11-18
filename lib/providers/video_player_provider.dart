import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';

class VideoPlayerProvider extends ChangeNotifier {
  BetterPlayerController? _betterPlayerController;
  String? _currentVideoUrl;
  bool _isPlaying = false;
  bool _isDisposed = false;

  BetterPlayerController? get betterPlayerController => _betterPlayerController;
  String? get currentVideoUrl => _currentVideoUrl;
  bool get isPlaying => _isPlaying;

  void setBetterPlayerController(BetterPlayerController controller) {
    _betterPlayerController = controller;
    notifyListeners();
  }

  void play() {
    _betterPlayerController?.play();
    _isPlaying = true;
    notifyListeners();
  }

  void pause() {
    _betterPlayerController?.pause();
    _isPlaying = false;
    notifyListeners();
  }

  void setCurrentVideo(String url) {
    _currentVideoUrl = url;
    notifyListeners();
  }

  void disposePlayer() {
    _betterPlayerController?.dispose();
    _isDisposed = true;
    notifyListeners();
  }
}
