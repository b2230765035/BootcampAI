import 'dart:typed_data';
import 'package:bootcamp175/core/network/data_state.dart';
import 'package:bootcamp175/core/usecase/usecase.dart';
import 'package:bootcamp175/production/data/repositories/user_repository.dart';

class UploadProfilePictureUseCase
    implements UseCase2<DataState, String, Uint8List> {
  final UserRepository _userRepository;

  UploadProfilePictureUseCase(this._userRepository);

  @override
  Future<DataState> call({
    required String param1,
    required Uint8List param2,
  }) async {
    DataState response = await _userRepository.uploadProfilePicture(
      username: param1,
      image: param2,
    );
    return response;
  }
}
