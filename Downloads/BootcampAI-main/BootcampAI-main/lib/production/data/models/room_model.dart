import 'package:bootcamp175/production/data/models/user_public_profile_model.dart';
import 'package:bootcamp175/production/data/models/user_public_with_role.dart';
import 'package:bootcamp175/production/domain/entities/room_entity.dart';

class RoomModel
    extends RoomEntity<UserPublicWithRoleModel, UserPublicProfileModel> {
  RoomModel({
    required super.roomName,
    required super.currentUsers,
    required super.pendingUsers,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> userJsonList = json["currentUsers"];
    List<dynamic> pendingUserJsonList = json["pendingUsers"];
    List<UserPublicWithRoleModel> userModelList = [];
    List<UserPublicProfileModel> pendingUserList = [];

    for (var userJson in userJsonList) {
      userModelList.add(UserPublicWithRoleModel.fromJson(userJson));
    }
    for (var userJson in pendingUserJsonList) {
      pendingUserList.add(UserPublicProfileModel.fromJson(userJson));
    }
    return RoomModel(
      roomName: json["roomName"],
      currentUsers: userModelList,
      pendingUsers: pendingUserList,
    );
  }
  Map<String, dynamic> toJson() => {
    'roomName': roomName,
    'currentUsers': currentUsers.map((user) => user.toJson()).toList(),
    'pendingUsers': pendingUsers.map((user) => user.toJson()).toList(),
  };
}
