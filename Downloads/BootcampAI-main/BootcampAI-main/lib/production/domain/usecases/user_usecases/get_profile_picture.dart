import 'package:bootcamp175/core/network/data_state.dart';
import 'package:bootcamp175/core/usecase/usecase.dart';
import 'package:bootcamp175/production/data/repositories/user_repository.dart';

class GetProfilePictureUseCase implements UseCase<DataState, String> {
  final UserRepository _userRepository;

  GetProfilePictureUseCase(this._userRepository);

  @override
  Future<DataState> call({required String param}) async {
    DataState response = await _userRepository.getUserProfilePicture(
      username: param,
    );
    return response;
  }
}
