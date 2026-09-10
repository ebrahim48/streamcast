import 'package:get/get.dart';

import '../../../../core/models/stream_item.dart';
import '../../domain/services/library_service.dart';

/// Backs the My Library tab, and the like/subscribe actions on the watch page.
///
/// Registered permanently so a watch recorded on the player is already in the
/// rail by the time the user switches tabs.
class LibraryController extends GetxController {
  LibraryController({required LibraryService libraryService})
    : _service = libraryService;

  final LibraryService _service;

  final RxList<StreamItem> history = <StreamItem>[].obs;
  final RxList<StreamItem> liked = <StreamItem>[].obs;
  final RxList<StreamItem> watchLater = <StreamItem>[].obs;
  final RxList<String> subscribed = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _service.seedIfEmpty().then((_) => refreshAll());
  }

  void refreshAll() {
    history.assignAll(_service.history);
    liked.assignAll(_service.liked);
    watchLater.assignAll(_service.watchLater);
    subscribed.assignAll(_service.subscribedChannels);
  }

  bool isSubscribed(String channel) => subscribed.contains(channel);

  bool isLiked(String id) => liked.any((s) => s.id == id);

  bool isSaved(String id) => watchLater.any((s) => s.id == id);

  Future<void> recordWatch(String id) async {
    await _service.recordWatch(id);
    history.assignAll(_service.history);
  }

  Future<void> toggleLiked(String id) async {
    await _service.toggleLiked(id);
    liked.assignAll(_service.liked);
  }

  Future<void> toggleWatchLater(String id) async {
    await _service.toggleWatchLater(id);
    watchLater.assignAll(_service.watchLater);
  }

  Future<void> toggleSubscribed(String channel) async {
    await _service.toggleSubscribed(channel);
    subscribed.assignAll(_service.subscribedChannels);
  }
}
