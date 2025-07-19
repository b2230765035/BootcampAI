import 'dart:typed_data';
import 'package:bootcamp175/core/network/custom_response.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseCloudApi {
  FirebaseAuth firebaseAuthInstance = FirebaseAuth.instance;
  final storageRef = FirebaseStorage.instance.ref();
  CollectionReference userCollection = FirebaseFirestore.instance.collection(
    "users",
  );

  Future<bool> isLoggedIn() async {
    User? currentUser = firebaseAuthInstance.currentUser;
    if (currentUser != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<CustomResponse> getProfilePicture({required String username}) async {
    final imageReference = storageRef.child("profile_pictures/$username.jpg");
    const threeMegabyte = 1024 * 1024 * 3;

    Uint8List? image = await imageReference.getData(threeMegabyte);
    if (image != null) {
      return CustomResponse(status: true, data: image);
    } else {
      return CustomResponse(status: false, error: "Image Not Found");
    }
  }

  Future<void> updateUserDataAboutProfilePhoto({required bool status}) async {
    if (await isLoggedIn()) {
      await userCollection.doc(firebaseAuthInstance.currentUser!.uid).update({
        "hasProfilePhoto": status,
      });
      await userCollection
          .doc(firebaseAuthInstance.currentUser!.uid)
          .collection("privateFields")
          .doc(firebaseAuthInstance.currentUser!.uid)
          .update({"hasProfilePhoto": status});
    }
  }

  Future<CustomResponse> uploadProfilePicture({
    required String username,
    required Uint8List image,
  }) async {
    final imageReference = storageRef.child("profile_pictures/$username.jpg");
    try {
      await imageReference.putData(
        image,
        SettableMetadata(contentType: "image/jpeg"),
      );
      await updateUserDataAboutProfilePhoto(status: true);
    } on FirebaseException catch (e) {
      return CustomResponse(status: false, error: e.toString());
    }

    return CustomResponse(status: true, data: "Uploaded image");
  }
}
