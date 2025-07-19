import 'package:bootcamp175/production/domain/entities/user_entity.dart';

// ignore: must_be_immutable
class UserPublicProfileModel extends UserEntity {
  const UserPublicProfileModel({super.username, super.hasProfilePhoto});

  factory UserPublicProfileModel.fromJson(Map<String, dynamic> json) =>
      UserPublicProfileModel(
        username: json["username"],
        hasProfilePhoto: json["hasProfilePhoto"],
      );

  Map<String, dynamic> toJson() => {
    'username': username,
    'hasProfilePhoto': hasProfilePhoto,
  };
}
