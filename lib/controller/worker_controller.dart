import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/worker_model.dart';

class WorkerController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// **Register the logged-in user as a worker**
  Future<String?> registerWorker(String jobTitle, String description,
      String city, String phone) async {
    try {
      // Get the logged-in user's details
      User? user = _auth.currentUser;
      if (user == null) {
        return "User not logged in";
      }

      Worker worker = Worker(
        uid: user.uid,
        // Use the same Firebase UID
        workerName: user.displayName ?? '',
        // Fetch user name
        phone: phone,
        jobTitle: jobTitle,
        description: description,
        city: city,
      );

      // Store worker details in Firestore under the user's UID
      await _firestore.collection('workers').add(worker.toMap());

      return null; // Success
    } catch (e) {
      return e.toString(); // Return error message
    }
  }
}
