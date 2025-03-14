

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/cart_model.dart';


class CartController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add item to cart
  Future<void> addToCart(CartItem cartItem) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        print("User not logged in");
        return;
      }

      String uid = user.uid;
      CollectionReference cartCollection = _firestore
          .collection('users')
          .doc(uid)
          .collection('cart');

      // Check if the item already exists in the cart
      DocumentSnapshot docSnapshot = await cartCollection.doc(cartItem.productId).get();
      if (docSnapshot.exists) {
        // If it exists, update the quantity
        await cartCollection.doc(cartItem.productId).update({
          'quantity': cartItem.quantity,
        });
      } else {
        // If it doesn't exist, add it to the cart
        await cartCollection.doc(cartItem.productId).set(cartItem.toMap());
      }
      print("Product added to cart");
    } catch (e) {
      print("Error adding to cart: $e");
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String productId) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        print("User not logged in");
        return;
      }

      String uid = user.uid;
      CollectionReference cartCollection = _firestore
          .collection('users')
          .doc(uid)
          .collection('cart');

      await cartCollection.doc(productId).delete();
      print("Product removed from cart");
    } catch (e) {
      print("Error removing from cart: $e");
    }
  }

  // Get all items in the cart
  Future<List<CartItem>> getCartItems() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        print("User not logged in");
        return [];
      }

      String uid = user.uid;
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('cart')
          .get();

      List<CartItem> cartItems = [];
      snapshot.docs.forEach((doc) {
        CartItem cartItem = CartItem.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
        cartItems.add(cartItem);
      });

      return cartItems;
    } catch (e) {
      print("Error fetching cart items: $e");
      return [];
    }
  }

  // Update the quantity of a cart item
  Future<void> updateQuantity(String productId, int newQuantity) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        print("User not logged in");
        return;
      }

      String uid = user.uid;
      CollectionReference cartCollection = _firestore
          .collection('users')
          .doc(uid)
          .collection('cart');

      await cartCollection.doc(productId).update({
        'quantity': newQuantity,
      });
      print("Cart item quantity updated");
    } catch (e) {
      print("Error updating quantity: $e");
    }
  }

  // Update the quantity of an existing cart item
  Future<void> updateCartItem(CartItem cartItem) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    String uid = user.uid;
    CollectionReference cartCollection =
    _firestore.collection('users').doc(uid).collection('cart');

    // Update the quantity and timestamp of the cart item
    await cartCollection.doc(cartItem.productId).update({
      'quantity': cartItem.quantity,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
