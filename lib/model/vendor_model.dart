class Vendor {
  String uid; // Add the UID field
  String businessName;
  String email;
  String phone;
  String address;
  String city;
  String businessType;
  String productCategory;
  List<String> businessModel;

  Vendor({
    required this.uid,  // Ensure UID is required
    required this.businessName,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.businessType,
    required this.productCategory,
    required this.businessModel,
  });

  // Convert Vendor object to Map (for Firebase)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid, // Store UID in Firestore
      'businessName': businessName,
      'email': email,
      'phone': phone,
      'address': address,
      'city':city,
      'businessType': businessType,
      'productCategory': productCategory,
      'businessModel': businessModel,
    };
  }

  // Create Vendor object from Firebase document
  factory Vendor.fromMap(Map<String, dynamic> map) {
    return Vendor(
      uid: map['uid'], // Retrieve UID
      businessName: map['businessName'],
      email: map['email'],
      phone: map['phone'],
      address: map['address'],
      city:map['city'],
      businessType: map['businessType'],
      productCategory: map['productCategory'],
      businessModel: List<String>.from(map['businessModel']),
    );
  }
}
