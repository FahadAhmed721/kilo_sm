import 'dart:convert';

import 'package:kiloi_sm/main.dart';
import 'package:kiloi_sm/repos/user/user.dart';
import 'package:kiloi_sm/services/storage.dart';
import 'package:kiloi_sm/utils/local_db_keys.dart';

class UserStorage {
  static final UserStorage _instance = UserStorage._internal();

  UserStorage._internal();

  static UserStorage instance() => _instance;
  UserContent? userContent = UserContent();
  // UserStorage({this.userContent});
  String token = '';
  UserContent get getUserContent {
    return userContent!;
  }

  String get accessToken {
    return token;
  }

  // 保存 profile
  Future<void> saveProfile(UserContent profile) async {
    // _isLogin.value = true;
    StorageService()
        .setString(STORAGE_USER_PROFILE_KEY, jsonEncode(profile.toFirestore()));
    userContent = profile;

    setToken(profile.token!);
    print("profile token is ${getUserContent.email} ${profile.token!}");
  }

  void saveProfileFromLocal(UserContent profile) {
    userContent = profile;
    token = profile.token ?? "";
  }

  // 保存 token
  Future<void> setToken(String value) async {
    await StorageService().setString(STORAGE_USER_TOKEN_KEY, value);
    token = value;
  }

  clearData() async {
    token = "";
    userContent = null;
    bool userToken = await StorageService().remove(STORAGE_USER_TOKEN_KEY);
    bool user = await StorageService().remove(STORAGE_USER_PROFILE_KEY);
    kPrint("shared data $user $userToken");
    // await StorageService().clear();
  }

  // static UserStorage instance() {
  //   return UserStorage();
  // }
}
