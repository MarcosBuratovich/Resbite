import 'package:meta/meta.dart';

/// A small value-object used as the key for [resbitesProvider].
///
/// Equality and hashCode are overridden so that two instances with identical
/// field values are considered the same key.  This prevents Riverpod from
/// recreating the provider (and thus re-fetching data) on every rebuild of
/// a widget where a new `ResbiteFilter()` is constructed.
@immutable
class ResbiteFilter {
  final bool upcoming;
  final String? userId;
  // Optional pagination parameters
  final int limit;
  final int offset;

  const ResbiteFilter({
    required this.upcoming,
    this.userId,
    this.limit = 20,
    this.offset = 0,
  });

  ResbiteFilter copyWith({
    bool? upcoming,
    String? userId,
    int? limit,
    int? offset,
  }) => ResbiteFilter(
        upcoming: upcoming ?? this.upcoming,
        userId: userId ?? this.userId,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResbiteFilter &&
          runtimeType == other.runtimeType &&
          upcoming == other.upcoming &&
          userId == other.userId &&
          limit == other.limit &&
          offset == other.offset;

  @override
  int get hashCode => Object.hash(upcoming, userId, limit, offset);
}
