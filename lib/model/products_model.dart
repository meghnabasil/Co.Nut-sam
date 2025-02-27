import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String vendorId;  // New field for vendor association
  final String name;
  final String company;
  final double price;
  final String category;
  final String description;
  final List<String> imageUrls;
  final Timestamp timestamp;

  Product({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.company,
    required this.price,
    required this.category,
    required this.description,
    required this.imageUrls,
    required this.timestamp,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      vendorId: data['vendorId'] ?? '',
      name: data['name'] ?? '',
      company: data['company'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vendorId': vendorId,
      'name': name,
      'company': company,
      'price': price,
      'category': category,
      'description': description,
      'imageUrls': imageUrls,
      'timestamp': timestamp,
    };
  }
}
