import 'package:bootcamp175/production/domain/entities/user_entity.dart';

class RoomEntity<T extends UserEntity> {
  final String roomName;
  final List<T> currentUsers;
  final List<Map<String, String>> pendingUsers;
  final List<Map<String, dynamic>> rejectedUsers;
  final List<Map<String, dynamic>> homeworks;
  final List<Map<String, dynamic>> notes;

  RoomEntity({
    this.roomName = "",
    this.currentUsers = const [],
    this.pendingUsers = const [],
    this.rejectedUsers = const [],
    this.homeworks = const [],
    this.notes = const [],
  });
}
