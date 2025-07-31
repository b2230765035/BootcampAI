import 'dart:io';

import 'package:bootcamp175/core/network/custom_response.dart';
import 'package:bootcamp175/production/data/models/message_model.dart';
import 'package:bootcamp175/production/data/models/room_model.dart';
import 'package:bootcamp175/production/data/models/user_model.dart';
import 'package:bootcamp175/production/data/models/user_public_profile_model.dart';
import 'package:bootcamp175/production/data/models/user_public_with_role.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
          rejectedUsers: [],
          homeworks: [],
          notes: [],
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
    UserModel data = UserModel.fromJson(
      userPrivateData.data() as Map<String, dynamic>,
    );
    List<dynamic> joinedClassrooms = data.joinedClassrooms;
    if (joinedClassrooms.isNotEmpty) {
      return CustomResponse(
        status: true,
        data: {"joinedClassrooms": joinedClassrooms, "userData": data},
      );
    } else {
      return CustomResponse(
        status: true,
        data: {"joinedClassrooms": [], "userData": data},
      );
    }
  }

  Future<CustomResponse> userAcceptClassroomInvite({
    required String roomName,
    required String username,
    required String requestOwnerUsername,
  }) async {
    if (!await isLoggedIn()) {
      return CustomResponse(status: false, error: "Not Logged in");
    }

    // Kullanıcıyı bul
    QuerySnapshot userQuery = await userCollection
        .where("username", isEqualTo: username)
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      return CustomResponse(status: false, error: "User not found");
    }

    DocumentSnapshot userDoc = userQuery.docs.first;
    String userId = userDoc.id;

    // Kullanıcının private datası
    DocumentSnapshot userPrivateDoc = await userCollection
        .doc(userId)
        .collection("privateFields")
        .doc(userId)
        .get();

    if (!userPrivateDoc.exists) {
      return CustomResponse(
        status: false,
        error: "User private data not found",
      );
    }

    UserModel userPrivateModel = UserModel.fromJson(
      userPrivateDoc.data() as Map<String, dynamic>,
    );

    // Step 1: receivedClassroomRequests içinde status'u "accepted" yap
    List<dynamic> updatedReceivedRequests = List.from(
      userPrivateModel.receivedClassroomRequests,
    );

    for (var request in updatedReceivedRequests) {
      if (request["roomName"] == roomName &&
          request["status"] == "pending" &&
          request["requestOwner"] == requestOwnerUsername) {
        request["status"] = "accepted";
        break;
      }
    }

    // Step 2: joinedClassrooms'a roomId ekle
    // Şimdi room'u bulalım
    QuerySnapshot roomQuery = await roomCollection
        .where("roomName", isEqualTo: roomName)
        .limit(1)
        .get();

    if (roomQuery.docs.isEmpty) {
      return CustomResponse(status: false, error: "Room not found");
    }

    DocumentSnapshot roomDoc = roomQuery.docs.first;
    String roomId = roomDoc.id;

    // Kullanıcı güncelle
    await userCollection
        .doc(userId)
        .collection("privateFields")
        .doc(userId)
        .update({
          "receivedClassroomRequests": updatedReceivedRequests,
          "joinedClassrooms": FieldValue.arrayUnion([roomName]),
        });

    // Room verisini al
    Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;

    // Step 3: pendingUsers listesinden kullanıcıyı çıkar
    List<Map<String, dynamic>> pendingUsers = List<Map<String, dynamic>>.from(
      roomData["pendingUsers"] ?? [],
    );
    List<Map<String, dynamic>> currentUsers = List<Map<String, dynamic>>.from(
      roomData["currentUsers"] ?? [],
    );

    // İlgili pending request'i bul
    Map<String, String>? targetRequest;

    for (var request in pendingUsers) {
      if (request["roomName"] == roomName &&
          request["invitedUser"] == username &&
          request["status"] == "pending" &&
          request["requestOwner"] == requestOwnerUsername) {
        targetRequest = Map<String, String>.from(request);
        break;
      }
    }

    if (targetRequest != null) {
      // PendingUsers'tan sil
      pendingUsers.removeWhere(
        (request) =>
            request["roomName"] == roomName &&
            request["invitedUser"] == username &&
            request["status"] == "pending" &&
            request["requestOwner"] == requestOwnerUsername,
      );
      Map<String, dynamic> addedUser =
          userQuery.docs[0].data() as Map<String, dynamic>;
      addedUser.addAll({"role": "Student"});
      // currentUsers'a ekle
      currentUsers.add(addedUser);

      // Güncelleme yap
      await roomCollection.doc(roomId).update({
        "pendingUsers": pendingUsers,
        "currentUsers": currentUsers,
      });

      return CustomResponse(status: true, data: "Join request accepted");
    } else {
      return CustomResponse(status: false, error: "Pending request not found");
    }
  }

  Future<CustomResponse> userRejectClassroomInvite({
    required String roomName,
    required String username,
    required String requestOwnerUsername,
  }) async {
    if (!await isLoggedIn()) {
      return CustomResponse(status: false, error: "Not Logged in");
    }

    // Kullanıcıyı bul
    QuerySnapshot userQuery = await userCollection
        .where("username", isEqualTo: username)
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) {
      return CustomResponse(status: false, error: "User not found");
    }

    DocumentSnapshot userDoc = userQuery.docs.first;
    String userId = userDoc.id;

    // Kullanıcının private datası
    DocumentSnapshot userPrivateDoc = await userCollection
        .doc(userId)
        .collection("privateFields")
        .doc(userId)
        .get();

    if (!userPrivateDoc.exists) {
      return CustomResponse(
        status: false,
        error: "User private data not found",
      );
    }

    UserModel userPrivateModel = UserModel.fromJson(
      userPrivateDoc.data() as Map<String, dynamic>,
    );

    // Step 1: receivedClassroomRequests içinde status'u "accepted" yap
    List<dynamic> updatedReceivedRequests = List.from(
      userPrivateModel.receivedClassroomRequests,
    );

    for (var request in updatedReceivedRequests) {
      if (request["roomName"] == roomName &&
          request["status"] == "pending" &&
          request["requestOwner"] == requestOwnerUsername) {
        request["status"] = "rejected";
        break;
      }
    }

    // Step 2: joinedClassrooms'a roomId ekle
    // Şimdi room'u bulalım
    QuerySnapshot roomQuery = await roomCollection
        .where("roomName", isEqualTo: roomName)
        .limit(1)
        .get();

    if (roomQuery.docs.isEmpty) {
      return CustomResponse(status: false, error: "Room not found");
    }

    DocumentSnapshot roomDoc = roomQuery.docs.first;
    String roomId = roomDoc.id;

    // Kullanıcı güncelle
    await userCollection
        .doc(userId)
        .collection("privateFields")
        .doc(userId)
        .update({"receivedClassroomRequests": updatedReceivedRequests});

    // Room verisini al
    Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;

    // Step 3: pendingUsers listesinden kullanıcıyı çıkar
    List<Map<String, dynamic>> pendingUsers = List<Map<String, dynamic>>.from(
      roomData["pendingUsers"] ?? [],
    );
    List<Map<String, dynamic>> rejectedUsers = List<Map<String, dynamic>>.from(
      roomData["rejectedUsers"] ?? [],
    );

    // İlgili pending request'i bul
    Map<String, String>? targetRequest;

    for (var request in pendingUsers) {
      if (request["roomName"] == roomName &&
          request["invitedUser"] == username &&
          request["status"] == "pending" &&
          request["requestOwner"] == requestOwnerUsername) {
        targetRequest = Map<String, String>.from(request);
        break;
      }
    }

    if (targetRequest != null) {
      // PendingUsers'tan sil
      pendingUsers.removeWhere(
        (request) =>
            request["roomName"] == roomName &&
            request["invitedUser"] == username &&
            request["status"] == "pending" &&
            request["requestOwner"] == requestOwnerUsername,
      );
      Map<String, dynamic> rejectedUser =
          userQuery.docs[0].data() as Map<String, dynamic>;
      rejectedUser.addAll({
        "requestOwner": requestOwnerUsername,
        "status": "rejected",
      });
      rejectedUser.remove("searchKeywords");

      // currentUsers'a ekle
      rejectedUsers.add(rejectedUser);

      // Güncelleme yap
      await roomCollection.doc(roomId).update({
        "pendingUsers": pendingUsers,
        "rejectedUsers": rejectedUsers,
      });

      return CustomResponse(status: true, data: "Reject request accepted");
    } else {
      return CustomResponse(status: false, error: "Pending request not found");
    }
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

  Future<CustomResponse> getClassroomDataOfUserWithUsername({
    required String roomName,
    required String username,
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
        if (userData.username == username) {
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

  Future<CustomResponse> uploadPDF({
    required String fileName,
    required File file,
    required String objectiveName,
    required String roomName,
    required String pdfType,
    required String uploadOwner,
  }) async {
    try {
      late Reference storageRef;
      String safeRoomName = sanitize(roomName);
      String safeFileName = sanitize(fileName);

      if (pdfType == "homework") {
        storageRef = FirebaseStorage.instance.ref().child(
          "classrooms/$safeRoomName/homeworks/$safeFileName",
        );
      } else if (pdfType == "note") {
        storageRef = FirebaseStorage.instance.ref().child(
          "classrooms/$safeRoomName/notes/$safeFileName",
        );
      }
      final uploadTask = await storageRef.putFile(file);

      final downloadUrl = await uploadTask.ref.getDownloadURL();

      QuerySnapshot room = await roomCollection
          .where("roomName", isEqualTo: roomName)
          .limit(1)
          .get();
      if (room.docs.isEmpty) {
        return CustomResponse(
          status: false,
          error: "No  classroom found with that name",
        );
      }
      QueryDocumentSnapshot roomDoc = room.docs[0];

      Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;
      if (pdfType == "homework") {
        List<Map<String, dynamic>> homeworks = List<Map<String, dynamic>>.from(
          roomData["homeworks"] ?? [],
        );
        homeworks.add({
          "homeworkName": objectiveName,
          "fileName": fileName,
          "fileUrl": downloadUrl,
          "uploadOwner": uploadOwner,
          "roomName": roomName,
          "uploadedAt": Timestamp.now(),
        });
        await roomCollection.doc(roomDoc.id).update({"homeworks": homeworks});
        return await getClassroomDataOfUserWithUsername(
          roomName: roomName,
          username: uploadOwner,
        );
      } else {
        List<Map<String, dynamic>> notes = List<Map<String, dynamic>>.from(
          roomData["notes"] ?? [],
        );
        notes.add({
          "noteName": objectiveName,
          "fileName": fileName,
          "fileUrl": downloadUrl,
          "uploadOwner": uploadOwner,
          "roomName": roomName,
          "uploadedAt": Timestamp.now(),
        });
        await roomCollection.doc(roomDoc.id).update({"notes": notes});
        return CustomResponse(status: true, data: "Uploaded File Succesfully");
      }
    } catch (e) {
      return CustomResponse(
        status: false,
        error: "Something went wrong while uploading pdf ",
      );
    }
  }
}

String sanitize(String input) {
  return input.replaceAll(RegExp(r'[\/\\#\?\%\*\:\[\]]'), '-');
}
