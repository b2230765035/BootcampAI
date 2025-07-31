import 'dart:io';

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
  Future<DataState> getClassroomMessageStream({required int roomId}) {
    // TODO: implement getClassroomMessageStream
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

  @override
  Future<DataState> userAcceptClassroomInvite({
    required String roomName,
    required String username,
    required String requestOwnerUsername,
  }) async {
    CustomResponse response = await chatApi.userAcceptClassroomInvite(
      roomName: roomName,
      username: username,
      requestOwnerUsername: requestOwnerUsername,
    );
    if (response.status == true) {
      return DataSuccess(response.data);
    } else {
      return DataFailed(response.error!);
    }
  }

  @override
  Future<DataState> userRejectClassroomInvite({
    required String roomName,
    required String username,
    required String requestOwnerUsername,
  }) async {
    CustomResponse response = await chatApi.userRejectClassroomInvite(
      roomName: roomName,
      username: username,
      requestOwnerUsername: requestOwnerUsername,
    );
    if (response.status == true) {
      return DataSuccess(response.data);
    } else {
      return DataFailed(response.error!);
    }
  }

  @override
  Future<DataState> uploadPDF({
    required String fileName,
    required File file,
    required String objectiveName,
    required String roomName,
    required String pdfType,
    required String uploadOwner,
  }) async {
    CustomResponse response = await chatApi.uploadPDF(
      fileName: fileName,
      file: file,
      objectiveName: objectiveName,
      roomName: roomName,
      pdfType: pdfType,
      uploadOwner: uploadOwner,
    );
    if (response.status == true) {
      return DataSuccess(response.data);
    } else {
      return DataFailed(response.error!);
    }
  }
}
