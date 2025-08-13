import 'history_item.dart';

class HistoryResponse {
  final int totalCount;
  final int limit;
  final int totalPages;
  final int currentPage;
  final String? next;
  final String? previous;
  final List<HistoryItem> results;

  HistoryResponse({
    required this.totalCount,
    required this.limit,
    required this.totalPages,
    required this.currentPage,
    this.next,
    this.previous,
    required this.results,
  });

  factory HistoryResponse.fromJson(Map<String, dynamic> json) {
    return HistoryResponse(
      totalCount: json['total_count'] ?? 0,
      limit: json['limit'] ?? 20,
      totalPages: json['total_pages'] ?? 0,
      currentPage: json['current_page'] ?? 1,
      next: json['next'],
      previous: json['previous'],
      results:
          (json['results'] as List<dynamic>?)
              ?.map((item) => HistoryItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_count': totalCount,
      'limit': limit,
      'total_pages': totalPages,
      'current_page': currentPage,
      'next': next,
      'previous': previous,
      'results': results.map((item) => item.toJson()).toList(),
    };
  }
}
