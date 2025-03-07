class Worker {
  String uid; // Add the UID field
  String workerName;
  String jobTitle;
  String wphone;
  String wcity;
  String description;

  Worker({
    required this.uid, // Ensure UID is required
    required this.workerName,
    required this.jobTitle,
    required this.wphone,
    required this.wcity,
    required this.description,
  });

  // Convert Worker object to Map (for Firebase)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid, // Store UID in Firestore
      'workerName': workerName,
      'jobTitle': jobTitle,
      'phone': wphone,
      'city': wcity,
      'description': description,
    };
  }

  // Create Worker object from Firebase document
  factory Worker.fromMap(Map<String, dynamic> map) {
    return Worker(
        uid: map['uid'] ?? '', // Provide default value
        workerName: map['workerName'] ?? 'Unknown',
        jobTitle: map['jobTitle'] ?? 'Unknown',
        wphone: map['phone'] ?? 'Unknown',
        wcity: map['city'] ?? 'Unknown',
        description: map['description'] ?? 'No description',
    );
  }
}
