import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  String id;
  String serviceName;
  String companyName;
  double price;
  int quantity;
  String unit;
  String pickupDate;
  String returnDate;
  String fullName;
  String mobileNumber;
  String district;
  String townCity;
  String pincode;
  String area;
  String buildingDetails;
  String landmark;
  String userId;
  // Vendor details added
  String vendorId;
  // String vendorName;
  Timestamp createdAt;

  Booking({
    this.id = '',
    required this.serviceName,
    required this.companyName,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.pickupDate,
    required this.returnDate,
    required this.fullName,
    required this.mobileNumber,
    required this.district,
    required this.townCity,
    required this.pincode,
    required this.area,
    required this.buildingDetails,
    required this.landmark,
    required this.userId,
    required this.vendorId,
   // required this.vendorName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'serviceName': serviceName,
      'companyName': companyName,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'pickupDate': pickupDate,
      'returnDate': returnDate,
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      'district': district,
      'townCity': townCity,
      'pincode': pincode,
      'area': area,
      'buildingDetails': buildingDetails,
      'landmark': landmark,
      'userId': userId,
      'vendorId': vendorId,
      // 'vendorName': vendorName,
      'createdAt': createdAt,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map, String id) {
    return Booking(
      id: id,
      serviceName: map['serviceName'],
      companyName: map['companyName'],
      price: map['price'],
      quantity: map['quantity'],
      unit: map['unit'],
      pickupDate: map['pickupDate'],
      returnDate: map['returnDate'],
      fullName: map['fullName'],
      mobileNumber: map['mobileNumber'],
      district: map['district'],
      townCity: map['townCity'],
      pincode: map['pincode'],
      area: map['area'],
      buildingDetails: map['buildingDetails'],
      landmark: map['landmark'],
      userId: map['userId'],
      vendorId: map['vendorId'],
      // vendorName: map['vendorName'],
      createdAt: map['createdAt'],
    );
  }
}
