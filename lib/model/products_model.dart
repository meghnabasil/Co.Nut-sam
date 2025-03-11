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



  // New Fields
  final bool isSubscriptionAvailable;
  final String? subscriptionDuration;
  final String? deliveryFrequency;
  final double? subscriptionPrice;
  final int? subscriptionQuantity;

  final bool isExportingAvailable;
  final String? exportCountry;
  final double? shippingCost;
  final int? exportQuantity;



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


    this.isSubscriptionAvailable = false,
    this.subscriptionDuration,
    this.deliveryFrequency,
    this.subscriptionPrice,
    this.subscriptionQuantity,
    this.isExportingAvailable = false,
    this.exportCountry,
    this.shippingCost,
    this.exportQuantity,
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



      isSubscriptionAvailable: data['subscription'] ?? false,
      subscriptionDuration: data['subscriptionDuration'],
      deliveryFrequency: data['deliveryFrequency'],
      subscriptionPrice: (data['subscriptionPrice'] ?? 0).toDouble(),
      subscriptionQuantity: data['subscriptionQuantity'],
      isExportingAvailable: data['exporting'] ?? false,
      exportCountry: data['exportCountry'],
      shippingCost: (data['shippingCost'] ?? 0).toDouble(),
      exportQuantity: data['exportQuantity'],
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

      'subscription': isSubscriptionAvailable,
      'subscriptionDuration': subscriptionDuration,
      'deliveryFrequency': deliveryFrequency,
      'subscriptionPrice': subscriptionPrice,
      'subscriptionQuantity': subscriptionQuantity,
      'exporting': isExportingAvailable,
      'exportCountry': exportCountry,
      'shippingCost': shippingCost,
      'exportQuantity': exportQuantity,
    };
  }
}
