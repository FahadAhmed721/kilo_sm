import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiloi_sm/repos/user/user.dart';
import 'package:kiloi_sm/repos/user/user_repo_impl.dart';

mixin UserRepo {
  static final UserRepo _instance = UserRepoImpl();

  static UserRepo instance() {
    return _instance;
  }

  Future<DocumentReference> posetUser({required UserContent userContent});

  Future<QuerySnapshot<UserContent>> getUser(
      {required UserContent userContent});
}
