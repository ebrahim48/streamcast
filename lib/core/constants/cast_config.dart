/// Casting configuration.
class CastConfig {
  CastConfig._();

  /// Google's Default Media Receiver application ID.
  ///
  /// StreamCast ships no custom receiver app, so content is loaded into
  /// Google's default one. It plays MP4 and HLS but nothing platform-specific,
  /// which is what [relayEndpoint] exists to bridge.
  static const String defaultReceiverAppId = 'CC1AD845';

  /// Base URL of the StreamCast relay.
  ///
  /// Twitch, Kick and Facebook Live have no castable media URL of their own —
  /// their players are web embeds. Casting them requires a server that
  /// re-publishes the stream as HLS, which the Default Media Receiver can play.
  ///
  /// **Not deployed yet.** While this is empty, [CastService] reports those
  /// platforms as needing the relay instead of failing at the receiver, and the
  /// cast sheet says so. Set it once the relay is live and casting starts
  /// working for those platforms with no other change.
  static const String relayEndpoint = String.fromEnvironment(
    'STREAMCAST_RELAY',
    defaultValue: '',
  );

  static bool get hasRelay => relayEndpoint.isNotEmpty;

  /// The HLS URL the relay would serve for [sourceUrl].
  static String relayUrlFor(String sourceUrl) =>
      '$relayEndpoint/hls?src=${Uri.encodeComponent(sourceUrl)}';
}
