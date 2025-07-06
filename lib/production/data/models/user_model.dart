import 'package:bootcamp175/production/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    super.mail,
    super.username,
    super.hasProfilePhoto,

    super.friends,
    super.receivedFriendRequests,
    super.sentFriendRequests,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    mail: json["mail"],
    username: json["username"],
    hasProfilePhoto: json["hasProfilePhoto"],
    friends: List<int>.from(json["friends"]),
    receivedFriendRequests: List<int>.from(json["receivedFriendRequests"]),
    sentFriendRequests: List<int>.from(json["sentFriendRequests"]),
  );

  Map<String, dynamic> toJson() => {
    'mail': mail,
    'username': username,
    'hasProfilePhoto': hasProfilePhoto,
    'friends': friends,
    'receivedFriendRequests': receivedFriendRequests,
    'sentFriendRequests': sentFriendRequests,
  };
}
