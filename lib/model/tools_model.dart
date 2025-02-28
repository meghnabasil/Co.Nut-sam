import 'package:cloud_firestore/cloud_firestore.dart';

class Tool {
  String id;
  String name;
  String company;
  String price;
  String description;
  String category;
  List<String> imageUrls;
  String vendorId;

  Tool({
    required this.id,
    required this.name,
    required this.company,
    required this.price,
    required this.description,
    required this.category,
    required this.imageUrls,
    required this.vendorId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'company': company,
      'price': price,
      'description': description,
      'category': category,
      'imageUrls': imageUrls,
      'vendorId': vendorId,
    };
  }

  factory Tool.fromMap(String id, Map<String, dynamic> data) {
    return Tool(
      id: id,
      name: data['name'],
      company: data['company'],
      price: data['price'],
      description: data['description'],
      category: data['category'],
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      vendorId: data['vendorId'],
    );
  }
}