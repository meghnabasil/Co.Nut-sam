import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String profileImage = 'asset/210379377.png';

  bool isVendor = false; // Toggle state for Vendor
  bool isWorker = false; // Toggle state for Worker

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = pickedFile.path;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
      if (userDoc.exists) {
        UserModel userModel = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        setState(() {
          name = userModel.name;
          email = userModel.email;
        });
      }
    }
  }

  String getActiveStatus() {
    if (isVendor) {
      return "Active as Vendor";
    } else if (isWorker) {
      return "Active as Worker";
    } else {
      return "Hello Customers";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: 60,
        backgroundColor: const Color(0xFF033015),
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: FileImage(File(profileImage)),
                    child: profileImage.isEmpty
                        ? const Icon(Icons.camera_alt, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Name
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF033015),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Email
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Edit Profile Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => Editprofile()));
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(const Color(0xFF033015)),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                  child: const Text('Edit Profile'),
                ),

                const SizedBox(height: 50),

                // Active Status Bar
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 90),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text(
                    getActiveStatus(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 45),
                const Divider(thickness: 2, color:  Color(0xFF033015)),

                const SizedBox(height: 50),
               Card(
                color: Color(0xFF033015),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                padding: const EdgeInsets.all(16.0),
               child: Column(
               children: [
                // Vendor Registration Card
                Card(
                  elevation: 6,
                  shadowColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  margin: const EdgeInsets.symmetric(horizontal: 30, vertical:5),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Vendor Heading
                        const Text(
                          "Sell your products 🛒",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF033015),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // How to Choose Vendor
                        const Text(
                          "If you own a business selling coconut products like fresh coconuts, oil, coir, or snacks, register as a Vendor.",
                          style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Colors.black54),
                        ),
                        const SizedBox(height: 15),

                        // Toggle & Button for Vendor
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Switch to vendor", style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                            Switch(
                              value: isVendor,
                              onChanged: (value) {
                                setState(() {
                                  isVendor = value;
                                  isWorker = false; // Disable Worker if Vendor is selected
                                });
                                if (value) {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => VendorRegisterScreen()));
                                }
                              },
                              activeColor: Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                // Worker Registration Card
                Card(
                  elevation: 6,
                  shadowColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Worker Heading
                        const Text(
                          " Work and Earn 🔧",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF033015),
                          ),
                        ),
                        const SizedBox(height: 10),


                        // How to Choose Worker
                        const Text(
                          "If you're skilled in coconut-related work like farming, shell crafting, coir processing, or delivery, register as a Worker.",
                          style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Colors.black54),
                        ),
                        const SizedBox(height: 15),

                        // Toggle & Button for Worker
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Switch to Worker", style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                            Switch(
                              value: isWorker,
                              onChanged: (value) {
                                setState(() {
                                  isWorker = value;
                                  isVendor = false; // Disable Vendor if Worker is selected
                                });
                                if (value) {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddWorkerScreen()));
                                }
                              },
                              activeColor: Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],),
    ),
      ),
    ),
    );
  }
}
