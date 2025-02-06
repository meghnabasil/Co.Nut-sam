import 'package:dup/bottomnav.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // Sample user profile data
  String name = "John Doe";
  String email = "johndoe@example.com";
  String address = "1234 Elm Street, Springfield, IL";
  File? profileImage; // Store the profile picture if updated

  void _pickImage() async {
    // Here you would implement the logic to pick an image from the gallery or camera
    // For this demo, we'll assume we have the image picked already

    setState(() {
      profileImage = File('path/to/your/image.jpg'); // This is just a placeholder
    });
  }

  void _updateProfile() {
    // Navigate to another page or open a dialog to update the profile
    print("Profile updated");

    // In a real app, you would send the updated profile data to a backend or local storage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF033015),
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              // Navigate back to HomeScreen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => BottomBarScreen()),
                    (route) => false,); // Removes all previous routes
            }
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,  // Aligns content to the top
            crossAxisAlignment: CrossAxisAlignment.center,  // Centers content horizontally
            children: [
              // Profile Picture
              GestureDetector(
                onTap: _pickImage, // Pick an image when tapped
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: profileImage != null
                      ? FileImage(profileImage!)
                      : null,
                  child: profileImage == null
                      ? const Icon(Icons.camera_alt, size: 50, color: Colors.brown)
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              // Displaying Name
              Text(
                name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Displaying Email
              Text(
                email,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),

              // Displaying Address
              Text(
                address,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),

              // Update Button
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text('Update Profile'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xFF033015),),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
