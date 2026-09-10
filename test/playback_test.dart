import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:streamcast_app/core/models/stream_item.dart';
import 'package:streamcast_app/features/ads/domain/services/ad_service.dart';
import 'package:streamcast_app/features/watch/domain/services/playback_service.dart';

StreamItem _item({
  required StreamPlatform platform,
  required String url,
  StreamStatus status = StreamStatus.live,
}) => StreamItem(
  id: 'x',
  title: 't',
  channelName: 'c',
  platform: platform,
  status: status,
  sourceUrl: url,
);

void main() {
  group('PlaybackService.embedUrl', () {
    final service = PlaybackService();

    test('YouTube accepts both the watch and short link forms', () {
      final watch = _item(
        platform: StreamPlatform.youtube,
        url: 'https://www.youtube.com/watch?v=mKCieTImjvU',
      );
      final short = _item(
        platform: StreamPlatform.youtube,
        url: 'https://youtu.be/mKCieTImjvU',
      );

      expect(service.embedUrl(watch), contains('/embed/mKCieTImjvU'));
      expect(service.embedUrl(short), contains('/embed/mKCieTImjvU'));
    });

    test('Twitch uses the channel when live and the video id otherwise', () {
      final live = _item(
        platform: StreamPlatform.twitch,
        url: 'https://www.twitch.tv/novaesports',
      );
      final vod = _item(
        platform: StreamPlatform.twitch,
        url: 'https://www.twitch.tv/videos/12345',
        status: StreamStatus.vod,
      );

      expect(service.embedUrl(live), contains('channel=novaesports'));
      expect(service.embedUrl(live), contains('parent='));
      expect(service.embedUrl(vod), contains('video=12345'));
    });

    test('Kick embeds live channels only', () {
      final live = _item(
        platform: StreamPlatform.kick,
        url: 'https://kick.com/kaiplays',
      );
      final vod = _item(
        platform: StreamPlatform.kick,
        url: 'https://kick.com/kaiplays/videos/setup-tour',
        status: StreamStatus.vod,
      );

      expect(service.embedUrl(live), 'https://player.kick.com/kaiplays');
      expect(service.embedUrl(vod), isNull);
    });

    test('Vimeo uses the numeric id', () {
      final vod = _item(
        platform: StreamPlatform.vimeo,
        url: 'https://vimeo.com/76979871',
        status: StreamStatus.vod,
      );
      expect(service.embedUrl(vod), contains('/video/76979871'));
    });

    test('an empty source yields no embed', () {
      expect(
        service.embedUrl(_item(platform: StreamPlatform.youtube, url: '')),
        isNull,
      );
    });
  });

  group('PlaybackService.modeFor', () {
    final service = PlaybackService();

    test('a direct file plays natively', () {
      expect(
        service.modeFor(
          _item(
            platform: StreamPlatform.direct,
            url: 'https://cdn.example.com/a.m3u8',
          ),
        ),
        PlaybackMode.native,
      );
    });

    test('an embeddable platform plays in a WebView', () {
      expect(
        service.modeFor(
          _item(platform: StreamPlatform.youtube, url: 'https://youtu.be/abc'),
        ),
        PlaybackMode.embed,
      );
    });

    test('offline and errored streams play nothing', () {
      for (final status in [StreamStatus.offline, StreamStatus.error]) {
        expect(
          service.modeFor(
            _item(
              platform: StreamPlatform.youtube,
              url: 'https://youtu.be/abc',
              status: status,
            ),
          ),
          PlaybackMode.none,
          reason: 'status $status',
        );
      }
    });

    test('a Kick VOD has nothing to play', () {
      expect(
        service.modeFor(
          _item(
            platform: StreamPlatform.kick,
            url: 'https://kick.com/kaiplays/videos/x',
            status: StreamStatus.vod,
          ),
        ),
        PlaybackMode.none,
      );
    });
  });

  group('PlaybackService.embedHtml', () {
    test('hosts the URL in a full-bleed iframe', () {
      final html = PlaybackService().embedHtml('https://example.com/p');
      expect(html, contains('src="https://example.com/p"'));
      expect(html, contains('allowfullscreen'));
      expect(html, contains('margin:0'));
    });
  });

  group('AdService', () {
    test('every gap falls inside the 3–4 minute window', () {
      final service = AdService(random: Random(7));
      for (var i = 0; i < 200; i++) {
        final gap = service.nextGap();
        expect(gap, greaterThanOrEqualTo(AdService.minGap));
        expect(gap, lessThanOrEqualTo(AdService.maxGap));
      }
    });

    test('gaps vary rather than repeating one interval', () {
      final service = AdService(random: Random(7));
      final seen = {for (var i = 0; i < 60; i++) service.nextGap().inSeconds};
      expect(seen.length, greaterThan(1));
    });

    test('breaks are suppressed for premium and during a reward grant', () {
      final service = AdService();
      expect(
        service.shouldShowAds(isPremium: false, rewardActive: false),
        isTrue,
      );
      expect(
        service.shouldShowAds(isPremium: true, rewardActive: false),
        isFalse,
      );
      expect(
        service.shouldShowAds(isPremium: false, rewardActive: true),
        isFalse,
      );
    });

    test('skipping unlocks before the break ends', () {
      expect(AdService.skipAfter, lessThan(AdService.interstitialLength));
    });
  });
}
