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
    super.searchKeywords,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      mail: json["mail"] ?? "",
      username: json["username"] ?? "",
      hasProfilePhoto: json["hasProfilePhoto"] ?? false,
      joinedClassrooms: List<int>.from(json["joinedClassrooms"] ?? []),
      receivedClassroomRequests: List<Map<String, String>>.from(
        (json["receivedClassroomRequests"] ?? []).map<Map<String, String>>(
          (e) => Map<String, String>.from(e),
        ),
      ),
      friends: List<int>.from(json["friends"] ?? []),
      receivedFriendRequests: List<int>.from(
        json["receivedFriendRequests"] ?? [],
      ),
      sentFriendRequests: List<int>.from(json["sentFriendRequests"] ?? []),
      searchKeywords: List<String>.from(json["searchKeywords"] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'mail': mail,
    'username': username,
    'hasProfilePhoto': hasProfilePhoto,
    'joinedClassrooms': joinedClassrooms,
    'receivedClassroomRequests': receivedClassroomRequests,
    'friends': friends,
    'receivedFriendRequests': receivedFriendRequests,
    'sentFriendRequests': sentFriendRequests,
    'searchKeywords': searchKeywords,
  };
}
