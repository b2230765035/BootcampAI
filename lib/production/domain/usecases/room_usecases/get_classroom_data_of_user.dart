import 'package:bootcamp175/core/network/data_state.dart';
import 'package:bootcamp175/core/usecase/usecase.dart';
import 'package:bootcamp175/production/data/models/user_public_profile_model.dart';
import 'package:bootcamp175/production/data/repositories/room_repository.dart';

class GetClassroomDataOfUserUseCase
    implements UseCase2<DataState, String, UserPublicProfileModel> {
  final RoomReposityory _roomRepository;

  GetClassroomDataOfUserUseCase(this._roomRepository);

  @override
  Future<DataState> call({
    required String param1,
    required UserPublicProfileModel param2,
  }) async {
    DataState response = await _roomRepository.getClassroomDataOfUser(
      roomName: param1,
      user: param2,
    );
    return response;
  }
}
