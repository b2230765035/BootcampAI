import 'package:bootcamp175/core/network/custom_response.dart';
import 'package:bootcamp175/production/data/models/message_model.dart';
import 'package:bootcamp175/production/data/models/room_model.dart';
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

  Future<CustomResponse> getAllClasses() async {
    QuerySnapshot result = await roomCollection.get();
    List<QueryDocumentSnapshot> results = result.docs;
    if (results.isEmpty) {
      return CustomResponse(status: false, error: "Zero Classes Found");
    } else {
      return CustomResponse(status: true, data: results);
    }
  }

  Future<CustomResponse> addUserToClassRoom({
    required int roomId,
    required UserPublicProfileModel userProfile,
  }) async {
    QuerySnapshot room = await roomCollection
        .where("roomId", isEqualTo: roomId)
        .get();
    QueryDocumentSnapshot roomDoc = room.docs[0];
    roomCollection.doc(roomDoc.id).update({
      "currentUsers": FieldValue.arrayUnion([userProfile.toJson()]),
    });
    return await getClassRoom(roomId: roomId);
  }

  Future<CustomResponse> getClassRoom({required int roomId}) async {
    QuerySnapshot room = await roomCollection
        .where("roomId", isEqualTo: roomId)
        .get();

    QueryDocumentSnapshot roomDoc = room.docs[0];
    if (room.docs.isEmpty) {
      return CustomResponse(
        status: false,
        error: "No public room found with that id",
      );
    }
    RoomModel roomModel = RoomModel.fromJson(
      roomDoc.data() as Map<String, dynamic>,
    );
    return CustomResponse(status: true, data: roomModel);
  }

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
}
