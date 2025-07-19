import 'package:bootcamp175/production/domain/entities/user_entity.dart';

class RoomEntity<T extends UserEntity, T2 extends UserEntity> {
  final String roomName;
  final List<T> currentUsers;
  final List<T2> pendingUsers;

  RoomEntity({
    this.roomName = "",
    this.currentUsers = const [],
    this.pendingUsers = const [],
  });
}
