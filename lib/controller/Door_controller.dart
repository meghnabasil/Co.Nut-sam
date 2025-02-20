import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dup/controller/session.dart';
import 'package:dup/controller/vendor_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/Doorstep_model.dart';

class DoorstepDeliveryController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<String?> getSessionVendorId() async {
    Map<String, String?> vendorData = await Session.getVendor();
    return vendorData['vid'];
  }
  /// **Fetch Vendor ID from Firestore**
 /* Future<String?> getVendorId() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return null; // User not logged in
      }

      // Fetch vendor document where the userId matches
      DocumentSnapshot vendorSnapshot = await _firestore
          .collection("vendors")
          .doc(user.uid) // Assuming vendor ID is stored with the user ID as the document ID
          .get();

      if (vendorSnapshot.exists) {
        return vendorSnapshot.get("vendorId"); // Get the vendorId field
      } else {
        return null; // Vendor not found
      }
    } catch (e) {
      print("Error fetching vendor ID: $e");
      return null;
    }
  }*/




  /// **Add Doorstep Delivery Details**
  Future<String?> addDoorstepDelivery(
      String companyName,
      String phone,
      String address,
      String city,
      String deliveryArea,
      String processingType,
      double price,
      String details,
      )async {
    try {
      String? vendorId = await getSessionVendorId();
      if (vendorId == null) {
        return "Vendor ID not found";
      }
      DocumentReference docRef = _firestore.collection("doorstep_deliveries").doc();

      DoorstepDelivery delivery = DoorstepDelivery(
        vid: vendorId,
        companyName: companyName,
        phone: phone,
        address: address,
        city: city,
        deliveryArea: deliveryArea,
        processingType: processingType,
        price: price,
        details: details,
      );

      await docRef.set(delivery.toMap());

      return null; // Success
    } on FirebaseException catch (e) {
      return "Error: ${e.message}";
    } catch (e) {
      return "Unexpected Error: $e";
    }
  }

  /// **Fetch Doorstep Delivery Details Using Vendor ID**
  Future<List<DoorstepDelivery>> fetchDoorstepDeliveries() async {
    try {
      String? vendorId = await getSessionVendorId();
      if (vendorId == null) {
        print("Vendor ID not found");
        return [];
      }

      QuerySnapshot snapshot = await _firestore
          .collection("doorstep_deliveries")
          .where("vid", isEqualTo: vendorId) // Fetch based on vendorId
          .get();

      return snapshot.docs
          .map((doc) => DoorstepDelivery.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print("Error fetching deliveries: $e");
      return [];
    }
  }
}