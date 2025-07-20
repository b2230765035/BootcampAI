import 'package:bootcamp175/core/network/custom_response.dart';
import 'package:bootcamp175/production/data/models/message_model.dart';
import 'package:bootcamp175/production/data/models/room_model.dart';
import 'package:bootcamp175/production/data/models/user_model.dart';
import 'package:bootcamp175/production/data/models/user_public_profile_model.dart';
import 'package:bootcamp175/production/data/models/user_public_with_role.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreChatApi {
  FirebaseAuth firebaseAuthInstance = FirebaseAuth.instance;
  CollectionReference roomCollection = FirebaseFirestore.instance.collection(
    "clasrooms",
  );
  CollectionReference userCollection = FirebaseFirestore.instance.collection(
    "users",
  );

  Future<CustomResponse> deleteUserFromClassRoom({
    required int roomId,
    required UserPublicProfileModel userProfile,
  }) async {
    QuerySnapshot room = await roomCollection
        .where("roomId", isEqualTo: roomId)
        .get();
    if (room.docs.isEmpty) {
      return CustomResponse(
        status: false,
        error: "No public room found with that id",
      );
    }
    QueryDocumentSnapshot roomDoc = room.docs[0];
    roomCollection.doc(roomDoc.id).update({
      "currentUsers": FieldValue.arrayRemove([userProfile.toJson()]),
    });
    return CustomResponse(status: true, data: "User Removed From Public Room");
  }

  Future<CustomResponse> userSendMessageClassroomRequest({
    required MessageModel message,
  }) async {
    QuerySnapshot room = await roomCollection
        .where("roomId", isEqualTo: message.roomId)
        .get();
    if (room.docs.isEmpty) {
      return CustomResponse(
        status: false,
        error: "No public room found with that id",
      );
    }
    QueryDocumentSnapshot roomDoc = room.docs[0];

    await roomCollection
        .doc(roomDoc.id)
        .collection("messages")
        .add(message.toJson());

    return CustomResponse(status: true, data: "Message Added");
  }

  Future<CustomResponse> getClassroomMessageStream({
    required int roomId,
  }) async {
    QuerySnapshot room = await roomCollection
        .where("roomId", isEqualTo: roomId)
        .get();
    if (room.docs.isEmpty) {
      return CustomResponse(
        status: false,
        error: "No public room found with that id",
      );
    }
    QueryDocumentSnapshot roomDoc = room.docs[0];
    Stream messageStream = roomCollection
        .doc(roomDoc.id)
        .collection("messages")
        .orderBy('dateTime', descending: true)
        .snapshots();
    return CustomResponse(status: true, data: messageStream);
  }

  Future<CustomResponse> createClassroom({
    required String roomName,
    required UserPublicProfileModel owner,
  }) async {
    bool checkRoomName = await searchRoomName(roomName: roomName);
    if (checkRoomName) {
      try {
        UserPublicWithRoleModel roomAdmin = UserPublicWithRoleModel(
          role: "Teacher",
          username: owner.username,
          hasProfilePhoto: owner.hasProfilePhoto,
        );
        RoomModel newRoom = RoomModel(
          roomName: roomName,
          currentUsers: [roomAdmin],
          pendingUsers: [],
        );
        await roomCollection.doc().set(newRoom.toJson());
        DocumentSnapshot userDoc = await userCollection
            .doc(firebaseAuthInstance.currentUser!.uid)
            .get();

        await userCollection
            .doc(userDoc.id)
            .collection("privateFields")
            .doc(userDoc.id)
            .update({
              "joinedClassrooms": FieldValue.arrayUnion([roomName]),
            });
        return CustomResponse(status: true, data: "Created the Requested Room");
      } catch (e) {
        return CustomResponse(
          status: false,
          error: "Error While Creating The Classroom",
        );
      }
    } else {
      return CustomResponse(
        status: false,
        error: "Room Name Already Taken. Create Another Name",
      );
    }
  }

  Future<bool> searchRoomName({required String roomName}) async {
    QuerySnapshot res = await roomCollection
        .where("roomName", isEqualTo: roomName)
        .limit(1)
        .get();
    if (res.size > 0) {
      return false; //Roomname already in use
    } else {
      return true;
    }
  }

  Future<CustomResponse> getAllJoinedClassroom() async {
    DocumentSnapshot userPrivateData = await userCollection
        .doc(firebaseAuthInstance.currentUser!.uid)
        .collection("privateFields")
        .doc(firebaseAuthInstance.currentUser!.uid)
        .get();
    Map<String, dynamic> data = userPrivateData.data() as Map<String, dynamic>;
    List<dynamic> joinedClassrooms = data['joinedClassrooms'];
    if (joinedClassrooms.isNotEmpty) {
      return CustomResponse(status: true, data: joinedClassrooms);
    } else {
      return CustomResponse(
        status: false,
        error: "User didnt join any classrooms",
      );
    }
  }

  //modify this function !!
  Future<CustomResponse> addUserToClassRoom({
    required String roomName,
    required UserPublicProfileModel userProfile,
  }) async {
    QuerySnapshot room = await roomCollection
        .where("roomName", isEqualTo: roomName)
        .get();
    QueryDocumentSnapshot roomDoc = room.docs[0];
    if (room.docs.isEmpty) {
      return CustomResponse(
        status: false,
        error: "No public room found with that name",
      );
    }
    UserPublicWithRoleModel roomUserProfile = UserPublicWithRoleModel(
      role: "Student",
      username: userProfile.username,
      hasProfilePhoto: userProfile.hasProfilePhoto,
    );
    roomCollection.doc(roomDoc.id).update({
      "currentUsers": FieldValue.arrayUnion([roomUserProfile.toJson()]),
    });
    return await getClassroom(roomName: roomName);
  }

  Future<CustomResponse> getClassroom({required String roomName}) async {
    QuerySnapshot room = await roomCollection
        .where("roomName", isEqualTo: roomName)
        .limit(1)
        .get();

    if (room.docs.isEmpty) {
      return CustomResponse(
        status: false,
        error: "No public room found with that name",
      );
    }
    QueryDocumentSnapshot roomDoc = room.docs[0];
    RoomModel roomModel = RoomModel.fromJson(
      roomDoc.data() as Map<String, dynamic>,
    );
    return CustomResponse(status: true, data: roomModel);
  }

  Future<CustomResponse> sendUserJoinRequestToClassroom({
    required String roomName,
    required UserPublicProfileModel requestOwner,
    required UserPublicProfileModel requestUser,
  }) async {
    if (await isLoggedIn()) {
      QuerySnapshot response = await userCollection
          .where("username", isEqualTo: requestUser.username)
          .limit(1)
          .get();
      QuerySnapshot response2 = await roomCollection
          .where("roomName", isEqualTo: roomName)
          .limit(1)
          .get();
      if (response.docs.isEmpty) {
        return CustomResponse(
          status: false,
          error: "User Not Found. Can't send request to user",
        );
      } else if (response2.docs.isEmpty) {
        return CustomResponse(
          status: false,
          error: "Room Not Found. Can't send request to user",
        );
      }
      QueryDocumentSnapshot user = response.docs[0];
      QueryDocumentSnapshot room = response2.docs[0];
      QuerySnapshot userPrivateDoc = await userCollection
          .doc(user.id)
          .collection("privateFields")
          .get();
      QueryDocumentSnapshot userPrivateSnapshot = userPrivateDoc.docs[0];
      UserModel userPrivateModel = UserModel.fromJson(
        userPrivateSnapshot.data() as Map<String, dynamic>,
      );
      bool alreadyInvited = false;
      for (var element in userPrivateModel.receivedClassroomRequests) {
        if (element["roomName"] == roomName) {
          alreadyInvited = true;
        }
      }
      if (alreadyInvited) {
        return CustomResponse(status: false, error: "Already Invited User");
      } else {
        userCollection
            .doc(user.id)
            .collection("privateFields")
            .doc(user.id)
            .update({
              "receivedClassroomRequests": FieldValue.arrayUnion([
                {
                  "requestOwner": requestOwner.username,
                  "status": "pending",
                  "roomName": roomName,
                },
              ]),
            });
        roomCollection.doc(room.id).update({
          "pendingUsers": FieldValue.arrayUnion([
            {
              "requestOwner": requestOwner.username,
              "invitedUser": requestUser.username,
              "status": "pending",
              "roomName": roomName,
            },
          ]),
        });
        return CustomResponse(status: true, data: "Sent request to user.");
      }
    } else {
      return CustomResponse(status: false, error: "Not Logged in");
    }
  }

  Future<bool> isLoggedIn() async {
    User? currentUser = firebaseAuthInstance.currentUser;
    if (currentUser != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<CustomResponse> getClassroomDataOfUser({
    required String roomName,
    required UserPublicProfileModel user,
  }) async {
    CustomResponse classroomData = await getClassroom(roomName: roomName);
    if (classroomData.status == false) {
      return CustomResponse(
        status: false,
        error: "No classroom found with given name",
      );
    } else {
      List<UserPublicWithRoleModel> userListwithRoles =
          classroomData.data.currentUsers;
      late UserPublicWithRoleModel foundUser;
      bool doesUserExist = false;
      for (UserPublicWithRoleModel userData in userListwithRoles) {
        if (userData.username == user.username) {
          doesUserExist = true;
          foundUser = userData;
        }
      }
      if (!doesUserExist) {
        return CustomResponse(status: false, error: "Couldn't find the user");
      } else {
        return CustomResponse(
          status: true,
          data: {"foundUser": foundUser, "roomData": classroomData.data},
        );
      }
    }
  }

  Future<CustomResponse> searchUsers({required String username}) async {
    if (await isLoggedIn()) {
      QuerySnapshot response = await userCollection
          .where("searchKeywords", arrayContains: username)
          .limit(5)
          .get();

      if (response.docs.isEmpty) {
        return CustomResponse(status: false, error: "Couldn't Find Any Users");
      }
      List<UserPublicProfileModel> usersFound = [];
      for (var user in response.docs) {
        usersFound.add(
          UserPublicProfileModel.fromJson(user.data() as Map<String, dynamic>),
        );
      }
      return CustomResponse(status: true, data: usersFound);
    } else {
      return CustomResponse(status: false, error: "Not Logged in");
    }
  }
}
