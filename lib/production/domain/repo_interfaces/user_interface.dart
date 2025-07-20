import 'dart:typed_data';

import 'package:bootcamp175/core/network/data_state.dart';
import 'package:bootcamp175/production/domain/entities/user_entity.dart';

abstract class UserInterface<T extends UserEntity> {
  Future<DataState> createUser({required T user, required String password});
  Future<DataState> loginRequest({required T user, required String password});
  Future<DataState> logoutRequest();
  Future<DataState> getCurrentUser();
  Future<DataState> getUser({required String username});

  Future<DataState> getUserPrivateInfo();
  Future<DataState> getUserProfilePicture({required String username});
  Future<DataState> uploadProfilePicture({
    required String username,
    required Uint8List image,
  });
}
