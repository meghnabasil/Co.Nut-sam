import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/vendor_model.dart';

class VendorController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Register Vendor with Existing User UID
  Future<String?> registerVendor(String businessName, String phone,
      String address,
      String city, String businessType, String productCategory,
      List<String> businessModel) async {
    try {
      // Get the currently logged-in user's UID
      User? user = _auth.currentUser;
      if (user == null) {
        return "User not logged in";
      }

      Vendor vendor = Vendor(
        uid: user.uid,
        // Using the same user ID
        businessName: businessName,
        email: user.email!,
        phone: phone,
        address: address,
        city: city,
        businessType: businessType,
        productCategory: productCategory,
        businessModel: businessModel,
      );

      await _firestore.collection("vendors").add(vendor.toMap());

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    }
  }

  /// Fetch Vendor Details
  Future<Vendor?> fetchVendorDetails() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return null;
      }

      DocumentSnapshot vendorDoc =
      await _firestore.collection("vendors").doc(user.uid).get();

      if (vendorDoc.exists) {
        return Vendor.fromMap(vendorDoc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching vendor details: $e");
      return null;
    }
  }
}
