import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../controller/session.dart';
import '../view/bottomnav.dart';

class EditWorkerProfile extends StatefulWidget {
  EditWorkerProfile({Key? key, required String workerId}) : super(key: key);

  @override
  _EditWorkerProfileState createState() => _EditWorkerProfileState();
}

class _EditWorkerProfileState extends State<EditWorkerProfile> {
  late TextEditingController nameController;
  late TextEditingController jobTitleController;
  late TextEditingController cityController;
  late TextEditingController phoneController;
  late TextEditingController descriptionController;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? workerId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    nameController = TextEditingController();
    jobTitleController = TextEditingController();
    cityController = TextEditingController();
    phoneController = TextEditingController();
    descriptionController = TextEditingController();

    _loadWorkerData();
  }

  Future<void> _loadWorkerData() async {
    // Fetch worker ID from session
    Map<String, String?> workerData = await Session.getWorker();
    workerId = workerData['workerId'];

    if (workerId == null || workerId!.isEmpty) {
      print("No worker ID found in session.");
      setState(() => isLoading = false);
      return;
    }

    await _loadWorkerDetails(workerId!);
  }

  Future<void> _loadWorkerDetails(String workerId) async {
    print("Fetching worker details for ID: $workerId");

    try {
      DocumentSnapshot workerDoc =
      await _firestore.collection("workers").doc(workerId).get();

      if (!workerDoc.exists) {
        print("Worker document does not exist!");
        setState(() => isLoading = false);
        return;
      }

      Map<String, dynamic> workerData =
      workerDoc.data() as Map<String, dynamic>;
      print("Worker Data: $workerData");

      setState(() {
        nameController.text = workerData['name'] ?? '';
        jobTitleController.text = workerData['jobTitle'] ?? '';
        cityController.text = workerData['city'] ?? '';
        phoneController.text = workerData['phone'] ?? '';
        descriptionController.text = workerData['description'] ?? '';

        isLoading = false;
      });
    } catch (e) {
      print("Error fetching worker details: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Worker Profile")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Full Name"),
            ),
            TextField(
              controller: jobTitleController,
              decoration: InputDecoration(labelText: "Job Title"),
            ),
            TextField(
              controller: cityController,
              decoration: InputDecoration(labelText: "City"),
            ),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: "Phone"),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: "Description"),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _firestore
                          .collection("workers")
                          .doc(workerId)
                          .update({
                        "name": nameController.text,
                        "jobTitle": jobTitleController.text,
                        "city": cityController.text,
                        "phone": phoneController.text,
                        "description": descriptionController.text,
                      });

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BottomBarScreen(initialIndex: 4),
                        ),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Worker Profile Updated")),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to update: $e")),
                      );
                    }
                  },
                  child: Text("Save"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    jobTitleController.dispose();
    cityController.dispose();
    phoneController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}