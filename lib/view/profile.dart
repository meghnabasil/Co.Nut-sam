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

import 'UserProfile_Edit.dart';

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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _editVendorProfile(Map<String, dynamic> data) async {


    Map<String, String?> vendorData = await Session.getVendor();
    String? vendorId = vendorData['vid'];

    if (vendorId == null || vendorId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Vendor ID is missing")));
      return;
    }

    TextEditingController businessNameController =
        TextEditingController(text: data['businessName']);
    TextEditingController businessTypeController =
        TextEditingController(text: data['businessType']);
    TextEditingController cityController =
        TextEditingController(text: data['city']);
    TextEditingController emailController =
        TextEditingController(text: data['email']);
    TextEditingController phoneController =
        TextEditingController(text: data['phone']);
    TextEditingController productCategoryController =
        TextEditingController(text: data['productCategory']);
    TextEditingController businessModelController =
        TextEditingController(text: data['businessModel']?.join(', '));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Vendor Profile"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: businessNameController,
                  decoration: InputDecoration(labelText: "Business Name"),
                ),
                TextField(
                  controller: businessTypeController,
                  decoration: InputDecoration(labelText: "Business Type"),
                ),
                TextField(
                  controller: cityController,
                  decoration: InputDecoration(labelText: "City"),
                ),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: "Phone"),
                ),
                TextField(
                  controller: productCategoryController,
                  decoration: InputDecoration(labelText: "Product Category"),
                ),
                TextField(
                  controller: businessModelController,
                  decoration: InputDecoration(labelText: "Business Model"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {

                try {
                  await _firestore.collection("vendors").doc(vendorId).update({
                    "businessName": businessNameController.text,
                    "businessType": businessTypeController.text,
                    "city": cityController.text,
                    "email": emailController.text,
                    "phone": phoneController.text,
                    "productCategory": productCategoryController.text,
                    "businessModel": businessModelController.text.split(', '),
                  });

                  Navigator.pop(context); // Close the dialog

                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Vendor Profile Updated")));

                } catch (e) {
                  // Handle any errors that might occur during the update
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to update: $e")));
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'asset/img.png',
          height: 23,
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF033015),
        iconTheme: IconThemeData(color: Colors.white),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF033015), // Button color
                    foregroundColor: Colors.white, // Text color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => EditProfile())),
                  child: const Text('Update Profile'),
                ),
                const SizedBox(height: 20),
                Divider(
                  color: Colors.black, // Line color
                  thickness: 2, // Line thickness
                  height: 20, // Space around the line
                ),
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
                Divider(
                  color: Colors.black, // Line color
                  thickness: 2, // Line thickness
                  height: 20, // Space around the line
                ),
                const SizedBox(height: 50),
                if (isVendor)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF033015),
                      border: Border.all(color: Colors.green, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Business Details",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.white),
                              onPressed: () {
                                _editVendorProfile({
                                  'businessName': businessName,
                                  'businessType': businessType,
                                  'city': city,
                                  'email': vendorEmail,
                                  'phone': phone,
                                  'productCategory': productCategory,
                                  'businessModel': businessModel,
                                });
                              },
                            ),
                          ],
                        ),
                        Divider(color: Colors.green, thickness: 1),
                        SizedBox(height: 8),
                        Text("📌 Business Name : $businessName",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white)),
                        Text("🏢 Business Type : $businessType",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                        Text("📍 City : $city",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                        Text("📧 Email : $vendorEmail",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                        Text("📞 Phone : $phone",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                        Text("📦 Product Category : $productCategory",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                        Text(
                            "💼 Business Model : ${businessModel?.join(', ')}",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                        SizedBox(height: 12),
                        imageUrl != null
                            ? Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    imageUrl!,
                                    height: 120,
                                    width: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : Center(
                                child: Text("❌ No Image Available",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.white)),
                              ),
                      ],
                    ),
                  ),
                if (isWorker)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF033015),
                      border: Border.all(color: Colors.green, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Worker Details",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.white),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddWorkerScreen(
                                          workerName:
                                              workerName ?? "Default Name")),
                                );
                              },
                            ),
                          ],
                        ),
                        Divider(color: Colors.green, thickness: 1),
                        SizedBox(height: 8),
                        Text("👤 Full Name       : $workerName",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white)),
                        Text("💰 Job Title         : $jobTitle",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                        Text("📍 City                 : $wcity",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                        Text("📞 Phone             : $wphone",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                        Text("📝 Description    : $description",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ],
                    ),
                  ),
                const SizedBox(height: 30),
                Card(
                  color: Colors.grey[300],
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Select Your Role ",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Are You an Vendor ? or worker ?...\nCome Register here ..\nby pushing the toggle button !\n You can register as either a Vendor or a Worker, but not both at the same time.",
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
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
                                            AddWorkerScreen(workerName: name)));
                            },
                    ),
                  ],
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


