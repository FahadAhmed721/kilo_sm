import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String? id;
  String? title;
  String? category;
  String? price;
  String? image;
  final Timestamp? addtime;

  Product(
      {this.id,
      this.category,
      this.image,
      this.price,
      this.addtime,
      this.title});

  factory Product.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Product(
        id: data?['id'],
        category: data?['category'],
        image: data?['image'],
        addtime: data?['addtime'],
        price: data?['price'],
        title: data?["title"]);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) "id": id,
      if (category != null) "category": category,
      if (image != null) "image": image,
      if (price != null) "price": price,
      if (title != null) "title": title,
      if (addtime != null) "addtime": addtime,
    };
  }
}
