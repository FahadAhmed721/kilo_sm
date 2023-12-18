import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiloi_sm/repos/products/comments.dart';
import 'package:kiloi_sm/repos/products/product_repo.dart';
import 'package:kiloi_sm/repos/products/products.dart';

class ProductRepoImpl implements ProductRepo {
  static String productTable = "products";
  static String commentsTable = "comments";
  static String mediaTable = "media";
  final db = FirebaseFirestore.instance;

  @override
  Future<DocumentReference<Object?>> postProduct(
      {required Product product}) async {
    DocumentReference? newDoc;
    await db
        .collection(productTable)
        .withConverter(
            fromFirestore: Product.fromFirestore,
            toFirestore: (product, option) => product.toFirestore())
        .add(product)
        .then((value) {
      newDoc = value;
    });
    return newDoc!;
  }

  @override
  Stream<QuerySnapshot<Product>> getAdminProducts({required String id}) {
    return db
        .collection(productTable)
        .where("id", isEqualTo: id)
        .withConverter(
            fromFirestore: Product.fromFirestore,
            toFirestore: (product, option) => product.toFirestore())
        .orderBy("addtime", descending: true)
        .limit(15)
        .snapshots();
  }

  @override
  Stream<QuerySnapshot<Product>> getUserProducts() {
    return db
        .collection(productTable)
        .withConverter(
            fromFirestore: Product.fromFirestore,
            toFirestore: (product, option) => product.toFirestore())
        .orderBy("addtime", descending: true)
        .limit(15)
        .snapshots();
  }

  @override
  Future<QuerySnapshot<Product>> loadMoreAdminProducts(
      {required String id, required Timestamp lastTime}) async {
    final products = await db
        .collection(productTable)
        .where('id', isEqualTo: id)
        .where("addtime", isLessThan: lastTime)
        .withConverter(
            fromFirestore: Product.fromFirestore,
            toFirestore: (product, option) => product.toFirestore())
        .orderBy("addtime", descending: true)
        .limit(15)
        .get();
    return products;
  }

  @override
  Future<QuerySnapshot<Product>> loadMoreUserProducts(
      {required Timestamp lastTime}) async {
    final products = await db
        .collection(productTable)
        .where("addtime", isLessThan: lastTime)
        .withConverter(
            fromFirestore: Product.fromFirestore,
            toFirestore: (product, option) => product.toFirestore())
        .orderBy("addtime", descending: true)
        .limit(15)
        .get();
    return products;
  }

  @override
  Future<DocumentReference<Object?>> postComment(
      {required Comment comment}) async {
    DocumentReference? newDoc;
    await db
        .collection(mediaTable)
        .doc(comment.docId)
        .collection(commentsTable)
        .withConverter(
            fromFirestore: Comment.fromFirestore,
            toFirestore: (cmnt, option) => cmnt.toFirestore())
        .add(comment)
        .then((value) {
      newDoc = value;
    });
    return newDoc!;
  }

  @override
  Stream<QuerySnapshot<Comment>> getMediaComments({required String docId}) {
    return db
        .collection(mediaTable)
        .doc(docId)
        .collection(commentsTable)
        .withConverter(
            fromFirestore: Comment.fromFirestore,
            toFirestore: (cmnt, option) => cmnt.toFirestore())
        .orderBy("addtime", descending: true)
        .limit(20)
        .snapshots();
  }

  @override
  Future<QuerySnapshot<Comment>> loadMoreUserComments(
      {required Timestamp lastTime, required String docId}) async {
    return await db
        .collection(mediaTable)
        .doc(docId)
        .collection(commentsTable)
        .where("addtime", isLessThan: lastTime)
        .withConverter(
            fromFirestore: Comment.fromFirestore,
            toFirestore: (cmnt, option) => cmnt.toFirestore())
        .orderBy("addtime", descending: true)
        .limit(20)
        .get();
  }

  @override
  Future<void> updateComment(
      {required String mediaDocId, required String docId}) async {
    await db
        .collection(mediaTable)
        .doc(mediaDocId)
        .collection(commentsTable)
        .doc(docId)
        // .withConverter(
        //     fromFirestore: Comment.fromFirestore,
        //     toFirestore: (media, option) => media.toFirestore())
        .update({"docId": docId});
  }
}
