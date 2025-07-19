import 'package:bootcamp175/core/network/data_state.dart';
import 'package:bootcamp175/core/usecase/usecase.dart';
import 'package:bootcamp175/production/data/models/user_public_profile_model.dart';
import 'package:bootcamp175/production/data/repositories/room_repository.dart';

class CreteClassroomUseCase
    implements UseCase2<DataState, String, UserPublicProfileModel> {
  final RoomReposityory _roomRepository;

  CreteClassroomUseCase(this._roomRepository);

  @override
  Future<DataState> call({
    required String param1,
    required UserPublicProfileModel param2,
  }) async {
    DataState response = await _roomRepository.createClassroom(
      roomName: param1,
      owner: param2,
    );
    return response;
  }
}
