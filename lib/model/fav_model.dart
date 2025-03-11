import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteModel {
  String id;
  String name;
  String imageUrl;
  double price;

  FavoriteModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
  });

  // Convert Firestore document to FavoriteModel
  factory FavoriteModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!;
    return FavoriteModel(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
    );
  }

  // Convert model to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
    };
  }
}
