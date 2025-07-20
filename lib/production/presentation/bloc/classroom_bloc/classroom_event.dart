part of 'classroom_bloc.dart';

abstract class ClassroomEvent {
  const ClassroomEvent();
}

class CreateClassroom extends ClassroomEvent {
  final UserPublicProfileModel user;
  final String roomName;
  const CreateClassroom({required this.user, required this.roomName});
}

class GetAllJoinedClassroom extends ClassroomEvent {
  const GetAllJoinedClassroom();
}

class GetClassroomDataOfUser extends ClassroomEvent {
  final String roomName;
  final UserPublicProfileModel user;
  const GetClassroomDataOfUser({required this.roomName, required this.user});
}

class SearchUsers extends ClassroomEvent {
  final String username;
  const SearchUsers({required this.username});
}

class SendInvitation extends ClassroomEvent {
  final String roomName;
  final UserPublicProfileModel requestOwner;
  final UserPublicProfileModel requestUser;
  const SendInvitation({
    required this.roomName,
    required this.requestOwner,
    required this.requestUser,
  });
}
