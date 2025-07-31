part of 'classroom_bloc.dart';

abstract class ClassroomState {
  final dynamic data;
  final String? error;
  const ClassroomState({this.data, this.error});
}

final class ClassroomInitial extends ClassroomState {}

//For Getting Joined Classrooms
class GetAllJoinedClassroomLoading extends ClassroomState {
  const GetAllJoinedClassroomLoading();
}

class GetAllJoinedClassroomDone extends ClassroomState {
  const GetAllJoinedClassroomDone({required super.data});
}

class GetAllJoinedClassroomError extends ClassroomState {
  const GetAllJoinedClassroomError({required super.error});
}

//For Creating Classroom
class CreateClassroomLoading extends ClassroomState {
  const CreateClassroomLoading();
}

class CreateClassroomDone extends ClassroomState {
  const CreateClassroomDone({required super.data});
}

class CreateClassroomError extends ClassroomState {
  const CreateClassroomError({required super.error});
}

//For Getting Classroom Data Of Specific User
class GetClassroomDataOfUserLoading extends ClassroomState {
  const GetClassroomDataOfUserLoading();
}

class GetClassroomDataOfUserDone extends ClassroomState {
  const GetClassroomDataOfUserDone({required super.data});
}

class GetClassroomDataOfUserError extends ClassroomState {
  const GetClassroomDataOfUserError({required super.error});
}

//For Searching Users
class SearchUsersLoading extends ClassroomState {
  const SearchUsersLoading({required super.data});
}

class SearchUsersDone extends ClassroomState {
  const SearchUsersDone({required super.data});
}

class SearchUsersError extends ClassroomState {
  const SearchUsersError({required super.data, required super.error});
}

//For Sending Classroom Invitation
class SendInvitationLoading extends ClassroomState {
  const SendInvitationLoading({required super.data});
}

class SendInvitationDone extends ClassroomState {
  const SendInvitationDone({required super.data});
}

class SendInvitationError extends ClassroomState {
  const SendInvitationError({required super.data, required super.error});
}

//Acceptin User Invitation
class UserActionClassroomInviteLoading extends ClassroomState {
  const UserActionClassroomInviteLoading({required super.data});
}

class UserActionClassroomInviteDone extends ClassroomState {
  const UserActionClassroomInviteDone({required super.data});
}

class UserActionClassroomInviteError extends ClassroomState {
  const UserActionClassroomInviteError({
    required super.data,
    required super.error,
  });
}

class UploadPDFLoading extends ClassroomState {
  const UploadPDFLoading({required super.data});
}

class UploadPDFDone extends ClassroomState {
  const UploadPDFDone({required super.data});
}

class UploadPDFError extends ClassroomState {
  const UploadPDFError({required super.data, required super.error});
}
