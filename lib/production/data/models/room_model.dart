import 'package:bootcamp175/production/data/models/user_public_profile_model.dart';
import 'package:bootcamp175/production/data/models/user_public_with_role.dart';
import 'package:bootcamp175/production/domain/entities/room_entity.dart';

import 'package:bootcamp175/production/domain/entities/user_entity.dart';
import 'package:bootcamp175/production/data/models/user_public_with_role.dart';

class RoomModel extends RoomEntity<UserPublicWithRoleModel> {
  RoomModel({
    required super.roomName,
    required super.currentUsers,
    required super.pendingUsers,
    required super.rejectedUsers,
    required super.homeworks,
    required super.notes,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> userJsonList = json["currentUsers"] ?? [];
    List<dynamic> pendingUserJsonList = json["pendingUsers"] ?? [];
    List<dynamic> rejectedUserJsonList = json["rejectedUsers"] ?? [];
    List<dynamic> homeworksJsonList = json["homeworks"] ?? [];
    List<dynamic> notesJsonList = json["notes"] ?? [];

    List<UserPublicWithRoleModel> userModelList = userJsonList
        .map((userJson) => UserPublicWithRoleModel.fromJson(userJson))
        .toList();

    List<Map<String, String>> pendingUserList = pendingUserJsonList
        .map((e) => Map<String, String>.from(e as Map))
        .toList();
    List<Map<String, dynamic>> rejectedUserList = rejectedUserJsonList
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    List<Map<String, dynamic>> homeworksList = homeworksJsonList
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    List<Map<String, dynamic>> notesList = notesJsonList
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    return RoomModel(
      roomName: json["roomName"] ?? "",
      currentUsers: userModelList,
      pendingUsers: pendingUserList,
      rejectedUsers: rejectedUserList,
      homeworks: homeworksList,
      notes: notesList,
    );
  }

  Map<String, dynamic> toJson() => {
    'roomName': roomName,
    'currentUsers': currentUsers.map((user) => user.toJson()).toList(),
    'pendingUsers': pendingUsers,
    'rejectedUsers': rejectedUsers,
    'homeworks': homeworks,
    'notes': notes,
  };
}
