part of 'user_bloc_bloc.dart';

abstract class UserBlocState {
  final dynamic data;
  final String? error;
  final dynamic image;

  const UserBlocState({this.data, this.error, this.image});
}

class UserBlocInitial extends UserBlocState {
  const UserBlocInitial();
}

//For Login and Register Actions
class UserBlocLoading extends UserBlocState {
  const UserBlocLoading();
}

class UserBlocDone extends UserBlocState {
  const UserBlocDone({required super.data});
}

class UserBlocError extends UserBlocState {
  const UserBlocError({required super.error});
}

//Logout State
class UserBlocLogout extends UserBlocState {
  const UserBlocLogout({required super.data});
}

//For checking if user is Authenticated. If already authenticated, navigate to main page
class IsAuthenticatedLoading extends UserBlocState {
  const IsAuthenticatedLoading();
}

class IsAuthenticatedDone extends UserBlocState {
  const IsAuthenticatedDone({required super.data});
}

class IsAuthenticatedError extends UserBlocState {
  const IsAuthenticatedError({required super.error});
}
