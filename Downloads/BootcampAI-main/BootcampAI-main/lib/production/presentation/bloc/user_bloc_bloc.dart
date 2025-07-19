import 'package:bloc/bloc.dart';
import 'package:bootcamp175/core/network/data_state.dart';
import 'package:bootcamp175/production/data/models/user_model.dart';
import 'package:bootcamp175/production/data/repositories/user_repository.dart';
import 'package:bootcamp175/production/domain/usecases/user_usecases/create_user.dart';
import 'package:bootcamp175/production/domain/usecases/user_usecases/is_authenticated.dart';
import 'package:bootcamp175/production/domain/usecases/user_usecases/login_request.dart';
import 'package:bootcamp175/production/domain/usecases/user_usecases/logout_request.dart';

part 'user_bloc_event.dart';
part 'user_bloc_state.dart';

class UserBlocBloc extends Bloc<UserBlocEvent, UserBlocState> {
  final UserRepository _userRepository = UserRepository();

  late CreteUserUseCase _createUserUseCase;
  late LoginRequestUseCase _loginRequestUseCase;
  late LogoutRequestUseCase _logoutRequestUseCase;
  late IsAuthenticatedUseCase _isAuthenticatedUseCase;

  UserBlocBloc() : super(const UserBlocInitial()) {
    _createUserUseCase = CreteUserUseCase(_userRepository);
    _loginRequestUseCase = LoginRequestUseCase(_userRepository);
    _logoutRequestUseCase = LogoutRequestUseCase(_userRepository);
    _isAuthenticatedUseCase = IsAuthenticatedUseCase(_userRepository);

    on<CreateUser>(onCreateUser);
    on<LoginRequest>(onLoginRequest);
    on<LogoutRequest>(onLogoutRequest);
    on<IsAuthenticatedRequest>(onIsAuthenticatedRequest);
  }

  void onIsAuthenticatedRequest(
    IsAuthenticatedRequest event,
    Emitter<UserBlocState> emit,
  ) async {
    emit(const IsAuthenticatedLoading());
    final DataState dataState = await _isAuthenticatedUseCase.call();
    if (dataState is DataSuccess && dataState.data != null) {
      emit(IsAuthenticatedDone(data: dataState.data!));
    } else {
      emit(IsAuthenticatedError(error: dataState.error));
    }
  }

  void onCreateUser(CreateUser event, Emitter<UserBlocState> emit) async {
    emit(const UserBlocLoading());
    final DataState dataState = await _createUserUseCase.call(
      param1: event.user!,
      param2: event.password!,
    );
    if (dataState is DataSuccess && dataState.data != null) {
      emit(UserBlocDone(data: dataState.data!));
    } else {
      emit(UserBlocError(error: dataState.error));
    }
  }

  void onLoginRequest(LoginRequest event, Emitter<UserBlocState> emit) async {
    emit(const UserBlocLoading());
    final DataState dataState = await _loginRequestUseCase.call(
      param1: event.user!,
      param2: event.password!,
    );
    if (dataState is DataSuccess && dataState.data != null) {
      emit(UserBlocDone(data: dataState.data!));
    } else {
      emit(UserBlocError(error: dataState.error));
    }
  }

  void onLogoutRequest(LogoutRequest event, Emitter<UserBlocState> emit) async {
    emit(const UserBlocLoading());
    final DataState dataState = await _logoutRequestUseCase.call();
    if (dataState is DataSuccess && dataState.data != null) {
      emit(UserBlocLogout(data: dataState.data!));
    } else {
      emit(UserBlocError(error: dataState.error));
    }
  }
}
