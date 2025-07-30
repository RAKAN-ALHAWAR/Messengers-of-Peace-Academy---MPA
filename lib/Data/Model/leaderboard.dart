import 'package:messengersofpeace/Core/Extension/convert/convert.dart';
import 'package:messengersofpeace/Core/Helper/model/model.dart';
import 'package:messengersofpeace/Data/data.dart';

class LeaderboardX {
  final String id;
  final String userImage;
  final String username;
  final int points;
  final int rank;

  LeaderboardX({
    required this.id,
    required this.userImage,
    required this.username,
    required this.points,
    required this.rank,
  });

  factory LeaderboardX.fromJson(Map<String, dynamic> json) {
    return ModelUtilX.checkFromJson(
      json,
      (json) => LeaderboardX(
        id: json[NameX.id].toStrX,
        userImage: json[NameX.userImage].toStrX,
        username: json[NameX.username].toStrX,
        points: json[NameX.points].toIntX,
        rank: json[NameX.rank].toIntX,
      ),
      requiredDataKeys: [NameX.id],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      NameX.id: id,
      NameX.userImage: userImage,
      NameX.username: username,
      NameX.points: points,
      NameX.rank: rank,
    };
  }
}
