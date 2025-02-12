import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/vendor_model.dart';

class VendorController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Register Vendor with Existing User UID
  Future<String?> registerVendor(String businessName, String phone, String address,
      String city, String businessType, String productCategory, List<String> businessModel) async {
    try {
      // Get the currently logged-in user's UID
      User? user = _auth.currentUser;
      if (user == null) {
        return "User not logged in";
      }

      Vendor vendor = Vendor(
        uid: user.uid, // Using the same user ID
        businessName: businessName,
        email: user.email!,
        phone: phone,
        address: address,
         city: city,
        businessType: businessType,
        productCategory: productCategory,
        businessModel: businessModel,
      );

      await _firestore.collection("vendors").doc(user.uid).set(vendor.toMap());

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    }
  }
}
