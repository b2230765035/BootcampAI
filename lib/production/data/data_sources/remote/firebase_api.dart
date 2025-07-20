import 'package:bootcamp175/core/network/custom_response.dart';
import 'package:bootcamp175/production/data/models/user_model.dart';
import 'package:bootcamp175/production/data/models/user_public_profile_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

class FbFstoreApi {
  //******** Instances And Collections Declared
  FirebaseAuth firebaseAuthInstance = FirebaseAuth.instance;
  FirebaseFunctions cloudFunctions = FirebaseFunctions.instance;

  CollectionReference userCollection = FirebaseFirestore.instance.collection(
    "users",
  );

  ///Function for creating a user and adding him to firestore afterwards
  Future<CustomResponse> createUser({
    required UserModel user,
    required String password,
  }) async {
    bool checkUsermane = await searchUsername(
      username: user.username,
    ); //check if username is taken first
    UserCredential userCred;
    if (checkUsermane == false) {
      try {
        userCred = await firebaseAuthInstance.createUserWithEmailAndPassword(
          email: user.mail,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "weak-password":
            return CustomResponse(
              status: false,
              error: "The password provided is too weak.",
            );
          case "email-already-in-use":
            return CustomResponse(
              status: false,
              error: 'The account already exists for that email.',
            );
          case "invalid-email":
            return CustomResponse(
              status: false,
              error: 'The email provided is invalid.',
            );
          case "operation-not-allowed":
            return CustomResponse(
              status: false,
              error: 'Email/password accounts are not enabled',
            );
          default:
            return CustomResponse(
              status: false,
              error: 'Something went wrong while creating user',
            );
        }
      }

      String userUid = userCred.user!.uid;
      await addUserToFirestore(
        user: user,
        uid: userUid,
      ); //Add user to firestore

      return CustomResponse(
        status: true,
        data: UserPublicProfileModel(username: user.username),
      );
    } else {
      return CustomResponse(status: false, error: 'Username Already Taken');
    }
  }

  ///Function to add an userModel to collection of firestore
  Future<void> addUserToFirestore({
    required UserModel user,
    required String uid,
  }) async {
    final List<String> keywords = generateSearchKeywords(user.username);

    //Adding Public Profile to outer doc
    UserPublicProfileModel userPublicProfile = UserPublicProfileModel(
      username: user.username,
      searchKeywords: keywords,
    );
    await userCollection.doc(uid).set(userPublicProfile.toJson());
    //Adding Private informations to inner collection
    final privateData = user.toJson();
    privateData['searchKeywords'] = keywords;

    await userCollection
        .doc(uid)
        .collection("privateFields")
        .doc(uid)
        .set(privateData);
  }

  ///Function to add an userModel to collection of firestore. Returns true if username already taken, if not returns false.
  Future<bool> searchUsername({required String username}) async {
    final result = await cloudFunctions.httpsCallable('findUsername').call({
      "username": username,
    });
    Map<String, dynamic> response = result.data as Map<String, dynamic>;
    return response["result"];
  }

  ///Function for signing in an user
  Future<CustomResponse> signIn({
    required UserModel user,
    required String password,
  }) async {
    try {
      await firebaseAuthInstance.signInWithEmailAndPassword(
        email: user.mail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "invalid-credential":
          return CustomResponse(
            status: false,
            error: 'Email or password is incorrect',
          );
        case "wrong-password":
          return CustomResponse(
            status: false,
            error: 'Email or password is incorrect',
          );
        case "user-not-found":
          return CustomResponse(
            status: false,
            error: 'Email or password is incorrect',
          );
        case "invalid-email":
          return CustomResponse(
            status: false,
            error: 'Email or password is incorrect',
          );
        default:
          return CustomResponse(
            status: false,
            error: 'Something went wrong while signing in',
          );
      }
    }
    return await getCurrentUserPublicProfile();
  }

  ///Function to sign out current user
  Future<CustomResponse> signOut() async {
    try {
      await firebaseAuthInstance.signOut();
      return CustomResponse(status: true, data: "Successfully logged out");
    } catch (e) {
      return CustomResponse(status: false, error: e.toString());
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

  Future<CustomResponse> getUser({required String username}) async {
    if (await isLoggedIn()) {
      QuerySnapshot response = await userCollection
          .where("username", isEqualTo: username)
          .get();
      if (response.docs.isEmpty) {
        return CustomResponse(status: false, error: "User Not Found");
      }
      UserPublicProfileModel userPublicModel = UserPublicProfileModel.fromJson(
        response.docs[0].data() as Map<String, dynamic>,
      );
      return CustomResponse(status: true, data: userPublicModel);
    } else {
      return CustomResponse(status: false, error: "Not Logged in");
    }
  }

  Future<CustomResponse> getCurrentUserPublicProfile() async {
    if (await isLoggedIn()) {
      DocumentSnapshot userDoc = await userCollection
          .doc(firebaseAuthInstance.currentUser!.uid)
          .get();
      UserPublicProfileModel userPublicModel = UserPublicProfileModel.fromJson(
        userDoc.data() as Map<String, dynamic>,
      );
      return CustomResponse(status: true, data: userPublicModel);
    } else {
      return CustomResponse(status: false, error: "Not Logged in");
    }
  }

  Future<CustomResponse> getCurrentUserPrivateInfo() async {
    if (await isLoggedIn()) {
      DocumentSnapshot userDoc = await userCollection
          .doc(firebaseAuthInstance.currentUser!.uid)
          .get();
      QuerySnapshot userPrivateDoc = await userCollection
          .doc(userDoc.id)
          .collection("privateFields")
          .get();
      if (userPrivateDoc.docs.isEmpty) {
        return CustomResponse(
          status: false,
          error: "Private Information Not Found",
        );
      }
      QueryDocumentSnapshot userPrivateSnapshot = userPrivateDoc.docs[0];
      UserModel userPrivateModel = UserModel.fromJson(
        userPrivateSnapshot.data() as Map<String, dynamic>,
      );

      return CustomResponse(status: true, data: userPrivateModel);
    } else {
      return CustomResponse(status: false, error: "Not Logged in");
    }
  }

  resetPassword({required String email}) async {}
}

List<String> generateSearchKeywords(String username) {
  username = username.toLowerCase();
  List<String> keywords = [];
  for (int i = 1; i <= username.length; i++) {
    keywords.add(username.substring(0, i));
  }
  return keywords;
}
