import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/worker_model.dart';

class WorkerController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Register Worker with Existing User UID
  Future<String?> registerWorker(String workerName, String jobTitle, String phone, String city, String description) async {
    try {
      // Get the currently logged-in user's UID
      User? user = _auth.currentUser;
      if (user == null) {
        return "User not logged in";
      }

      Worker worker = Worker(
        uid: user.uid, // Using the same user ID
        workerName: workerName,
        jobTitle: jobTitle,
        phone: phone,
        city: city,
        description: description,
      );
/*
      await _firestore.collection("vendors").doc(vendorId).set(vendor.toMap());

      await _firestore.collection("users").doc(vendorId).update({
        'vendorId': vendorId,
        'isVendor': true,
      });*/

      await _firestore.collection("workers").add(worker.toMap());

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    }
  }

  Future<Worker?> fetchWorkerData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return null;
      }

      DocumentSnapshot workerDoc = await _firestore.collection("workers").doc(user.uid).get();

      if (workerDoc.exists) {
        return Worker.fromMap(workerDoc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Error fetching worker data: $e");
      return null;
    }
  }
}


