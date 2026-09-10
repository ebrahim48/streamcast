import 'package:flutter/foundation.dart';

/// Receiver families StreamCast can hand a stream to.
enum CastDeviceType { chromecast, airplay, appleTv, smartTv }

/// A discoverable receiver on the local network.
@immutable
class CastDevice {
  const CastDevice({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.type,
  });

  final String id;

  /// Friendly name the user gave the device, e.g. "Living Room TV".
  final String name;

  /// Mono subtitle under the name, e.g. "Samsung · AirPlay 2".
  final String subtitle;

  final CastDeviceType type;
}

/// Where the cast sheet is in its discovery cycle.
enum CastState {
  /// Sheet closed, nothing connected.
  idle,

  /// Scanning the local network.
  searching,

  /// Scan finished with no receivers.
  notFound,

  /// Receivers found and listed.
  found,

  /// Streaming to a receiver.
  connected,
}
