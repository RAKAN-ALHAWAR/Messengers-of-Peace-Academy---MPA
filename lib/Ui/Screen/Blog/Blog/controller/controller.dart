import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:messengersofpeace/Config/config.dart';

import '../../../../../Config/Translation/translation.dart';
import '../../../../../Core/Error/error.dart';
import '../../../../../Core/Service/controller_lease.dart';
import '../../../../../Core/Service/session_lease.dart';
import '../../../../../Data/Model/blog.dart';
import '../../../../../Data/Model/blog_page.dart';
import '../../../../../Data/data.dart';

class BlogController extends GetxController {
  //============================================================================
  // Variables

  /// Loaded articles
  final blogs = <BlogX>[].obs;

  /// Is loading the next page
  final isLoadingMore = false.obs;

  /// Has more pages
  final hasMore = false.obs;

  /// Error of the last next-page load
  final loadMoreError = Rxn<ErrorX>();
  int _generation = 0;
  int _nextPage = 0;
  int? _totalEntries;
  String? _locale;
  SessionLeaseX? _lease;

  //============================================================================
  // Functions

  /// The lease is current and the language is the one it started in
  bool _current(SessionLeaseX lease, String locale) =>
      lease.isCurrent && TranslationX.getLanguageCode == locale;

  /// Get the first page from database
  Future<List<BlogX>> getData() async {
    final generation = ++_generation;
    final locale = TranslationX.getLanguageCode;
    final lease = ControllerLeaseX.capture(
      this,
      also: () => generation == _generation,
    );
    _lease = lease;
    _locale = locale;
    blogs.clear();
    _nextPage = 0;
    _totalEntries = null;
    hasMore.value = false;
    isLoadingMore.value = false;
    loadMoreError.value = null;
    final page = await DatabaseX.getBlogsPage(
      lang: TranslationX.backendLanguageCode,
    );
    if (!_current(lease, locale)) return const [];
    _accept(page);
    return List.unmodifiable(blogs);
  }

  /// Add a page; a repeated page is an explicit retry, never a silent end
  void _accept(BlogPageX page) {
    final seen = blogs.map((entry) => entry.id).toSet();
    final additions =
        page.entries.where((entry) => seen.add(entry.id)).toList();
    if (_nextPage > 0 && page.rawCount > 0 && additions.isEmpty) {
      throw ErrorX(message: 'Unable to load more articles. Please try again.');
    }
    blogs.addAll(additions);
    _totalEntries = page.totalEntries ?? _totalEntries;
    _nextPage++;
    hasMore.value =
        page.rawCount > 0 &&
        (_totalEntries == null || blogs.length < _totalEntries!);
  }

  /// Load the next page
  Future<void> loadMore() async {
    final lease = _lease;
    final locale = _locale;
    if (lease == null ||
        locale == null ||
        !_current(lease, locale) ||
        isLoadingMore.value ||
        !hasMore.value) {
      return;
    }
    isLoadingMore.value = true;
    loadMoreError.value = null;
    try {
      final page = await DatabaseX.getBlogsPage(
        lang: TranslationX.backendLanguageCode,
        page: _nextPage,
      );
      if (!_current(lease, locale)) return;
      _accept(page);
    } catch (error) {
      if (!_current(lease, locale)) return;
      loadMoreError.value = ErrorX.fromException(error);
    } finally {
      if (_current(lease, locale)) isLoadingMore.value = false;
    }
  }

  /// Navigate to article details
  void onArticleDetails(BlogX blog) =>
      Get.toNamed(RouteNameX.articleDetails, arguments: blog);

  //============================================================================
  // Lifecycle

  @override
  void onInit() {
    super.onInit();

    /// Initialize date format
    initializeDateFormatting(TranslationX.getLanguageCode, null);
  }

  /// A closed controller retires every load in flight
  @override
  void onClose() {
    _generation++;
    super.onClose();
  }
}
