import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String profileImage = 'https://via.placeholder.com/150'; // Default profile image

  @override
  void initState() {
    super.initState();
    // Initialize with current user data
    _nameController.text = "Current User Name";
    _emailController.text = "user@example.com";
    _addressController.text = "Current Address";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: const Color(0xFF033015),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                // Add functionality to change profile image
              },
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(profileImage),
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    onPressed: () {
                      // Implement image picker functionality
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: "Address",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF033015),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // Implement save functionality
                String updatedName = _nameController.text;
                String updatedEmail = _emailController.text;
                String updatedAddress = _addressController.text;

                // You can now update the user data in your backend or state management
                print("Updated Name: $updatedName");
                print("Updated Email: $updatedEmail");
                print("Updated Address: $updatedAddress");

                Navigator.pop(context); // Go back to the profile screen
              },
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
