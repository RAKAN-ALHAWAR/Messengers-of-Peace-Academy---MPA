import 'package:messengersofpeace/Core/Extension/convert/convert.dart';
import 'package:messengersofpeace/Core/Helper/model/model.dart';
import 'package:messengersofpeace/Data/data.dart';

class MyCertificate {
  final String name;
  final String courseName;
  final String shareUrl;
  final String downloadUrl;
  final String issuedDate;

  // "certificate_name": "Certificate",
  // "coursename": "Da'wah Essentials",
  // "share_url": "https://mopacademy.org/mod/customcert/view.php?id=359&downloadissue=18433",
  // "download_url": "https://mopacademy.org/mod/customcert/view.php?id=359&downloadissue=18433&download=1",
  // "issued_date": "2025-03-04"
  MyCertificate({
    required this.name,
    required this.courseName,
    required this.shareUrl,
    required this.downloadUrl,
    required this.issuedDate,
  });

  factory MyCertificate.fromJson(Map<String, dynamic> json) {
    return ModelUtilX.checkFromJson(
      json,
      (json) => MyCertificate(
        name: json[NameX.certificateName].toStrX,
        courseName: json[NameX.courseName].toStrX,
        shareUrl: json[NameX.shareUrl].toStrX,
        downloadUrl: json[NameX.downloadUrl].toStrX,
        issuedDate: json[NameX.issuedDate].toStrX,
      ),
      requiredDataKeys: [
        NameX.certificateName,
        NameX.courseName,
        NameX.shareUrl,
        NameX.downloadUrl,
        NameX.issuedDate,
      ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      NameX.certificateName: name,
      NameX.courseName: courseName,
      NameX.shareUrl: shareUrl,
      NameX.downloadUrl: downloadUrl,
      NameX.issuedDate: issuedDate,
    };
  }
}
