import 'dart:typed_data';

import 'package:bootcamp175/core/network/custom_response.dart';
import 'package:bootcamp175/core/network/data_state.dart';
import 'package:bootcamp175/production/data/data_sources/remote/firebase_api.dart';
import 'package:bootcamp175/production/data/models/user_model.dart';
import 'package:bootcamp175/production/domain/repo_interfaces/user_interface.dart';

//Will be Using UserModel instead of UserEntity inside DataState for the functions we wil be creating. (Ex: fromJson... )

class UserRepository extends UserInterface<UserModel> {
  FbFstoreApi fbFstoreApi = FbFstoreApi();

  @override
  Future<DataState> createUser({
    required UserModel user,
    required String password,
  }) async {
    CustomResponse response = await fbFstoreApi.createUser(
      user: user,
      password: password,
    );
    if (response.status == true) {
      return DataSuccess(response.data);
    } else {
      return DataFailed(response.error!);
    }
  }

  @override
  Future<DataState> loginRequest({
    required UserModel user,
    required String password,
  }) async {
    CustomResponse response = await fbFstoreApi.signIn(
      user: user,
      password: password,
    );
    if (response.status == true) {
      return DataSuccess(response.data);
    } else {
      return DataFailed(response.error!);
    }
  }

  @override
  Future<DataState> logoutRequest() async {
    CustomResponse response = await fbFstoreApi.signOut();
    if (response.status == true) {
      return DataSuccess(response.data);
    } else {
      return DataFailed(response.error!);
    }
  }

  @override
  Future<DataState> getCurrentUser() async {
    CustomResponse response = await fbFstoreApi.getCurrentUserPublicProfile();
    if (response.status == true) {
      return DataSuccess(response.data);
    } else {
      return DataFailed(response.error!);
    }
  }

  @override
  Future<DataState> getUser({required String username}) async {
    CustomResponse response = await fbFstoreApi.getUser(username: username);
    if (response.status == true) {
      return DataSuccess(response.data);
    } else {
      return DataFailed(response.error!);
    }
  }

  @override
  Future<DataState> getUserPrivateInfo() async {
    CustomResponse response = await fbFstoreApi.getCurrentUserPrivateInfo();
    if (response.status == true) {
      return DataSuccess(response.data);
    } else {
      return DataFailed(response.error!);
    }
  }
}
