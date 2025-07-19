import 'package:bootcamp175/production/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    super.mail,
    super.username,
    super.hasProfilePhoto,
    super.joinedClassrooms,
    super.receivedClassroomRequests,
    super.friends,
    super.receivedFriendRequests,
    super.sentFriendRequests,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    mail: json["mail"],
    username: json["username"],
    hasProfilePhoto: json["hasProfilePhoto"],
    joinedClassrooms: json["joinedClassrooms"],
    receivedClassroomRequests: json["receivedClassroomRequests"],
    friends: List<int>.from(json["friends"]),
    receivedFriendRequests: List<int>.from(json["receivedFriendRequests"]),
    sentFriendRequests: List<int>.from(json["sentFriendRequests"]),
  );

  Map<String, dynamic> toJson() => {
    'mail': mail,
    'username': username,
    'hasProfilePhoto': hasProfilePhoto,
    'joinedClassrooms': joinedClassrooms,
    'receivedClassroomRequests': receivedClassroomRequests,
    'friends': friends,
    'receivedFriendRequests': receivedFriendRequests,
    'sentFriendRequests': sentFriendRequests,
  };
}
