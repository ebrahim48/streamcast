import 'dart:convert';

import '../../../../core/models/stream_item.dart';
import '../../../../core/services/storage_service.dart';

/// Stores links posted from the Add-to-Feed sheet.
///
/// **Phase 1:** links persist on the device rather than reaching a dashboard,
/// so the flow is exercisable end to end. Posting to the admin backend replaces
/// [save] alone.
class AddLinkRepository {
  AddLinkRepository({required StorageService storageService})
    : _storage = storageService;

  final StorageService _storage;

  List<StreamItem> getAll() {
    final raw = _storage.getString(StorageKeys.feedLinks);
    if (raw == null || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .cast<Map<String, dynamic>>()
          .map(StreamItem.fromJson)
          .toList(growable: false);
    } catch (_) {
      // A corrupt payload shouldn't take the feed down with it.
      return const [];
    }
  }

  Future<void> save(StreamItem item) async {
    final items = [item, ...getAll()];
    await _storage.setString(
      StorageKeys.feedLinks,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }
}