/*void _editVendorProfile(Map<String, dynamic> data) async {
  // Get the vendor information from session
  Map<String, String?> vendorData = await Session.getVendor();
  String? vendorId = vendorData['vid'];

  if (vendorId == null || vendorId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vendor ID is missing")));
    return;
  }

  // Initialize text controllers with data from the vendor
  TextEditingController businessNameController =
  TextEditingController(text: data['businessName']);
  TextEditingController businessTypeController =
  TextEditingController(text: data['businessType']);
  TextEditingController cityController =
  TextEditingController(text: data['city']);
  TextEditingController emailController =
  TextEditingController(text: data['email']);
  TextEditingController phoneController =
  TextEditingController(text: data['phone']);
  TextEditingController productCategoryController =
  TextEditingController(text: data['productCategory']);
  TextEditingController businessModelController =
  TextEditingController(text: data['businessModel']?.join(', '));

  // To store the selected image URL
  String? imageUrl;

  // Function to pick an image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      String fileName = basename(file.path);

      // Upload image to Firebase Storage
      try {
        TaskSnapshot uploadTask = await _storage
            .ref()
            .child('vendorImages/$vendorId/$fileName')
            .putFile(file);
        imageUrl = await uploadTask.ref.getDownloadURL(); // Get image URL after upload
        print('Image URL: $imageUrl');
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  // Make sure to use BuildContext instead of Context in showDialog or ScaffoldMessenger
  showDialog(
    context: context, // context here must be of type BuildContext
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Edit Vendor Profile"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image picker button
              IconButton(
                icon: Icon(Icons.image),
                onPressed: _pickImage,
                tooltip: 'Pick Company Image',
              ),
              if (imageUrl != null)
                Image.network(imageUrl!), // Show selected image if available
              TextField(
                controller: businessNameController,
                decoration: InputDecoration(labelText: "Business Name"),
              ),
              TextField(
                controller: businessTypeController,
                decoration: InputDecoration(labelText: "Business Type"),
              ),
              TextField(
                controller: cityController,
                decoration: InputDecoration(labelText: "City"),
              ),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: "Phone"),
              ),
              TextField(
                controller: productCategoryController,
                decoration: InputDecoration(labelText: "Product Category"),
              ),
              TextField(
                controller: businessModelController,
                decoration: InputDecoration(labelText: "Business Model"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Update vendor profile data in Firestore
                await _firestore.collection("vendors").doc(vendorId).update({
                  "businessName": businessNameController.text,
                  "businessType": businessTypeController.text,
                  "city": cityController.text,
                  "email": emailController.text,
                  "phone": phoneController.text,
                  "productCategory": productCategoryController.text,
                  "businessModel": businessModelController.text.split(', '),
                  if (imageUrl != null) "profileImage": imageUrl, // Save the image URL if available
                });

                Navigator.pop(context); // Close the dialog

                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Vendor Profile Updated")));
              } catch (e) {
                // Handle any errors that might occur during the update
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to update: $e")));
              }
            },
            child: Text("Save"),
          ),
        ],
      );
    },
  );
}*/

