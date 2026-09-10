import '../../../../core/models/stream_item.dart';
import '../../data/repositories/library_repository.dart';

/// Business logic for the user's saved content.
class LibraryService {
  LibraryService({required LibraryRepository libraryRepository})
    : _repository = libraryRepository;

  final LibraryRepository _repository;

  Future<void> seedIfEmpty() => _repository.seedIfEmpty();

  List<StreamItem> get history => _repository.getHistory();

  List<StreamItem> get liked => _repository.getLiked();

  List<StreamItem> get watchLater => _repository.getWatchLater();

  List<String> get subscribedChannels => _repository.getSubscribedChannels();

  bool isSubscribed(String channel) =>
      _repository.getSubscribedChannels().contains(channel);

  bool isLiked(String id) => _repository.getLiked().any((s) => s.id == id);

  Future<void> recordWatch(String id) => _repository.addToHistory(id);

  Future<bool> toggleLiked(String id) => _repository.toggleLiked(id);

  Future<bool> toggleWatchLater(String id) => _repository.toggleWatchLater(id);

  Future<bool> toggleSubscribed(String channel) =>
      _repository.toggleSubscribed(channel);
}
