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

    final tags = List<Map<String, dynamic>>.from(json[NameX.tags] ?? []);
    final lang =
        tags.isNotEmpty
            ? tags.first[NameX.name]
                    ?.toString()
                    .substring(0, 2)
                    .toLowerCase() ??
                'en'
            : null;

    return ModelUtilX.checkFromJson(json, (json) {
      return BlogX(
        id: json[NameX.id].toStrX,
        userId: json[NameX.userId].toStrNullableX,
        subject: json[NameX.subject].toStrX,
        summary: json[NameX.summary].toStrX,
        imageUrl: fileUrl ?? '',
        imageUrlWithoutWebservice: fileUrl?.replaceFirst('webservice/', ''),
        lang: lang ?? 'en',
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
