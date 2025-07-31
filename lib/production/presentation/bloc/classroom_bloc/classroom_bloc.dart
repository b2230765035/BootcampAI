import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:bootcamp175/core/network/data_state.dart';
import 'package:bootcamp175/production/data/models/user_public_profile_model.dart';
import 'package:bootcamp175/production/data/repositories/room_repository.dart';
import 'package:bootcamp175/production/domain/usecases/room_usecases/create_classroom.dart';
import 'package:bootcamp175/production/domain/usecases/room_usecases/get_all_joined_classroom.dart';
import 'package:bootcamp175/production/domain/usecases/room_usecases/get_classroom_data_of_user.dart';
import 'package:bootcamp175/production/domain/usecases/room_usecases/search_users.dart';
import 'package:bootcamp175/production/domain/usecases/room_usecases/send_user_join_request_to_classroom.dart';
import 'package:bootcamp175/production/domain/usecases/room_usecases/upload_pdf.dart';
import 'package:bootcamp175/production/domain/usecases/room_usecases/user_accept_classroom_invite.dart';
import 'package:bootcamp175/production/domain/usecases/room_usecases/user_reject_classroom_invite.dart';

part 'classroom_event.dart';
part 'classroom_state.dart';

class ClassroomBloc extends Bloc<ClassroomEvent, ClassroomState> {
  final RoomReposityory _roomReposityory = RoomReposityory();
  late CreteClassroomUseCase _createClassroomUseCase;
  late GetAllJoinedClassroomUseCase _getAllJoinedClassroomUseCase;
  late GetClassroomDataOfUserUseCase _getClassroomDataOfUserUseCase;
  late SearchUsersUseCase _searchUsersUseCase;
  late SendUserJoinRequestToClassroomUseCase
  _sendUserJoinRequestToClassroomUseCase;
  late UserAcceptClassroomInviteUseCase _userAcceptClassroomInviteUseCase;
  late UserRejectClassroomInviteUseCase _userRejectClassroomInviteUseCase;
  late UploadPDFUseCase _uploadPDFUseCase;

  ClassroomBloc() : super(ClassroomInitial()) {
    _createClassroomUseCase = CreteClassroomUseCase(_roomReposityory);
    _getAllJoinedClassroomUseCase = GetAllJoinedClassroomUseCase(
      _roomReposityory,
    );
    _getClassroomDataOfUserUseCase = GetClassroomDataOfUserUseCase(
      _roomReposityory,
    );
    _searchUsersUseCase = SearchUsersUseCase(_roomReposityory);
    _sendUserJoinRequestToClassroomUseCase =
        SendUserJoinRequestToClassroomUseCase(_roomReposityory);
    _userAcceptClassroomInviteUseCase = UserAcceptClassroomInviteUseCase(
      _roomReposityory,
    );
    _userRejectClassroomInviteUseCase = UserRejectClassroomInviteUseCase(
      _roomReposityory,
    );
    _uploadPDFUseCase = UploadPDFUseCase(_roomReposityory);

    on<CreateClassroom>(onCreateClassroom);
    on<GetAllJoinedClassroom>(onGetAllJoinedClassroom);
    on<GetClassroomDataOfUser>(onGetClassroomDataOfUser);
    on<SearchUsers>(onSearchUsers);
    on<SendInvitation>(onSendInvitation);
    on<UserAcceptClassroomInvite>(onUserAcceptClassroomInvite);
    on<UserRejectClassroomInvite>(onUserRejectClassroomInvite);
    on<UploadPDF>(onUploadPDF);
  }
  void onCreateClassroom(
    CreateClassroom event,
    Emitter<ClassroomState> emit,
  ) async {
    emit(CreateClassroomLoading());
    final DataState dataState = await _createClassroomUseCase.call(
      param1: event.roomName,
      param2: event.user,
    );
    if (dataState is DataSuccess && dataState.data != null) {
      emit(CreateClassroomDone(data: dataState.data));
    } else {
      emit(CreateClassroomError(error: dataState.error));
    }
  }

