import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

BetterPlayerConfiguration configurationBetterPlayer(
  int startPosition, {
  bool fullScreenByDefault = false,
  bool allowedScreenSleep = false,
  bool showControls = true,
}) {
  return BetterPlayerConfiguration(
    autoPlay: true,
    looping: false,

    fullScreenByDefault: fullScreenByDefault,
    allowedScreenSleep: allowedScreenSleep,
    aspectRatio: 16 / 9,
    fit: BoxFit.contain,
    autoDetectFullscreenDeviceOrientation: true,
    autoDetectFullscreenAspectRatio: true,
    fullScreenAspectRatio: 9 / 16,
    
    deviceOrientationsOnFullScreen: const [DeviceOrientation.portraitUp],
    deviceOrientationsAfterFullScreen: const [DeviceOrientation.portraitUp],
    startAt: Duration(milliseconds: startPosition),
    controlsConfiguration: BetterPlayerControlsConfiguration(
      enableProgressText: true,
      progressBarPlayedColor: Colors.red,
      enableAudioTracks: false,
      enableQualities: false,
      showControls: showControls,
      enableSubtitles: false,
      controlBarColor: Colors.black.withOpacity(0.5),
      progressBarHandleColor: Colors.red,
      
    ),
  );
}

BetterPlayerPlaylistConfiguration createPlayList(
    {required bool loopVideos, required int nextVideoDelay}) {
  return BetterPlayerPlaylistConfiguration(
      nextVideoDelay: Duration(seconds: nextVideoDelay),
      loopVideos: loopVideos);
}

BetterPlayerCacheConfiguration cacheConfiguration(String videoUrl,
    {int maxCacheSize = 50 * 1024 * 1024}) {
  return BetterPlayerCacheConfiguration(
      useCache: true,
      maxCacheSize: maxCacheSize,
      key: videoUrl.toString(),
      maxCacheFileSize: 50 * 1024 * 1024,
      preCacheSize: 10 * 1024 * 1024);
}
