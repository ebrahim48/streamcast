import '../../../../core/data/mock_data.dart';
import '../../../../core/models/stream_item.dart';
import '../../../../core/services/storage_service.dart';

/// Persists the user's own lists — history, likes, watch later, subscriptions.
///
/// Only stream ids are stored; the full items are resolved from the catalogue
/// on read. That keeps the stored payload tiny and means a title or thumbnail
/// correction reaches saved rows without a migration.
class LibraryRepository {
  LibraryRepository({required StorageService storageService})
    : _storage = storageService;

  final StorageService _storage;

  /// Most recent first, capped so the rail stays a rail.
  static const int historyLimit = 20;

  List<StreamItem> _resolve(String key) {
    final ids = _storage.getStringList(key) ?? const <String>[];
    return ids
        .map(MockData.byId)
        .whereType<StreamItem>()
        .toList(growable: false);
  }

  List<StreamItem> getHistory() => _resolve(StorageKeys.history);

  List<StreamItem> getLiked() => _resolve(StorageKeys.liked);

  List<StreamItem> getWatchLater() => _resolve(StorageKeys.watchLater);

  List<String> getSubscribedChannels() =>
      _storage.getStringList(StorageKeys.subscribed) ?? const <String>[];

  /// Records a watch, moving an existing entry back to the front.
  Future<void> addToHistory(String id) async {
    final ids = <String>[..._storage.getStringList(StorageKeys.history) ?? []]
      ..remove(id)
      ..insert(0, id);
    if (ids.length > historyLimit) ids.removeRange(historyLimit, ids.length);
    await _storage.setStringList(StorageKeys.history, ids);
  }

  /// Adds or removes [id] from the list at [key]. Returns the new membership.
  Future<bool> _toggle(String key, String id) async {
    final ids = <String>[..._storage.getStringList(key) ?? []];
    final nowMember = !ids.contains(id);
    nowMember ? ids.insert(0, id) : ids.remove(id);
    await _storage.setStringList(key, ids);
    return nowMember;
  }

  Future<bool> toggleLiked(String id) => _toggle(StorageKeys.liked, id);

  Future<bool> toggleWatchLater(String id) =>
      _toggle(StorageKeys.watchLater, id);

  Future<bool> toggleSubscribed(String channel) =>
      _toggle(StorageKeys.subscribed, channel);

  /// Seeds the lists shown in the design so a fresh install has something to
  /// show. Runs once — after that the lists are whatever the user made them.
  Future<void> seedIfEmpty() async {
    if (_storage.getStringList(StorageKeys.history) != null) return;

    await _storage.setStringList(StorageKeys.history, [
      'vod_clutch',
      'vod_warehouse41',
      'live_ranked',
    ]);
    await _storage.setStringList(StorageKeys.liked, [
      'vod_desk',
      'vod_casting',
    ]);
    await _storage.setStringList(StorageKeys.watchLater, []);
    await _storage.setStringList(StorageKeys.subscribed, ['Signal Desk']);
  }
}
