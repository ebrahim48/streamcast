import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_chrome_cast/cast_context.dart';
import 'package:flutter_chrome_cast/discovery.dart';
import 'package:flutter_chrome_cast/entities.dart';
import 'package:flutter_chrome_cast/common.dart';
import 'package:flutter_chrome_cast/media.dart';
import 'package:flutter_chrome_cast/models.dart';
import 'package:flutter_chrome_cast/session.dart';

import '../../../../core/constants/cast_config.dart';
import '../../../../core/models/cast_device.dart';

/// Google Cast, behind the app's own [CastDevice] model.
///
/// Wraps `flutter_chrome_cast`, which binds the real Cast SDK on Android and
/// iOS. Content is loaded into Google's Default Media Receiver — StreamCast
/// ships no custom receiver — so whatever is sent must be a media URL the
/// receiver can play (MP4/HLS), not a web embed.
///
/// The SDK is unavailable on desktop and in tests, so every entry point is
/// guarded by [isSupported] and the repository degrades to "no devices" rather
/// than throwing.
class CastRepository {
  CastRepository();

  /// Cast is an Android/iOS-only SDK.
  static bool get isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  bool _initialized = false;

  /// Sets up the Cast context against the Default Media Receiver.
  ///
  /// Safe to call more than once; safe to call on an unsupported platform.
  Future<void> init() async {
    if (_initialized || !isSupported) return;

    try {
      const appId = CastConfig.defaultReceiverAppId;
      final GoogleCastOptions options = Platform.isIOS
          ? IOSGoogleCastOptions(
              GoogleCastDiscoveryCriteriaInitialize.initWithApplicationID(
                appId,
              ),
            )
          : GoogleCastOptionsAndroid(appId: appId);

      GoogleCastContext.instance.setSharedInstanceWithOptions(options);
      _initialized = true;
    } catch (e) {
      debugPrint('Cast init failed: $e');
    }
  }

  /// Receivers seen on the local network, as they appear and disappear.
  Stream<List<CastDevice>> devicesStream() {
    if (!isSupported) return Stream.value(const []);
    return GoogleCastDiscoveryManager.instance.devicesStream.map(
      (devices) => devices.map(_toCastDevice).toList(),
    );
  }

  /// True while a receiver session is connected.
  Stream<bool> connectionStream() {
    if (!isSupported) return Stream.value(false);
    return GoogleCastSessionManager.instance.currentSessionStream.map(
      (session) => session != null,
    );
  }

  Future<void> startDiscovery() async {
    if (!isSupported) return;
    await init();
    GoogleCastDiscoveryManager.instance.startDiscovery();
  }

  Future<void> stopDiscovery() async {
    if (!isSupported) return;
    GoogleCastDiscoveryManager.instance.stopDiscovery();
  }

  /// Opens a session with [device].
  Future<bool> connect(CastDevice device) async {
    if (!isSupported) return false;

    final target = _findNative(device.id);
    if (target == null) return false;

    return GoogleCastSessionManager.instance.startSessionWithDevice(target);
  }

  /// Hands a media URL to the connected receiver.
  ///
  /// [isLive] selects the receiver's live stream type, which is what stops it
  /// from presenting a seek bar over a broadcast that has no fixed duration.
  Future<void> loadMedia({
    required String contentId,
    required String url,
    required String title,
    required String subtitle,
    required bool isLive,
    String? imageUrl,
  }) async {
    if (!isSupported) return;

    await GoogleCastRemoteMediaClient.instance.loadMedia(
      GoogleCastMediaInformationIOS(
        contentId: contentId,
        streamType: isLive
            ? CastMediaStreamType.live
            : CastMediaStreamType.buffered,
        contentUrl: Uri.parse(url),
        contentType: _contentTypeFor(url),
        metadata: GoogleCastGenericMediaMetadata(
          title: title,
          subtitle: subtitle,
          images: [
            if (imageUrl != null)
              GoogleCastImage(
                url: Uri.parse(imageUrl),
                height: 360,
                width: 640,
              ),
          ],
        ),
      ),
      autoPlay: true,
    );
  }

  /// MIME type the receiver needs in order to pick a demuxer.
  String _contentTypeFor(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
    if (path.endsWith('.m3u8')) return 'application/x-mpegURL';
    if (path.endsWith('.mpd')) return 'application/dash+xml';
    if (path.endsWith('.webm')) return 'video/webm';
    return 'video/mp4';
  }

  Future<void> play() async {
    if (!isSupported) return;
    await GoogleCastRemoteMediaClient.instance.play();
  }

  Future<void> pause() async {
    if (!isSupported) return;
    await GoogleCastRemoteMediaClient.instance.pause();
  }

  /// Receiver volume, 0–100 as the UI expresses it.
  Future<void> setVolume(int percent) async {
    if (!isSupported) return;
    GoogleCastSessionManager.instance.setDeviceVolume(
      (percent.clamp(0, 100)) / 100,
    );
  }

  Future<void> disconnect() async {
    if (!isSupported) return;
    await GoogleCastSessionManager.instance.endSessionAndStopCasting();
  }

  GoogleCastDevice? _findNative(String id) {
    for (final d in GoogleCastDiscoveryManager.instance.devices) {
      if (d.deviceID == id) return d;
    }
    return null;
  }

  CastDevice _toCastDevice(GoogleCastDevice device) => CastDevice(
    id: device.deviceID,
    name: device.friendlyName,
    subtitle: device.modelName ?? 'Google Cast',
    type: _typeFor(device.modelName),
  );

  CastDeviceType _typeFor(String? model) {
    final m = (model ?? '').toLowerCase();
    if (m.contains('apple tv')) return CastDeviceType.appleTv;
    if (m.contains('airplay')) return CastDeviceType.airplay;
    if (m.contains('chromecast') || m.contains('google')) {
      return CastDeviceType.chromecast;
    }
    return CastDeviceType.smartTv;
  }
}
