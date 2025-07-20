import 'package:bootcamp175/production/domain/entities/user_entity.dart';

// ignore: must_be_immutable
class UserPublicProfileModel extends UserEntity {
  const UserPublicProfileModel({
    super.username,
    super.hasProfilePhoto,
    super.searchKeywords,
  });

  factory UserPublicProfileModel.fromJson(Map<String, dynamic> json) =>
      UserPublicProfileModel(
        username: json["username"],
        hasProfilePhoto: json["hasProfilePhoto"],
        searchKeywords: List<String>.from(json["searchKeywords"] ?? []),
      );

  Map<String, dynamic> toJson() => {
    'username': username,
    'hasProfilePhoto': hasProfilePhoto,
    'searchKeywords': searchKeywords,
  };
}
