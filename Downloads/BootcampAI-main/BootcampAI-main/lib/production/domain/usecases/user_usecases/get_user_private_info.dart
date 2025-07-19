import 'package:bootcamp175/core/network/data_state.dart';
import 'package:bootcamp175/core/usecase/usecase.dart';
import 'package:bootcamp175/production/data/models/user_model.dart';
import 'package:bootcamp175/production/data/repositories/user_repository.dart';

class GetUserPrivateInfoUseCase implements UseCase<DataState, UserModel> {
  final UserRepository _userRepository;

  GetUserPrivateInfoUseCase(this._userRepository);

  @override
  Future<DataState> call({void param}) async {
    DataState response = await _userRepository.getUserPrivateInfo();
    return response;
  }
}
