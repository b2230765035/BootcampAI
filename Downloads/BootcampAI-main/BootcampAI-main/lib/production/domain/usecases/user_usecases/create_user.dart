import 'package:bootcamp175/core/network/data_state.dart';
import 'package:bootcamp175/core/usecase/usecase.dart';
import 'package:bootcamp175/production/data/models/user_model.dart';
import 'package:bootcamp175/production/data/repositories/user_repository.dart';

class CreteUserUseCase implements UseCase2<DataState, UserModel, String> {
  final UserRepository _userRepository;

  CreteUserUseCase(this._userRepository);

  @override
  Future<DataState> call({
    required UserModel param1,
    required String param2,
  }) async {
    DataState response = await _userRepository.createUser(
      user: param1,
      password: param2,
    );
    return response;
  }
}
