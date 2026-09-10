import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/models/stream_item.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_dimens.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/stream_thumbnail.dart';
import '../../domain/services/playback_service.dart';

/// Real playback for one stream.
///
/// Two engines behind one widget:
/// - [PlaybackMode.embed] — the platform's own web player in a WebView, so
///   YouTube keeps its cast button and Twitch keeps its official player.
/// - [PlaybackMode.native] — an MP4/HLS URL through `video_player`.
///
/// Until the viewer taps play it shows the poster frame, so opening a page
/// never costs a stream the user didn't ask for — and on the ad-supported tier
/// the ad timer only starts once playback does.
class StreamPlayerView extends StatefulWidget {
  const StreamPlayerView({
    super.key,
    required this.item,
    required this.playbackService,
    this.onStarted,
    this.onFailed,
    this.paused = false,
  });

  final StreamItem item;
  final PlaybackService playbackService;

  /// Holds playback while an ad break is on screen.
  ///
  /// Only the native engine can honour this. A platform embed runs in a
  /// cross-origin iframe that the app cannot script, so a break over a
  /// YouTube or Twitch player covers it rather than stopping it — which is
  /// also how those platforms' own overlays behave.
  final bool paused;

  /// Fired once real playback begins — the watch-time clock starts here.
  final VoidCallback? onStarted;

  /// Fired when the engine can't load the source.
  final VoidCallback? onFailed;

  @override
  State<StreamPlayerView> createState() => _StreamPlayerViewState();
}

class _StreamPlayerViewState extends State<StreamPlayerView> {
  WebViewController? _web;
  VideoPlayerController? _video;

  bool _started = false;
  bool _buffering = false;
  bool _failed = false;

  PlaybackMode get _mode => widget.playbackService.modeFor(widget.item);

  @override
  void didUpdateWidget(StreamPlayerView old) {
    super.didUpdateWidget(old);

    if (old.paused != widget.paused && _video != null) {
      widget.paused ? _video!.pause() : _video!.play();
    }

    // A retry, or a different stream on the same route, has to drop whatever
    // engine the previous source was using.
    if (old.item.id != widget.item.id ||
        old.item.status != widget.item.status) {
      _teardown();
      setState(() {
        _started = false;
        _failed = false;
      });
    }
  }

  void _teardown() {
    _video?.dispose();
    _video = null;
    _web = null;
  }

  @override
  void dispose() {
    _teardown();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _buffering = true;
      _failed = false;
    });

    try {
      switch (_mode) {
        case PlaybackMode.embed:
          await _startEmbed();
        case PlaybackMode.native:
          await _startNative();
        case PlaybackMode.none:
          throw StateError('nothing playable for ${widget.item.id}');
      }
      if (!mounted) return;
      setState(() {
        _started = true;
        _buffering = false;
      });
      widget.onStarted?.call();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _buffering = false;
        _failed = true;
      });
      widget.onFailed?.call();
    }
  }

  Future<void> _startEmbed() async {
    final url = widget.playbackService.embedUrl(widget.item)!;

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.bgPrimary)
      // The platform players handle their own fullscreen and audio; media
      // playback must not need a second gesture once the user has tapped play.
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            if (error.isForMainFrame ?? true) _fail();
          },
        ),
      );

    await controller.loadHtmlString(
      widget.playbackService.embedHtml(url),
      // A base URL is required for the iframe's origin check: Twitch and Kick
      // reject embeds whose parent doesn't match what they were told.
      baseUrl: 'https://${PlaybackService.embedParent}',
    );

    _web = controller;
  }

  Future<void> _startNative() async {
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.item.sourceUrl),
    );
    await controller.initialize();
    await controller.setLooping(false);
    await controller.play();
    _video = controller;
  }

  void _fail() {
    if (!mounted || _failed) return;
    setState(() => _failed = true);
    widget.onFailed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ColoredBox(color: AppColors.black, child: _body()),
    );
  }

  Widget _body() {
    if (_failed) return _PlayerMessage(text: "Couldn't load this stream");

    if (_started && _web != null) {
      return WebViewWidget(controller: _web!);
    }
    if (_started && _video != null) {
      return Center(
        child: AspectRatio(
          aspectRatio: _video!.value.aspectRatio,
          child: VideoPlayer(_video!),
        ),
      );
    }

    // Poster frame with the play affordance, or a spinner while the engine
    // spins up.
    return Stack(
      fit: StackFit.expand,
      children: [
        StreamThumbnail(seed: widget.item.thumbnailSeed, radius: 0),
        if (_buffering)
          const ColoredBox(
            color: Color(0x88000000),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.accentSignal,
                strokeWidth: 2.5,
              ),
            ),
          )
        else if (_mode == PlaybackMode.none)
          _PlayerMessage(text: _unplayableReason())
        else
          Center(child: _PlayButton(onTap: _start)),
      ],
    );
  }

  String _unplayableReason() =>
      widget.item.platform == StreamPlatform.kick && !widget.item.isLive
      ? 'Kick embeds live channels only'
      : "This source can't be played here";
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Play',
      child: InkResponse(
        onTap: onTap,
        radius: 40.r,
        child: Container(
          width: 56.r,
          height: 56.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.black.withValues(alpha: 0.42),
            border: Border.all(
              color: AppColors.textPrimary.withValues(alpha: 0.85),
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            size: 34.r,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _PlayerMessage extends StatelessWidget {
  const _PlayerMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.bgSurfaceElevated,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimens.gapXl.w),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(color: AppColors.textDim),
          ),
        ),
      ),
    );
  }
}
