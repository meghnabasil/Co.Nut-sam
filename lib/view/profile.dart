import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dup/controller/session.dart';
import 'package:dup/view/editprofile.dart';
import 'package:dup/model/user_model.dart';
import 'package:dup/view/venregistration.dart';
import 'package:dup/view/workerRegistration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "";
  String email = "";
  String profileImage = '';
  bool isVendor = false;
  bool isWorker = false;
  final ImagePicker _picker = ImagePicker();
  String? vendorAddress;
  List<String>? businessModel;
  String? businessName;
  String? businessType;
  String? city;
  String? vendorEmail;
  String? imageUrl;
  String? phone;
  String? productCategory;

  String? workerName;
  String? jobTitle;
  String? wphone;
  String? wcity;
  String? description;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        print("User Document Data: ${userDoc.data()}"); // Debugging

        UserModel userModel =
            UserModel.fromMap(userDoc.data() as Map<String, dynamic>);

        setState(() {
          name = userModel.name;
          email = userModel.email;
          profileImage = userModel.profileImage;
          isVendor = userModel.isVendor ?? false;
          isWorker = userModel.isWorker ?? false;
        });
        print('Is Vendor: $isVendor');

        if (isVendor) {
          Map<String, String?> vendorData = await Session.getVendor();
          String? vendorId = vendorData['vid']; // Get vendor ID from session

          if (vendorId != null && vendorId.isNotEmpty) {
            print("Vendor ID found: $vendorId");
            await _loadVendorDetails(vendorId);
          } else {
            print("Vendor ID not found in session");
          }
        }

        String? workerId = userDoc['workerId'];
        if (workerId != null && workerId.isNotEmpty) {
          print("Worker ID found: $workerId");
          await _loadWorkerDetails(workerId);
        }
      }
    }
  }

  Future<void> _loadWorkerDetails(String workerId) async {
    print("Fetching worker details for ID: $workerId");

    DocumentSnapshot workerDoc = await FirebaseFirestore.instance
        .collection("workers")
        .doc(workerId)
        .get();

    if (!workerDoc.exists) {
      print("Worker document does not exist!");
      return;
    }

    Map<String, dynamic> workerData = workerDoc.data() as Map<String, dynamic>;
    print("Worker Data: $workerData");

    setState(() {
      workerName = workerData['workerName'] ?? '';
      jobTitle = workerData['jobTitle'] ?? '';
      wphone = workerData['phone'] ?? '';
      wcity = workerData['city'] ?? '';
      description = workerData['description'] ?? '';
    });
  }

  Future<void> _loadVendorDetails(String vendorId) async {
    print("Fetching vendor details for ID: $vendorId");

    DocumentSnapshot vendorDoc = await FirebaseFirestore.instance
        .collection("vendors")
        .doc(vendorId)
        .get();

    if (!vendorDoc.exists) {
      print("Vendor document does not exist!");
      return;
    }

    Map<String, dynamic> vendorData = vendorDoc.data() as Map<String, dynamic>;
    print("Vendor Data: $vendorData"); // Debugging

    setState(() {
      vendorAddress = vendorData['address'] ?? '';
      businessModel = vendorData['businessModel'] != null
          ? List<String>.from(vendorData['businessModel'])
          : [];
      businessName = vendorData['businessName'] ?? '';
      businessType = vendorData['businessType'] ?? '';
      city = vendorData['city'] ?? '';
      vendorEmail = vendorData['email'] ?? '';
      imageUrl = vendorData['imageUrl'] ?? '';
      phone = vendorData['phone'] ?? '';
      productCategory = vendorData['productCategory'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: const Color(0xFF033015),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                    radius: 50,
                    backgroundImage: /*profileImage.isNotEmpty
                      ?*/
                        NetworkImage(profileImage)
                    // : AssetImage('assets/default_avatar.png') as ImageProvider,
                    ),
                const SizedBox(height: 20),
                Text(name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                Text(email, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Editprofile())),
                  child: const Text('Edit Profile'),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isVendor
                        ? "Active as Vendor"
                        : isWorker
                            ? "Active as Worker"
                            : "Hello Customers",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                ),
                const SizedBox(height: 20),
                if (isVendor)
                  Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Business Name: $businessName"),
                          Text("Business Type: $businessType"),
                          Text("City: $city"),
                          Text("Email: $vendorEmail"),
                          Text("Phone: $phone"),
                          Text("Product Category: $productCategory"),
                          Text("Business Model: ${businessModel?.join(', ')}"),
                          imageUrl != null
                              ? Image.network(imageUrl!,
                                  height: 100, width: 100)
                              : Text("No Image Available"),
                        ],
                      )),
                if (isWorker)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Worker Details",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("Full Name: $workerName"),
                        Text("Job Title: $jobTitle"),
                        Text("City: $wcity"),
                        Text("Phone: $wphone"),
                        Text("Discription: $description"),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Switch to Vendor"),
                    Switch(
                      value: isVendor,
                      onChanged: isVendor || isWorker
                          ? null
                          : (value) {
                              if (value)
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            VendorRegisterScreen()));
                            },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Switch to Worker"),
                    Switch(
                      value: isWorker,
                      onChanged: isWorker || isVendor
                          ? null
                          : (value) {
                              if (value)
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AddWorkerScreen(workerName: name )));
                            },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
