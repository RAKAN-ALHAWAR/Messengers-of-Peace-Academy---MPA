part of '../../data.dart';

class ScrollRefreshLoadMoreParametersX {
  late int page;
  late int perPage;
  String? searchQuery;
  Map<String, dynamic>? filters;
  String? orderBy;

  ScrollRefreshLoadMoreParametersX({
    required this.page,
    required this.perPage,
    this.searchQuery,
    this.filters,
    this.orderBy,
  });
}
