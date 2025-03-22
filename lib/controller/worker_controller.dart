import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dup/controller/session.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/worker_model.dart';

class WorkerController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Register Worker with Existing User UID
  Future<String?> registerWorker(String workerName, String jobTitle,
      String phone, String city, String description) async {
    try {
      // Get the currently logged-in user's UID
      User? user = _auth.currentUser;
      if (user == null) {
        return "User not logged in";
      }

      DocumentReference workerDocRef = _firestore.collection("workers").doc();
      String workerId = workerDocRef.id;

      Worker worker = Worker(
        uid: user.uid,
        workerName: workerName,
        jobTitle: jobTitle,
        wphone: phone,
        wcity: city,
        description: description,
      );

      await workerDocRef.set(worker.toMap());
      await _firestore.collection("users").doc(user.uid).set({
        'workerId': workerId,
        'isWorker': true,
      }, SetOptions(merge: true));

      await Session.saveWorker(workerId);

      return null;
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

      DocumentSnapshot workerDoc =
          await _firestore.collection("workers").doc(user.uid).get();

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
