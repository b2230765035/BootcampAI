import 'package:bloc/bloc.dart';
import 'package:bootcamp175/core/network/data_state.dart';
import 'package:bootcamp175/production/data/models/user_model.dart';
import 'package:bootcamp175/production/data/repositories/user_repository.dart';
import 'package:bootcamp175/production/domain/usecases/user_usecases/create_user.dart';
import 'package:bootcamp175/production/domain/usecases/user_usecases/get_profile_picture.dart';
import 'package:bootcamp175/production/domain/usecases/user_usecases/is_authenticated.dart';
import 'package:bootcamp175/production/domain/usecases/user_usecases/login_request.dart';
import 'package:bootcamp175/production/domain/usecases/user_usecases/logout_request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_bloc_event.dart';
part 'user_bloc_state.dart';

class UserBlocBloc extends Bloc<UserBlocEvent, UserBlocState> {
  final UserRepository _userRepository = UserRepository();

  late CreteUserUseCase _createUserUseCase;
  late LoginRequestUseCase _loginRequestUseCase;
  late LogoutRequestUseCase _logoutRequestUseCase;
  late IsAuthenticatedUseCase _isAuthenticatedUseCase;
  late GetProfilePictureUseCase _getProfilePictureUseCase;

  UserBlocBloc() : super(const UserBlocInitial()) {
    _createUserUseCase = CreteUserUseCase(_userRepository);
    _loginRequestUseCase = LoginRequestUseCase(_userRepository);
    _logoutRequestUseCase = LogoutRequestUseCase(_userRepository);
    _isAuthenticatedUseCase = IsAuthenticatedUseCase(_userRepository);
    _getProfilePictureUseCase = GetProfilePictureUseCase(_userRepository);

    on<CreateUser>(onCreateUser);
    on<LoginRequest>(onLoginRequest);
    on<LogoutRequest>(onLogoutRequest);
    on<IsAuthenticatedRequest>(onIsAuthenticatedRequest);
    on<GetUserProfilePictureRequest>(onProfilePictureRequest);
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
      final User? firebaseAuthUser = dataState.data as User?;

      if (firebaseAuthUser != null) {
        print('Firebase Auth User Email: ${firebaseAuthUser.email}');
        try {
          // 'String?' hatasını çözmek için:
          // UserModel'deki 'mail' alanı String bekliyorsa ve firebaseAuthUser.email null ise
          // bu satırda hata alırsınız. Bu durumda ya UserModel'i 'mail: String?' yapın
          // ya da null gelme ihtimalini kontrol edin (?? 'default@example.com' gibi)
          // Ancak Auth ile kayıt olduğu için email'in null gelmesi beklenmez, o yüzden '!' kullanılabilir.
          final UserModel userToSave = UserModel(
            mail: firebaseAuthUser.email, // Buraya ! ekledik, çünkü email null olmamalıdır kayıtta
            username: (event.user as UserModel).username,
            hasProfilePhoto: (event.user as UserModel).hasProfilePhoto,
            joinedClassrooms: (event.user as UserModel).joinedClassrooms,
            receivedClassroomRequests: (event.user as UserModel).receivedClassroomRequests,
            friends: (event.user as UserModel).friends,
            // Hata düzeltme: receivedFriendRequests için doğru alan
            receivedFriendRequests: (event.user as UserModel).receivedFriendRequests,
            sentFriendRequests: (event.user as UserModel).sentFriendRequests,
          );
          print('User model to save (mail field): ${userToSave.mail}'); // DEBUG AMAÇLI EKLE
          print('User model to save (as JSON): ${userToSave.toJson()}');
          await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseAuthUser.uid)
              .set(userToSave.toJson());

          emit(UserBlocDone(data: firebaseAuthUser));
        } catch (firestoreError) {
          await firebaseAuthUser.delete();
          emit(UserBlocError(error: 'Firestore\'a kullanıcı kaydedilemedi: ${firestoreError.toString()}'));
        }
      } else {
        emit(const UserBlocError(error: 'Firebase kullanıcısı oluşturulamadı.'));
      }
    } else {
      emit(UserBlocError(error: dataState.error ?? 'Kayıt başarısız oldu.'));
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

  void onProfilePictureRequest(
      GetUserProfilePictureRequest event,
      Emitter<UserBlocState> emit,
      ) async {
    // 'state' hatasını çözmek için 'UserBlocState' sınıfınızdaki 'data' alanının tipine göre kontrol yapıldı.
    // Eğer 'data' kesinlikle null değilse '!' ile erişebilirsiniz.
    // Varsayılan olarak 'data' null olabilirse bu şekilde kontrol etmek en güvenlisidir.
    if (state.data != null && (state.data as UserModel).hasProfilePhoto) { // Type cast to UserModel
      emit(ProfilePictureLoading(data: state.data!));
      final DataState dataState = await _getProfilePictureUseCase.call(
        param: event.username,
      );
      if (dataState is DataSuccess && dataState.data != null) {
        // Burada 'data'yı tekrar kullanırken null olmama garantisi olduğu için '!' kullanılabilir.
        emit(ProfilePictureDone(data: state.data!, image: dataState.data));
      }
    }
  }
} // UserBlocBloc sınıfının kapanış parantezi buraya geldi!