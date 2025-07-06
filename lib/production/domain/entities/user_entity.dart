import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String mail;
  final String username;
  final bool hasProfilePhoto;
  final List<int> friends;
  final List<int> receivedFriendRequests;
  final List<int> sentFriendRequests;

  const UserEntity({
    this.mail = "",
    this.username = "",
    this.hasProfilePhoto = false,
    this.friends = const <int>[],
    this.receivedFriendRequests = const <int>[],
    this.sentFriendRequests = const <int>[],
  });

  @override
  List<Object?> get props => [mail, username];
}
