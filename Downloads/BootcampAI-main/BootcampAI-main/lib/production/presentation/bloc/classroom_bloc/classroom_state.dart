part of 'classroom_bloc.dart';

abstract class ClassroomState {
  final dynamic data;
  final String? error;
  const ClassroomState({this.data, this.error});
}

final class ClassroomInitial extends ClassroomState {}

//For Creating Room
class CreateClassroomLoading extends ClassroomState {
  const CreateClassroomLoading();
}

class CreateClassroomDone extends ClassroomState {
  const CreateClassroomDone({required super.data});
}

class CreateClassroomError extends ClassroomState {
  const CreateClassroomError({required super.error});
}
