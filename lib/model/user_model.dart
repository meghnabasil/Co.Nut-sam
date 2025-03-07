class UserModel {
  final String uid;
  final String name;
  final String email;
  final String profileImage =
      'https://firebasestorage.googleapis.com/v0/b/dup-a79d6.firebasestorage.app/o/user.jpg?alt=media&token=6cfb58c0-60cd-4a5d-b77c-b5a37f5dc1f8';
  final String password;
  final bool isVendor;
  final bool isWorker;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.password,
    this.isVendor = false,
    this.isWorker = false,
    profileImage,
  });

  // Convert UserModel to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'password': password,
      'isVendor': isVendor,
      'isWorker': isWorker,
      'userImage': profileImage,
    };
  }

  // Convert Firestore document to UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profileImage: map['userImage'] ?? '',
      password: map['password'] ?? '',
      isVendor: map['isVendor'] ?? false,
      isWorker: map['isWorker'] ?? false,
    );
  }

  // Convert UserModel to JSON (for API)
  Map<String, dynamic> toJson() => toMap();

  // Convert JSON to UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel.fromMap(json);

  // Copy method to create a modified instance
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? profileImage,
    String? password,
    bool? isVendor,
    bool? isWorker,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      isVendor: isVendor ?? this.isVendor,
      isWorker: isWorker ?? this.isWorker,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
