import '../../core/utils/json_reader.dart';

/// One page of a paginated collection.
class PaginatedList<T> {
  const PaginatedList({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.hasMore,
    this.totalCount,
  });

  const PaginatedList.empty({this.pageSize = 20})
    : items = const [],
      page = 1,
      hasMore = false,
      totalCount = 0;

  /// Backend shape (see `docs/API_SPEC.md`, section 1.5):
  /// ```json
  /// { "items": [...], "currentPage": 1, "limit": 20, "totalItems": 57,
  ///   "totalPages": 3, "isLast": false, "hasNext": true }
  /// ```
  factory PaginatedList.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) itemFromJson,
  ) {
    final items = json.readList('items', itemFromJson);
    final page = json.readInt('currentPage', fallback: 1);
    final limit = json.readInt('limit', fallback: items.length);
    final totalItems = json.readIntOrNull('totalItems');
    final totalPages = json.readIntOrNull('totalPages');

    // Prefer the explicit flags; derive from totals only if both are absent.
    final bool hasMore;
    if (json['hasNext'] != null) {
      hasMore = json.readBool('hasNext');
    } else if (json['isLast'] != null) {
      hasMore = !json.readBool('isLast');
    } else if (totalPages != null) {
      hasMore = page < totalPages;
    } else {
      hasMore = totalItems != null && page * limit < totalItems;
    }

    return PaginatedList(
      items: items,
      page: page,
      pageSize: limit,
      totalCount: totalItems,
      hasMore: hasMore,
    );
  }

  final List<T> items;
  final int page;
  final int pageSize;
  final bool hasMore;
  final int? totalCount;

  bool get isEmpty => items.isEmpty;
}
