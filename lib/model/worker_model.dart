class Worker {
  String uid; // Add the UID field
  String workerName;
  String jobTitle;
  String phone;
  String city;
  String description;

  Worker({
    required this.uid, // Ensure UID is required
    required this.workerName,
    required this.jobTitle,
    required this.phone,
    required this.city,
    required this.description,
  });

  // Convert Worker object to Map (for Firebase)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid, // Store UID in Firestore
      'workerName': workerName,
      'jobTitle': jobTitle,
      'phone': phone,
      'city': city,
      'description': description,
    };
  }

  // Create Worker object from Firebase document
  factory Worker.fromMap(Map<String, dynamic> map) {
    return Worker(
      uid: map['uid'], // Retrieve UID
      workerName: map['workerName'],
      jobTitle: map['jobTitle'],
      phone: map['phone'],
      city: map['city'],
      description: map['description'],
    );
  }
}
