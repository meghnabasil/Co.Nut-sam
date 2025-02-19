import 'package:cloud_firestore/cloud_firestore.dart';

class DoorstepDelivery {
  String vid; // Vendor/User ID
  String companyName;
  String phone;
  String address;
  String city;
  String deliveryArea;
  String processingType;
  double price;
  String details;

  DoorstepDelivery({
    required this.vid,
    required this.companyName,
    required this.phone,
    required this.address,
    required this.city,
    required this.deliveryArea,
    required this.processingType,
    required this.price,
    required this.details,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': vid,
      'companyName': companyName,
      'phone': phone,
      'address': address,
      'city': city,
      'deliveryArea': deliveryArea,
      'processingType': processingType,
      'price': price,
      'details': details,
    };
  }

  // Convert Firestore document to object
  factory DoorstepDelivery.fromMap(Map<String, dynamic> map, String documentId) {
    return DoorstepDelivery(
      vid: map['uid'],
      companyName: map['companyName'],
      phone: map['phone'],
      address: map['address'],
      city: map['city'],
      deliveryArea: map['deliveryArea'],
      processingType: map['processingType'],
      price: (map['price'] as num).toDouble(),
      details: map['details'],
    );
  }
}
