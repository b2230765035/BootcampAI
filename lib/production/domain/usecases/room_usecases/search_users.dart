import 'package:bootcamp175/core/network/data_state.dart';
import 'package:bootcamp175/core/usecase/usecase.dart';
import 'package:bootcamp175/production/data/repositories/room_repository.dart';
import 'package:bootcamp175/production/data/repositories/user_repository.dart';

class SearchUsersUseCase implements UseCase<DataState, String> {
  final RoomReposityory _roomRepository;

  SearchUsersUseCase(this._roomRepository);

  @override
  Future<DataState> call({required String param}) async {
    DataState response = await _roomRepository.searchUsers(username: param);
    return response;
  }
}
