import 'package:flutter_test/flutter_test.dart';
import 'package:streamcast_app/core/constants/cast_config.dart';
import 'package:streamcast_app/core/models/cast_device.dart';
import 'package:streamcast_app/core/models/stream_item.dart';
import 'package:streamcast_app/features/cast/data/repositories/cast_repository.dart';
import 'package:streamcast_app/features/cast/domain/services/cast_service.dart';

StreamItem _item(StreamPlatform platform, {String url = 'https://x.test/a'}) =>
    StreamItem(
      id: 'x',
      title: 't',
      channelName: 'c',
      platform: platform,
      status: StreamStatus.live,
      sourceUrl: url,
    );

void main() {
  final service = CastService(castRepository: CastRepository());

  group('CastService.availabilityFor', () {
    test('a direct media URL is castable by StreamCast', () {
      expect(
        service.availabilityFor(_item(StreamPlatform.direct)),
        CastAvailability.castable,
      );
    });

    test('YouTube casts from its own player', () {
      expect(
        service.availabilityFor(_item(StreamPlatform.youtube)),
        CastAvailability.nativeOnly,
      );
    });

    test('web-only players need the relay, which is not deployed', () {
      // Guard the premise: these expectations describe the un-relayed build.
      expect(CastConfig.hasRelay, isFalse);

      for (final platform in [
        StreamPlatform.twitch,
        StreamPlatform.kick,
        StreamPlatform.facebook,
        StreamPlatform.vimeo,
      ]) {
        expect(
          service.availabilityFor(_item(platform)),
          CastAvailability.needsRelay,
          reason: platform.name,
        );
      }
    });
  });

  group('CastService.castUrlFor', () {
    test('a direct stream is sent as-is', () {
      const url = 'https://cdn.test/master.m3u8';
      expect(service.castUrlFor(_item(StreamPlatform.direct, url: url)), url);
    });

    test('platforms StreamCast cannot cast yield no URL', () {
      expect(service.castUrlFor(_item(StreamPlatform.youtube)), isNull);
      expect(service.castUrlFor(_item(StreamPlatform.twitch)), isNull);
    });
  });

  group('CastService.relayCaption', () {
    test('names the mechanism the stream actually uses', () {
      expect(
        service.relayCaption(_item(StreamPlatform.direct)),
        '// direct stream · streamcast relay',
      );
      expect(
        service.relayCaption(_item(StreamPlatform.youtube)),
        '// native cast · platform player',
      );
      expect(
        service.relayCaption(_item(StreamPlatform.twitch)),
        '// relay offline · cast unavailable',
      );
    });
  });

  group('CastRepository', () {
    test('reports no support off Android and iOS', () {
      // The suite runs on the host, where no Cast SDK is bound. Every entry
      // point must degrade rather than throw.
      expect(CastRepository.isSupported, isFalse);
    });

    test('degrades to an empty device list instead of throwing', () async {
      final repository = CastRepository();
      await repository.init();
      await repository.startDiscovery();

      expect(await repository.devicesStream().first, isEmpty);
      expect(await repository.connectionStream().first, isFalse);
      expect(
        await repository.connect(
          const CastDevice(
            id: 'nope',
            name: 'Living Room TV',
            subtitle: 'Google Cast',
            type: CastDeviceType.chromecast,
          ),
        ),
        isFalse,
      );

      // These must all be no-ops rather than errors.
      await repository.play();
      await repository.pause();
      await repository.setVolume(50);
      await repository.disconnect();
      await repository.stopDiscovery();
    });
  });
}
