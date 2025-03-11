import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/cart_model.dart';


class CartController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addToCart(CartItem item) async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    String uid = user.uid;
    CollectionReference cartCollection =
    _firestore.collection('users').doc(uid).collection('cart');

    await cartCollection.doc(item.productId).set(item.toMap());
  }

  Future<void> removeFromCart(String productId) async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    String uid = user.uid;
    CollectionReference cartCollection =
    _firestore.collection('users').doc(uid).collection('cart');

    await cartCollection.doc(productId).delete();
  }

  Stream<List<CartItem>> getCartItems() {
    final User? user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    String uid = user.uid;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => CartItem.fromMap(doc.data(), doc.id)).toList());
  }
}
