part of 'classroom_bloc.dart';

abstract class ClassroomEvent {
  const ClassroomEvent();
}

class CreateClassroom extends ClassroomEvent {
  final UserPublicProfileModel user;
  final String roomName;
  const CreateClassroom({required this.user, required this.roomName});
}
