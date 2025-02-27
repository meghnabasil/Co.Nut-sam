import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VendorProfilePage extends StatelessWidget {
  final String vid; // Vendor UID

  const VendorProfilePage({super.key, required this.vid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Profile'),
        backgroundColor: const Color(0xFF033015),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('vendors').doc(vid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong!'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Vendor not found'));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(data),
                const SizedBox(height: 20),
                _buildProfileDetail("Business Name", data['businessName']),
                _buildProfileDetail("Email", data['email']),
                _buildProfileDetail("Phone", data['phone']),
                _buildProfileDetail("Address", data['address']),
                _buildProfileDetail("City", data['city']),
                _buildProfileDetail("Business Type", data['businessType']),
                _buildProfileDetail("Product Category", data['productCategory']),
                const SizedBox(height: 10),
                const Text(
                  'Business Models:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (data['businessModel'] != null && data['businessModel'] is List)
                  ...List.generate(
                    (data['businessModel'] as List).length,
                        (index) => Text('- ${data['businessModel'][index]}'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> data) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundImage: AssetImage("assets/profile.jpg"),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['businessName'] ?? "No Business Name",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                data['email'] ?? "No Email",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetail(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        "$title: ${value ?? 'Not available'}",
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
