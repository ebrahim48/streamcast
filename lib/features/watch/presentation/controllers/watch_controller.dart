import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/models/chat_message.dart';
import '../../../../core/models/comment_item.dart';
import '../../../../core/models/stream_item.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../ads/presentation/controllers/ad_controller.dart';
import '../../../cast/domain/services/cast_service.dart';
import '../../../library/presentation/controllers/library_controller.dart';
import '../../../main/presentation/controllers/main_shell_controller.dart';
import '../../../premium/presentation/controllers/premium_controller.dart';
import '../../domain/services/playback_service.dart';
import '../../domain/services/watch_service.dart';

/// Which engagement tab is showing.
enum WatchTab { chat, comments }

/// State for a single stream's watch page.
class WatchController extends GetxController {
  WatchController({
    required WatchService watchService,
    required CastService castService,
    required PlaybackService playback,
    required AdController adController,
    required LibraryController libraryController,
    required PremiumController premiumController,
    required StreamItem initialItem,
  }) : _service = watchService,
       _cast = castService,
       playbackService = playback,
       _ads = adController,
       _library = libraryController,
       _premium = premiumController,
       item = initialItem.obs;

  final WatchService _service;
  final CastService _cast;
  final AdController _ads;
  final LibraryController _library;
  final PremiumController _premium;

  /// Exposed to the player widget, which owns the playback engines itself.
  final PlaybackService playbackService;

  /// The stream being watched. Observable because retrying an errored stream
  /// swaps its status in place.
  final Rx<StreamItem> item;

  final Rx<WatchTab> tab = WatchTab.chat.obs;

  final RxList<ChatMessage> chat = <ChatMessage>[].obs;
  final RxList<CommentItem> comments = <CommentItem>[].obs;
  final RxList<StreamItem> upNext = <StreamItem>[].obs;

  final TextEditingController composer = TextEditingController();

  final RxBool isLoading = true.obs;

  /// Playback progress, 0–1. Live streams sit pinned at the live edge.
  final RxDouble progress = 0.0.obs;

  StreamItem get current => item.value;

  bool get supportsChat => _service.supportsChat(current);

  bool get needsDirectCastButton => _cast.needsDirectCastButton(current);

  String get relayCaption => _cast.relayCaption(current);

  /// How this stream reaches a receiver — drives the direct-cast caption.
  CastAvailability get castAvailability => _cast.availabilityFor(current);

  /// Playback has begun: start counting toward the next ad break.
  void onPlaybackStarted() => _ads.start();

  /// The engine couldn't load the source — show the error frame, and stop the
  /// ad clock so a viewer staring at a failure isn't also shown an ad.
  void onPlaybackFailed() {
    _ads.stop();
    item.value = current.copyWith(status: StreamStatus.error);
  }

  String get headerMeta => _service.headerMeta(current);

  /// Placeholder text for the composer, which serves both tabs.
  String get composerHint =>
      tab.value == WatchTab.chat ? 'Send a message...' : 'Add a comment...';

  bool get isSubscribed => _library.isSubscribed(current.channelName);

  @override
  void onInit() {
    super.onInit();

    // A recorded video has no chat, so open on the tab that has content.
    if (!supportsChat) tab.value = WatchTab.comments;

    progress.value = current.isLive ? 1.0 : 0.34;
    load();
    _library.recordWatch(current.id);
  }

  Future<void> load() async {
    isLoading.value = true;
    final results = await Future.wait([
      _service.loadChat(current.id),
      _service.loadComments(current.id),
      _service.loadUpNext(current.id, isPremium: _premium.isPremium.value),
    ]);
    chat.assignAll(results[0] as List<ChatMessage>);
    comments.assignAll(results[1] as List<CommentItem>);
    upNext.assignAll(results[2] as List<StreamItem>);
    isLoading.value = false;
  }

  void selectTab(WatchTab next) {
    if (next == WatchTab.chat && !supportsChat) return;
    tab.value = next;
  }

  Future<void> toggleSubscribe() =>
      _library.toggleSubscribed(current.channelName);

  /// Retries an errored stream.
  ///
  /// Phase 1 has no real player, so this restores the stream to its catalogue
  /// status — which is what a successful reload would do.
  void retry() {
    item.value = current.copyWith(
      status: current.viewersLive != null
          ? StreamStatus.live
          : StreamStatus.vod,
    );
  }

  /// Posts the composer's contents into whichever tab is showing.
  void send() {
    final text = composer.text.trim();
    if (text.isEmpty) return;

    if (tab.value == WatchTab.chat) {
      final now = DateTime.now();
      final stamp =
          '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}';
      chat.add(ChatMessage(user: 'you', text: text, time: stamp, isMine: true));
    } else {
      comments.insert(
        0,
        CommentItem(
          user: 'you',
          text: text,
          time: 'now',
          likes: 0,
          isMine: true,
        ),
      );
    }
    composer.clear();
  }

  void openStream(StreamItem next) =>
      Get.offAndToNamed(AppRoutes.watch, arguments: next);

  /// Premium lives in the shell below this page, so unwind to it rather
  /// than stacking a second copy on top of the player.
  void openPremium() =>
      Get.find<MainShellController>().goToFromStack(ShellTab.premium);

  @override
  void onClose() {
    // The clock only runs while something is playing on this page.
    _ads.stop();
    composer.dispose();
    super.onClose();
  }
}
