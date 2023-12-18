import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiloi_sm/repos/medias/media.dart';
import 'package:kiloi_sm/repos/products/comments.dart';
import 'package:kiloi_sm/repos/products/product_repo_impl.dart';
import 'package:kiloi_sm/repos/products/products.dart';

mixin ProductRepo {
  static final ProductRepo _instance = ProductRepoImpl();

  static ProductRepo instance() {
    return _instance;
  }

  Future<DocumentReference> postProduct({required Product product});
  Future<DocumentReference> postComment({required Comment comment});
  Future<void> updateComment(
      {required String mediaDocId, required String docId});
  Stream<QuerySnapshot<Comment>> getMediaComments({required String docId});
  Future<QuerySnapshot<Comment>> loadMoreUserComments(
      {required Timestamp lastTime, required String docId});
  Stream<QuerySnapshot<Product>> getAdminProducts({required String id});
  Stream<QuerySnapshot<Product>> getUserProducts();
  Future<QuerySnapshot<Product>> loadMoreAdminProducts({
    required String id,
    required Timestamp lastTime,
  });
  Future<QuerySnapshot<Product>> loadMoreUserProducts({
    required Timestamp lastTime,
  });
}
