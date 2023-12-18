import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiloi_sm/repos/user/user.dart';
import 'package:kiloi_sm/repos/user/user_repo.dart';

class UserRepoImpl implements UserRepo {
  static String userTable = "user";
  final db = FirebaseFirestore.instance;
  @override
  Future<DocumentReference> posetUser(
      {required UserContent userContent}) async {
    DocumentReference? newDoc;
    await db
        .collection(userTable)
        .withConverter(
            fromFirestore: UserContent.fromFirestore,
            toFirestore: (msgData, option) => userContent.toFirestore())
        .add(userContent)
        .then((value) {
      newDoc = value;
    });
    return newDoc!;
  }

  @override
  Future<QuerySnapshot<UserContent>> getUser(
      {required UserContent userContent}) async {
    // TODO: implement getUser
    return await db
        .collection(userTable)
        .where("id", isEqualTo: userContent.token)
        .withConverter(
            fromFirestore: UserContent.fromFirestore,
            toFirestore: (msgData, option) => userContent.toFirestore())
        .get();
  }
}
