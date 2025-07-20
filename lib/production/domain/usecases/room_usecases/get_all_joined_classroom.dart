import 'package:bootcamp175/core/network/data_state.dart';
import 'package:bootcamp175/core/usecase/usecase.dart';
import 'package:bootcamp175/production/data/repositories/room_repository.dart';

class GetAllJoinedClassroomUseCase implements UseCase<DataState, void> {
  final RoomReposityory _roomRepository;

  GetAllJoinedClassroomUseCase(this._roomRepository);

  @override
  Future<DataState> call({void param}) async {
    DataState response = await _roomRepository.getAllJoinedClassroom();
    return response;
  }
}