  void onGetAllJoinedClassroom(
    GetAllJoinedClassroom event,
    Emitter<ClassroomState> emit,
  ) async {
    emit(GetAllJoinedClassroomLoading());
    final DataState dataState = await _getAllJoinedClassroomUseCase.call();
    if (dataState is DataSuccess && dataState.data != null) {
      emit(GetAllJoinedClassroomDone(data: dataState.data));
    } else {
      emit(GetAllJoinedClassroomError(error: dataState.error));
    }
  }

  void onGetClassroomDataOfUser(
    GetClassroomDataOfUser event,
    Emitter<ClassroomState> emit,
  ) async {
    emit(GetClassroomDataOfUserLoading());
    final DataState dataState = await _getClassroomDataOfUserUseCase.call(
      param1: event.roomName,
      param2: event.user,
    );
    if (dataState is DataSuccess && dataState.data != null) {
      emit(GetClassroomDataOfUserDone(data: dataState.data));
    } else {
      emit(GetClassroomDataOfUserError(error: dataState.error));
    }
  }

  void onSearchUsers(SearchUsers event, Emitter<ClassroomState> emit) async {
    emit(SearchUsersLoading(data: state.data));
    final DataState dataState = await _searchUsersUseCase.call(
      param: event.username,
    );
    if (dataState is DataSuccess && dataState.data != null) {
      final previousData = Map<String, dynamic>.from(state.data ?? {});
      previousData["searchUsers"] = dataState.data;

      emit(SearchUsersDone(data: previousData));
    } else {
      emit(SearchUsersError(data: state.data, error: dataState.error));
    }
  }

  void onSendInvitation(
    SendInvitation event,
    Emitter<ClassroomState> emit,
  ) async {
    emit(SendInvitationLoading(data: state.data));
    final DataState dataState = await _sendUserJoinRequestToClassroomUseCase
        .call(
          param1: event.roomName,
          param2: event.requestOwner,
          param3: event.requestUser,
        );

    if (dataState is DataSuccess && dataState.data != null) {
      emit(SendInvitationDone(data: state.data));
    } else {
      emit(SendInvitationError(data: state.data, error: dataState.error));
    }
  }

  void onUserAcceptClassroomInvite(
    UserAcceptClassroomInvite event,
    Emitter<ClassroomState> emit,
  ) async {
    emit(UserActionClassroomInviteLoading(data: state.data));
    final DataState dataState = await _userAcceptClassroomInviteUseCase.call(
      param1: event.roomName,
      param2: event.username,
      param3: event.requesOwnerUsername,
    );

    if (dataState is DataSuccess && dataState.data != null) {
      emit(UserActionClassroomInviteDone(data: state.data));
    } else {
      emit(
        UserActionClassroomInviteError(
          data: state.data,
          error: dataState.error,
        ),
      );
    }
  }

  void onUserRejectClassroomInvite(
    UserRejectClassroomInvite event,
    Emitter<ClassroomState> emit,
  ) async {
    emit(UserActionClassroomInviteLoading(data: state.data));
    final DataState dataState = await _userRejectClassroomInviteUseCase.call(
      param1: event.roomName,
      param2: event.username,
      param3: event.requesOwnerUsername,
    );

    if (dataState is DataSuccess && dataState.data != null) {
      emit(UserActionClassroomInviteDone(data: state.data));
    } else {
      emit(
        UserActionClassroomInviteError(
          data: state.data,
          error: dataState.error,
        ),
      );
    }
  }

  void onUploadPDF(UploadPDF event, Emitter<ClassroomState> emit) async {
    emit(UploadPDFLoading(data: state.data));
    final DataState dataState = await _uploadPDFUseCase.call(
      param1: event.fileName,
      param2: event.file,
      param3: event.objectiveName,
      param4: event.roomName,
      param5: event.pdfType,
      param6: event.uploadOwner,
    );

    if (dataState is DataSuccess && dataState.data != null) {
      emit(UploadPDFDone(data: dataState.data));
    } else {
      emit(UploadPDFError(data: state.data, error: dataState.error));
    }
  }
}
