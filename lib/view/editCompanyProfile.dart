import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dup/view/bottomnav.dart';
import 'package:dup/view/profile.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import '../controller/session.dart';

class EditCompanyProfile extends StatefulWidget {
  final String? vendorId;

  EditCompanyProfile({required this.vendorId, super.key});

  @override
  State<EditCompanyProfile> createState() => _EditCompanyProfileState();
}

class _EditCompanyProfileState extends State<EditCompanyProfile> {
  late TextEditingController businessNameController;
  late TextEditingController businessTypeController;
  late TextEditingController cityController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController productCategoryController;
  late TextEditingController businessModelController;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String? vendorId;
  String? vendorAddress;
  List<String>? businessModel;
  String? businessName;
  String? businessType;
  String? city;
  String? vendorEmail;
  String? imageUrl;
  String? phone;
  String? productCategory;
  bool isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    businessNameController = TextEditingController();
    businessTypeController = TextEditingController();
    cityController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    productCategoryController = TextEditingController();
    businessModelController = TextEditingController();

    _loadVendorData();
  }

  Future<void> _loadVendorData() async {
    // Fetch vendor ID from session
    Map<String, String?> vendorData = await Session.getVendor();
    vendorId = vendorData['vid'];

    if (vendorId == null || vendorId!.isEmpty) {
      print("No vendor ID found in session.");
      setState(() => isLoading = false);
      return;
    }

    await _loadVendorDetails(vendorId!);
  }

  Future<void> _loadVendorDetails(String vendorId) async {
    print("Fetching vendor details for ID: $vendorId");

    try {
      DocumentSnapshot vendorDoc =
          await _firestore.collection("vendors").doc(vendorId).get();

      if (!vendorDoc.exists) {
        print("Vendor document does not exist!");
        setState(() => isLoading = false);
        return;
      }

      Map<String, dynamic> vendorData =
          vendorDoc.data() as Map<String, dynamic>;
      print("Vendor Data: $vendorData");

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

        businessNameController.text = businessName ?? '';
        businessTypeController.text = businessType ?? '';
        cityController.text = city ?? '';
        emailController.text = vendorEmail ?? '';
        phoneController.text = phone ?? '';
        productCategoryController.text = productCategory ?? '';
        businessModelController.text = businessModel?.join(', ') ?? '';

        isLoading = false;
      });
    } catch (e) {
      print("Error fetching vendor details: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      String fileName = basename(file.path);

      try {
        TaskSnapshot uploadTask = await _storage
            .ref('vendorImages/$vendorId/$fileName')
            .putFile(file);
        imageUrl = await uploadTask.ref.getDownloadURL();
        setState(() {}); // Update UI
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Company Profile")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.image),
                    onPressed: _pickImage,
                    tooltip: 'Pick Company Image',
                  ),
                  if (imageUrl != null) Image.network(imageUrl!),
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
                                .collection("vendors")
                                .doc(vendorId)
                                .update({
                              "businessName": businessNameController.text,
                              "businessType": businessTypeController.text,
                              "city": cityController.text,
                              "email": emailController.text,
                              "phone": phoneController.text,
                              "productCategory": productCategoryController.text,
                              "businessModel":
                                  businessModelController.text.split(', '),
                              if (imageUrl != null) "imageUrl": imageUrl,
                            });

                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BottomBarScreen(initialIndex: 4,),
                                ));

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Vendor Profile Updated")),
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
    businessNameController.dispose();
    businessTypeController.dispose();
    cityController.dispose();
    emailController.dispose();
    phoneController.dispose();
    productCategoryController.dispose();
    businessModelController.dispose();
    super.dispose();
  }
}
