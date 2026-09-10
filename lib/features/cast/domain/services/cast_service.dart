import '../../../../core/constants/cast_config.dart';
import '../../../../core/models/cast_device.dart';
import '../../../../core/models/stream_item.dart';
import '../../data/repositories/cast_repository.dart';

/// Why a stream can or cannot be sent to a receiver.
enum CastAvailability {
  /// StreamCast can load the media itself.
  castable,

  /// The platform's own player carries the cast button — YouTube.
  nativeOnly,

  /// The stream is a web embed with no castable media URL, and the relay that
  /// would republish it as HLS is not configured.
  needsRelay,
}

/// Casting business logic.
///
/// The rule that defines the product lives here: platforms without a native
/// cast button are relayed by StreamCast, so *everything* is castable.
class CastService {
  CastService({required CastRepository castRepository})
    : _repository = castRepository;

  final CastRepository _repository;

  /// True when the platform ships a Cast SDK at all.
  bool get isSupported => CastRepository.isSupported;

  Future<void> init() => _repository.init();

  Stream<List<CastDevice>> devicesStream() => _repository.devicesStream();

  Stream<bool> connectionStream() => _repository.connectionStream();

  Future<void> startDiscovery() => _repository.startDiscovery();

  Future<void> stopDiscovery() => _repository.stopDiscovery();

  Future<bool> connect(CastDevice device) => _repository.connect(device);

  Future<void> disconnect() => _repository.disconnect();

  Future<void> setVolume(int value) => _repository.setVolume(value);

  Future<void> setPaused(bool paused) =>
      paused ? _repository.pause() : _repository.play();

  /// How — or whether — [item] reaches a receiver.
  ///
  /// The Default Media Receiver plays media URLs, not web pages. A direct
  /// MP4/HLS link goes straight across; YouTube casts through its own embed
  /// button; everything else is a web-only player and needs the relay to
  /// republish it as HLS first.
  CastAvailability availabilityFor(StreamItem item) {
    if (item.platform == StreamPlatform.direct) {
      return CastAvailability.castable;
    }
    if (item.platform.hasNativeCast) return CastAvailability.nativeOnly;
    return CastConfig.hasRelay
        ? CastAvailability.castable
        : CastAvailability.needsRelay;
  }

  /// The URL to hand the receiver, or null when [item] isn't castable by us.
  String? castUrlFor(StreamItem item) => switch (availabilityFor(item)) {
    CastAvailability.castable =>
      item.platform == StreamPlatform.direct
          ? item.sourceUrl
          : CastConfig.relayUrlFor(item.sourceUrl),
    _ => null,
  };

  /// Loads [item] onto the connected receiver. Returns false when it isn't
  /// something StreamCast can cast.
  Future<bool> loadOnReceiver(StreamItem item) async {
    final url = castUrlFor(item);
    if (url == null) return false;

    await _repository.loadMedia(
      contentId: item.id,
      url: url,
      title: item.title,
      subtitle: '${item.channelName} · ${item.platform.label}',
      isLive: item.isLive,
    );
    return true;
  }

  /// Whether the watch page should show its own full-width `Cast to TV`
  /// button.
  ///
  /// A direct video file has no embedded player chrome to cast from, so
  /// StreamCast supplies the control. YouTube ships its own button inside the
  /// embed, and the rest cast through the header icon.
  bool needsDirectCastButton(StreamItem item) =>
      item.platform == StreamPlatform.direct;

  /// The mono caption under the direct-cast button.
  String relayCaption(StreamItem item) => switch (availabilityFor(item)) {
    CastAvailability.nativeOnly => '// native cast · platform player',
    CastAvailability.castable => '// direct stream · streamcast relay',
    CastAvailability.needsRelay => '// relay offline · cast unavailable',
  };
}
