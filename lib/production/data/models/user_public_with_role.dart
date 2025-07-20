import 'package:bootcamp175/production/domain/entities/user_entity.dart';

// ignore: must_be_immutable
class UserPublicWithRoleModel extends UserEntity {
  String role = "";

  UserPublicWithRoleModel({
    required this.role,
    super.username,
    super.hasProfilePhoto,
    super.searchKeywords,
  });

  factory UserPublicWithRoleModel.fromJson(Map<String, dynamic> json) =>
      UserPublicWithRoleModel(
        username: json["username"],
        hasProfilePhoto: json["hasProfilePhoto"],
        role: json["role"],
        searchKeywords: List<String>.from(json["searchKeywords"] ?? []),
      );

  Map<String, dynamic> toJson() => {
    'username': username,
    'hasProfilePhoto': hasProfilePhoto,
    'role': role,
    "searchKeywords": searchKeywords,
  };
}
