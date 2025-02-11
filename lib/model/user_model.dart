class UserModel {
  String uid;
  String name;
  String email;

  UserModel({required this.uid, required this.name, required this.email});

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
    };
  }

  // Create UserModel from Firestore data
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
