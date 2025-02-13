import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/user_model.dart';
import 'package:dup/controller/session.dart';


class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register User
  Future<String?> registerUser(String name, String email,
      String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel user = UserModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        password: password,
      );

      await _firestore.collection("users").doc(user.uid).set(user.toMap());

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    }
  }


//login
  Future<String?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );


      String userId = userCredential.user!.uid;

      DocumentSnapshot userDoc = await _firestore.collection("users").doc(
          userCredential.user!.uid).get();


      if (!userDoc.exists) {
        return "User not found"; // Prevents unauthorized logins
      }
      await Session.saveSession(email, userId);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    }
  }
}
