
import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  String productId;
  String productName;
  double price;
  String imageUrl;
  int quantity;
  DateTime addedAt;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    required this.addedAt,
  });

  // Method to create a CartItem instance from Firestore document data
  factory CartItem.fromFirestore(Map<String, dynamic> data, String productId) {
    return CartItem(
      productId: productId,
      productName: data['productName'] ?? '',
      price: data['price']?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] ?? '',
      quantity: data['quantity'] ?? 1,
      addedAt: (data['addedAt'] as Timestamp).toDate(),
    );
  }

  // Method to convert a CartItem instance into a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'addedAt': FieldValue.serverTimestamp(),
    };
  }
}
