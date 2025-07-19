import 'package:bloc/bloc.dart';
import 'package:bootcamp175/core/network/data_state.dart';
import 'package:bootcamp175/production/data/models/user_public_profile_model.dart';
import 'package:bootcamp175/production/data/repositories/room_repository.dart';
import 'package:bootcamp175/production/domain/usecases/room_usecases/create_classroom.dart';

part 'classroom_event.dart';
part 'classroom_state.dart';

class ClassroomBloc extends Bloc<ClassroomEvent, ClassroomState> {
  final RoomReposityory _roomReposityory = RoomReposityory();
  late CreteClassroomUseCase _createClassroomUseCase;

  ClassroomBloc() : super(ClassroomInitial()) {
    _createClassroomUseCase = CreteClassroomUseCase(_roomReposityory);

    on<CreateClassroom>(onCreateClassroom);
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
}
