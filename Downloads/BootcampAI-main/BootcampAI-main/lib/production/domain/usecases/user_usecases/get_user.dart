import 'package:bootcamp175/core/network/data_state.dart';
import 'package:bootcamp175/core/usecase/usecase.dart';
import 'package:bootcamp175/production/data/repositories/user_repository.dart';

class GetUserUseCase implements UseCase<DataState, String> {
  final UserRepository _userRepository;

  GetUserUseCase(this._userRepository);

  @override
  Future<DataState> call({required String param}) async {
    DataState response = await _userRepository.getUser(username: param);
    return response;
  }
}
