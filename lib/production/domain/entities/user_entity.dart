import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String mail;
  final String username;
  final bool hasProfilePhoto;
  final List<String> joinedClassrooms;
  final List<Map<String, String>> receivedClassroomRequests;
  final List<int> friends;
  final List<int> receivedFriendRequests;
  final List<int> sentFriendRequests;
  final List<String> searchKeywords;

  const UserEntity({
    this.mail = "",
    this.username = "",
    this.hasProfilePhoto = false,
    this.joinedClassrooms = const <String>[],
    this.receivedClassroomRequests = const <Map<String, String>>[],
    this.friends = const <int>[],
    this.receivedFriendRequests = const <int>[],
    this.sentFriendRequests = const <int>[],
    this.searchKeywords = const <String>[],
  });

  @override
  List<Object?> get props => [mail, username];
}
