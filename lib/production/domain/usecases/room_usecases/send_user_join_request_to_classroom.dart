import 'package:bootcamp175/core/network/data_state.dart';
import 'package:bootcamp175/core/usecase/usecase.dart';
import 'package:bootcamp175/production/data/models/user_public_profile_model.dart';
import 'package:bootcamp175/production/data/repositories/room_repository.dart';

class SendUserJoinRequestToClassroomUseCase
    implements
        UseCase3<
          DataState,
          String,
          UserPublicProfileModel,
          UserPublicProfileModel
        > {
  final RoomReposityory _roomRepository;

  SendUserJoinRequestToClassroomUseCase(this._roomRepository);

  @override
  Future<DataState> call({
    required String param1,
    required UserPublicProfileModel param2,
    required UserPublicProfileModel param3,
  }) async {
    DataState response = await _roomRepository.sendUserJoinRequestToClassroom(
      roomName: param1,
      requestOwner: param2,
      requestUser: param3,
    );
    return response;
  }
}
