import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/products_model.dart';

class ProductController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addProduct(Product product) async {
    try {
      await _firestore.collection('products').add(product.toMap());
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').snapshots().map(
          (snapshot) =>
          snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(),
    );
  }
}