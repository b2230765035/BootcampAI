import 'package:bootcamp175/core/network/data_state.dart';
import 'package:bootcamp175/core/usecase/usecase.dart';
import 'package:bootcamp175/production/data/repositories/room_repository.dart';

class UserAcceptClassroomInviteUseCase
    implements UseCase3<DataState, String, String, String> {
  final RoomReposityory _roomRepository;

  UserAcceptClassroomInviteUseCase(this._roomRepository);

  @override
  Future<DataState> call({
    required String param1,
    required String param2,
    required String param3,
  }) async {
    DataState response = await _roomRepository.userAcceptClassroomInvite(
      roomName: param1,
      username: param2,
      requestOwnerUsername: param3,
    );
    return response;
  }
}
