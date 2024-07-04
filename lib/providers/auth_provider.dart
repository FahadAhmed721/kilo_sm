import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kiloi_sm/main.dart';
import 'package:kiloi_sm/repos/user/user.dart';
import 'package:kiloi_sm/repos/user/user_repo.dart';
import 'package:kiloi_sm/services/storage.dart';
import 'package:kiloi_sm/store/user_storage.dart';
import 'package:kiloi_sm/utils/local_db_keys.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String? _accessToken;
  UserRepo userRepo = UserRepo.instance();

  UserContent get getUserContent {
    return UserStorage.instance().getUserContent;
  }

  // bool get isAuth {
  //   return _accessToken != null;
  // }

  String get accessToken {
    return _accessToken!;
  }

  String get userToken {
    return UserStorage.instance().accessToken;
  }

  Future<bool> signUpWithEmailAndPassword(
      {required String email,
      required String password,
      required String name,
      required bool isAdmin}) async {
    try {
      await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((userCredential) async {
        _accessToken = userCredential.user!.uid;
        UserContent userContent = UserContent(
            email: email, name: name, token: _accessToken, isAdmin: isAdmin);
        await userRepo.posetUser(userContent: userContent);
        await UserStorage.instance().saveProfile(userContent);
        if (!isAdmin) {
          FirebaseMessaging.instance.subscribeToTopic('notifications');
        }
        // kPrint("user is ${getUserContent.email}");
      });
      notifyListeners();

      return _accessToken != null;
    } on FirebaseAuthException catch (error) {
      kPrint("Firebase Auth Exception ${error.message ?? ""}");
    }

    return _accessToken != null;
  }

  Future<bool> signInWithEmailAndPassword(
      {required String email,
      required String password,
      required bool isAdmin}) async {
    try {
      await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((userCredential) async {
        // _accessToken = userCredential.user!.uid;
        await saveLocalData(userCredential.user!.uid, isAdmin);
        if (!isAdmin) {
          FirebaseMessaging.instance.subscribeToTopic('notifications');
        }
      });
      notifyListeners();

      return _accessToken != null;
    } on FirebaseAuthException catch (error) {
      kPrint(error.message ?? "");
      return _accessToken == null;
    }

    // return _accessToken != null;
  }

  saveLocalData(String userId, bool isAdmin) async {
    try {
      UserContent userContent = UserContent(token: userId, isAdmin: isAdmin);
      await userRepo.getUser(userContent: userContent).then((value) async {
        userContent = value.docs.first.data();

        /// This logic will run if user login as an admin or if admin login as a user
        if (userContent.isAdmin != isAdmin) {
          kPrint("Invalid user");

          return;
        }
        _accessToken = userId;
        kPrint("access token $_accessToken");
        await UserStorage.instance().saveProfile(userContent);
        notifyListeners();
      });
    } on FirebaseException catch (error) {
      kPrint("error is ${error.message}");
    }
  }

  Future<bool> getLocalData() async {
    if (!StorageService().preferense().containsKey(STORAGE_USER_PROFILE_KEY)) {
      return false;
    }
    String userData = StorageService().getString(STORAGE_USER_PROFILE_KEY);
    if (userData.isNotEmpty) {
      UserContent userContent = UserContent.fromJson(json.decode(userData));
      UserStorage.instance().saveProfileFromLocal(userContent);
      kPrint("userData is ${userData}");

      return true;
    }

    return false;
  }

  Future<void> logOut() async {
    kPrint("before logout $userToken");
    await UserStorage.instance().clearData();
    _accessToken = null;
    await FirebaseAuth.instance.signOut();
    FirebaseMessaging.instance.unsubscribeFromTopic("notifications");
    notifyListeners();
    kPrint("after logout $userToken");
    // notifyListeners();
  }
}
