import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/vendor_model.dart';

class VendorProfilePage extends StatefulWidget {
  final String vendorId;

  const VendorProfilePage({Key? key, required this.vendorId}) : super(key: key);

  @override
  _VendorProfilePageState createState() => _VendorProfilePageState();
}

class _VendorProfilePageState extends State<VendorProfilePage> {
  late Future<Vendor> vendorFuture;

  @override
  void initState() {
    super.initState();
    vendorFuture = fetchVendorDetails(widget.vendorId);
  }

  Future<Vendor> fetchVendorDetails(String vendorId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(vendorId)
          .get();

      if (doc.exists) {
        return Vendor.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        throw Exception('Vendor not found');
      }
    } catch (e) {
      throw Exception('Error fetching vendor details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendor Profile'),
      ),
      body: FutureBuilder<Vendor>(
        future: vendorFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            Vendor vendor = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300], // Placeholder background color
                    backgroundImage: (vendor.imageUrl != null && vendor.imageUrl!.isNotEmpty)
                        ? NetworkImage(vendor.imageUrl!)
                        : null,
                    onBackgroundImageError: (_, __) {
                      // Handle image loading error
                      // You can set a flag here to show a default image or take other actions
                    },
                    child: (vendor.imageUrl == null || vendor.imageUrl!.isEmpty)
                        ? Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),

                  SizedBox(height: 16),
                  Text(
                    vendor.businessName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(vendor.email),
                  SizedBox(height: 8),
                  Text(vendor.phone),
                  SizedBox(height: 8),
                  Text(vendor.address),
                  SizedBox(height: 8),
                  Text(vendor. businessType),
                  SizedBox(height: 8),
                  Text(vendor.businessModel as String),
                  SizedBox(height: 8),
                  Text('Category: ${vendor.productCategory}'),
                ],
              ),
            );
          } else {
            return Center(child: Text('Vendor not found'));
          }
        },
      ),
    );
  }
}
