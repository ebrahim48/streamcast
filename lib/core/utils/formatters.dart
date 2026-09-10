/// Display formatting shared by every card and header.
class Formatters {
  Formatters._();

  /// Compacts a count the way the design shows it: `184K`, `2.1M`, `12.4K`.
  ///
  /// A trailing `.0` is dropped, so 184,000 reads "184K" rather than "184.0K".
  static String compactCount(int value) {
    if (value >= 1000000) return '${_trim(value / 1000000)}M';
    if (value >= 1000) return '${_trim(value / 1000)}K';
    return '$value';
  }

  static String _trim(double v) {
    final s = v.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  /// "2 days ago", "1 week ago", "1 month ago".
  static String timeAgo(DateTime when, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(when);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return _plural(diff.inMinutes, 'minute');
    if (diff.inDays < 1) return _plural(diff.inHours, 'hour');
    if (diff.inDays < 7) return _plural(diff.inDays, 'day');
    if (diff.inDays < 30) return _plural(diff.inDays ~/ 7, 'week');
    if (diff.inDays < 365) return _plural(diff.inDays ~/ 30, 'month');
    return _plural(diff.inDays ~/ 365, 'year');
  }

  static String _plural(int n, String unit) =>
      '$n $unit${n == 1 ? '' : 's'} ago';

  /// The metadata line under a card: watcher count while live, otherwise
  /// views plus age. Returns an empty string when there is nothing to say.
  static String metaLine({
    required bool isLive,
    int? viewersLive,
    int? views,
    DateTime? publishedAt,
  }) {
    if (isLive) {
      if (viewersLive == null) return '';
      return '${compactCount(viewersLive)} watching';
    }
    final parts = <String>[
      if (views != null) '${compactCount(views)} views',
      if (publishedAt != null) timeAgo(publishedAt),
    ];
    return parts.join(' · ');
  }
}
