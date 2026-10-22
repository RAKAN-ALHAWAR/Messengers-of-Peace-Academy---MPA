import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:messengersofpeace/Config/config.dart';

import '../../../../../Config/Translation/translation.dart';
import '../../../../../Core/Error/error.dart';
import '../../../../../Core/Service/session_lease.dart';
import '../../../../../Data/Model/blog.dart';
import '../../../../../Data/Model/blog_page.dart';
import '../../../../../Data/data.dart';

class BlogController extends GetxController {
  final blogs = <BlogX>[].obs;
  final isLoadingMore = false.obs;
  final hasMore = false.obs;
  final loadMoreError = Rxn<ErrorX>();
  int _generation = 0;
  int _nextPage = 0;
  int _rawCount = 0;
  int? _totalEntries;
  String? _locale;
  SessionLeaseX? _lease;

  bool _current(SessionLeaseX lease, String locale) =>
      lease.isCurrent && TranslationX.getLanguageCode == locale;

  Future<List<BlogX>> getData() async {
    final generation = ++_generation;
    final locale = TranslationX.getLanguageCode;
    final lease = SessionLeaseX.capture(
      isActive: () => !isClosed && generation == _generation,
    );
    _lease = lease;
    _locale = locale;
    blogs.clear();
    _nextPage = 0;
    _rawCount = 0;
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

  void _accept(BlogPageX page) {
    final seen = blogs.map((entry) => entry.id).toSet();
    final additions =
        page.entries.where((entry) => seen.add(entry.id)).toList();
    if (_nextPage > 0 && page.rawCount > 0 && additions.isEmpty) {
      // A repeated/non-progressing page is recoverable by explicit retry. It
      // must not silently end the archive or trigger an automatic request loop.
      throw ErrorX(message: 'Unable to load more articles. Please try again.');
    }
    blogs.addAll(additions);
    _rawCount += page.rawCount;
    _totalEntries = page.totalEntries ?? _totalEntries;
    _nextPage++;
    hasMore.value =
        page.rawCount > 0 &&
        (_totalEntries == null || _rawCount < _totalEntries!);
  }

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

  void onArticleDetails(BlogX blog) =>
      Get.toNamed(RouteNameX.articleDetails, arguments: blog);

  @override
  void onInit() {
    super.onInit();
    initializeDateFormatting(TranslationX.getLanguageCode, null);
  }

  @override
  void onClose() {
    _generation++;
    super.onClose();
  }
}
