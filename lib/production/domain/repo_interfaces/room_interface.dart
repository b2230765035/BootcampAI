import 'package:bootcamp175/core/network/data_state.dart';
import 'package:bootcamp175/production/domain/entities/message_entity.dart';
import 'package:bootcamp175/production/domain/entities/room_entity.dart';
import 'package:bootcamp175/production/domain/entities/user_entity.dart';

abstract class RoomInterface<
  T extends RoomEntity,
  T2 extends UserEntity,
  T3 extends MessageEntity,
  T4 extends UserEntity
> {
  Future<DataState> createClassroom({
    required String roomName,
    required T4 owner,
  });
  Future<DataState> getAllClasses();
  Future<DataState> getClass({required int roomId});
  Future<DataState> userJoinClassroomRequest({
    required int roomId,
    required T2 user,
  });
  Future<DataState> userLeaveClassroomRequest({
    required int roomId,
    required T2 user,
  });
  Future<DataState> userSendMessageClassroomRequest({required T3 message});
  Future<DataState> getClassroomMessageStream({required int roomId});
  Future<DataState> getAllJoinedClassroom();
  Future<DataState> sendUserJoinRequestToClassroom({
    required String roomName,
    required T4 requestOwner,
    required T4 requestUser,
  });
  Future<DataState> getClassroomDataOfUser({
    required String roomName,
    required T4 user,
  });
  Future<DataState> searchUsers({required String username});
}
