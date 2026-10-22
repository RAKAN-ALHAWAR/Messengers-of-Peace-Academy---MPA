import '../../Core/Error/error.dart';
import '../../Core/Helper/model/model.dart';
import '../data.dart';
import 'blog.dart';

/// One server page, with the raw count kept separately from valid parsed items.
class BlogPageX {
  BlogPageX({
    required List<BlogX> entries,
    required this.rawCount,
    this.totalEntries,
  }) : entries = List.unmodifiable(entries);

  final List<BlogX> entries;
  final int rawCount;
  final int? totalEntries;

  factory BlogPageX.fromJson(Map<String, dynamic> json) {
    final entries = json[NameX.entries];
    if (entries is! List) throw ErrorX(message: 'Unable to load articles.');
    final total = json[NameX.totalentries];
    final parsedTotal =
        total is int ? total : int.tryParse(total?.toString() ?? '');
    return BlogPageX(
      entries: ModelUtilX.generateItems(entries, BlogX.fromJson),
      rawCount: entries.length,
      totalEntries:
          parsedTotal != null && parsedTotal >= 0 ? parsedTotal : null,
    );
  }
}
