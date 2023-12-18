import 'package:cloud_firestore/cloud_firestore.dart';

class UserContent {
  final String? token;
  final String? name;
  final String? email;
  final bool? isAdmin;

  UserContent({
    this.token,
    this.name,
    this.email,
    this.isAdmin,
  });

  factory UserContent.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return UserContent(
        token: data?['id'],
        name: data?['name'],
        email: data?['email'],
        isAdmin: data?["isAdmin"]);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (token != null) "id": token,
      if (name != null) "name": name,
      if (email != null) "email": email,
      if (email != null) "isAdmin": isAdmin,
    };
  }

  factory UserContent.fromJson(
    Map<String, dynamic> data,
  ) {
    return UserContent(
        token: data['id'],
        name: data['name'],
        email: data['email'],
        isAdmin: data["isAdmin"]);
  }
}
