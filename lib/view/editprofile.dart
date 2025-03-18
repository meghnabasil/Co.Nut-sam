import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import '../controller/session.dart';
import 'bottomnav.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController addressController;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String? userId;
  String? imageUrl;
  bool isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    addressController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    Map<String, String?> sessionData = await Session.getSession();
    userId = sessionData['uid'];

    if (userId == null || userId!.isEmpty) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    try {
      DocumentSnapshot userDoc =
      await _firestore.collection("users").doc(userId).get();

      if (userDoc.exists && mounted) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          nameController.text = data['name'] ?? '';
          emailController.text = data['email'] ?? '';
          addressController.text = data['address'] ?? '';
          imageUrl = data['imageUrl'] ?? '';
          isLoading = false;
        });
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      String fileName = basename(file.path);

      try {
        TaskSnapshot uploadTask = await _storage
            .ref('userImages/$userId/$fileName')
            .putFile(file);
        String newImageUrl = await uploadTask.ref.getDownloadURL();

        if (mounted) {
          setState(() {
            imageUrl = newImageUrl;
          });
        }
      } catch (e) {
        debugPrint('Error uploading image: $e');
      }
    }
  }

  Future<void> _saveProfile(BuildContext context) async {
    if (userId == null) {
      _showSnackBar(context, "User ID not found");
      return;
    }

    try {
      await _firestore.collection("users").doc(userId).update({
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "address": addressController.text.trim(),
        if (imageUrl != null) "imageUrl": imageUrl,
      });

      _showSnackBar(context, "Profile Updated Successfully");
      _navigateToHome(context);
    } catch (e) {
      _showSnackBar(context, "Failed to update profile: $e");
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _navigateToHome(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (_) => const BottomBarScreen(initialIndex: 4)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                    ? NetworkImage(imageUrl!)
                    : const AssetImage('assets/default_profile.png')
                as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField("Name", nameController),
            _buildTextField("Email", emailController,
                keyboardType: TextInputType.emailAddress),
            _buildTextField("Address", addressController),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => _saveProfile(context),
                  child: const Text("Save"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
