import 'package:messengersofpeace/Core/Extension/convert/convert.dart';
import 'package:messengersofpeace/Core/Helper/model/model.dart';
import 'package:messengersofpeace/Data/data.dart';

class BlogX {
  final String id;
  final String? userId;
  final String subject;
  final String summary;
  final String imageUrl;
  final String? imageUrlWithoutWebservice;
  final String lang;
  final DateTime? createdAt;

  BlogX({
    required this.id,
    this.userId,
    required this.subject,
    required this.summary,
    required this.imageUrl,
    this.imageUrlWithoutWebservice,
    required this.lang,
    this.createdAt,
  });

  factory BlogX.fromJson(Map<String, dynamic> json) {
    final attachments = List<Map<String, dynamic>>.from(
      json[NameX.attachmentfiles] ?? [],
    );
    final fileUrl =
        attachments.isNotEmpty
            ? attachments.first[NameX.fileurl]?.toString() ?? ''
            : null;

    // Tags are optional metadata. A short or malformed tag must not discard
    // an otherwise valid article, and Unicode prefixes must not split a rune.
    final tags = json[NameX.tags];
    final firstTag = tags is List && tags.isNotEmpty ? tags.first : null;
    final tagName = firstTag is Map ? firstTag[NameX.name]?.toString() : null;
    final prefix = (tagName ?? '').runes.take(2).toList();
    final lang =
        prefix.length == 2 ? String.fromCharCodes(prefix).toLowerCase() : 'en';

    return ModelUtilX.checkFromJson(json, (json) {
      return BlogX(
        id: json[NameX.id].toStrX,
        userId: json[NameX.userId].toStrNullableX,
        subject: json[NameX.subject].toStrX,
        summary: json[NameX.summary].toStrX,
        imageUrl: fileUrl ?? '',
        imageUrlWithoutWebservice: fileUrl?.replaceFirst('webservice/', ''),
        lang: lang,
        createdAt:
            json[NameX.created] != null
                ? DateTime.fromMillisecondsSinceEpoch(
                  json[NameX.created].toIntX * 1000,
                )
                : null,
      );
    }, requiredDataKeys: [NameX.id, NameX.subject, NameX.summary]);
  }

  Map<String, dynamic> toJson() {
    return {
      NameX.id: id,
      NameX.userId: userId,
      NameX.subject: subject,
      NameX.summary: summary,
      NameX.imageUrl: imageUrl,
      NameX.imageUrlWithoutWebservice: imageUrlWithoutWebservice,
      NameX.lang: lang,
    };
  }
}
