import 'package:bootcamp175/core/network/custom_response.dart';
import 'package:bootcamp175/core/network/data_state.dart';
import 'package:bootcamp175/production/data/data_sources/remote/firestore_chat_api.dart';
import 'package:bootcamp175/production/data/models/message_model.dart';
import 'package:bootcamp175/production/data/models/room_model.dart';
import 'package:bootcamp175/production/data/models/user_public_profile_model.dart';
import 'package:bootcamp175/production/data/models/user_public_with_role.dart';
import 'package:bootcamp175/production/domain/repo_interfaces/room_interface.dart';

class RoomReposityory
    extends
        RoomInterface<
          RoomModel,
          UserPublicWithRoleModel,
          MessageModel,
          UserPublicProfileModel
        > {
  FirestoreChatApi chatApi = FirestoreChatApi();
  @override
  Future<DataState> getAllClasses() {
    // TODO: implement getAllClasses
    throw UnimplementedError();
  }

  @override
  Future<DataState> getClass({required int roomId}) {
    // TODO: implement getClass
    throw UnimplementedError();
  }

  @override
  Future<DataState> getClassroomMessageStream({required int roomId}) {
    // TODO: implement getClassroomMessageStream
    throw UnimplementedError();
  }

  @override
  Future<DataState> userJoinClassroomRequest({
    required int roomId,
    required UserPublicWithRoleModel user,
  }) {
    // TODO: implement userJoinClassroomRequest
    throw UnimplementedError();
  }

  @override
  Future<DataState> userLeaveClassroomRequest({
    required int roomId,
    required UserPublicWithRoleModel user,
  }) {
    // TODO: implement userLeaveClassroomRequest
    throw UnimplementedError();
  }

  @override
  Future<DataState> userSendMessageClassroomRequest({
    required MessageModel message,
  }) {
    // TODO: implement userSendMessageClassroomRequest
    throw UnimplementedError();
  }

  @override
  Future<DataState> createClassroom({
    required String roomName,
    required UserPublicProfileModel owner,
  }) async {
    CustomResponse response = await chatApi.createClassroom(
      roomName: roomName,
      owner: owner,
    );
    if (response.status == true) {
      return DataSuccess(response.data);
    } else {
      return DataFailed(response.error!);
    }
  }

  @override
  Future<DataState> getAllJoinedClassroom() async {
    CustomResponse response = await chatApi.getAllJoinedClassroom();
    if (response.status == true) {
      return DataSuccess(response.data);
    } else {
      return DataFailed(response.error!);
    }
  }

  @override
  Future<DataState> sendUserJoinRequestToClassroom({
    required String roomName,
    required UserPublicProfileModel requestOwner,
    required UserPublicProfileModel requestUser,
  }) async {
    CustomResponse response = await chatApi.sendUserJoinRequestToClassroom(
      roomName: roomName,
      requestOwner: requestOwner,
      requestUser: requestUser,
    );
    if (response.status == true) {
      return DataSuccess(response.data);
    } else {
      return DataFailed(response.error!);
    }
  }

  @override
  Future<DataState> getClassroomDataOfUser({
    required String roomName,
    required UserPublicProfileModel user,
  }) async {
    CustomResponse response = await chatApi.getClassroomDataOfUser(
      roomName: roomName,
      user: user,
    );
    if (response.status == true) {
      return DataSuccess(response.data);
    } else {
      return DataFailed(response.error!);
    }
  }

  @override
  Future<DataState> searchUsers({required String username}) async {
    CustomResponse response = await chatApi.searchUsers(username: username);
    if (response.status == true) {
      return DataSuccess(response.data);
    } else {
      return DataFailed(response.error!);
    }
  }
}
