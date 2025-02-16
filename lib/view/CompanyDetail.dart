import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CompanyDetail extends StatefulWidget {
  final String vendorId;

  CompanyDetail({required this.vendorId});

  @override
  _CompanyDetailState createState() => _CompanyDetailState();
}

class _CompanyDetailState extends State<CompanyDetail> {
  String businessName = "Loading...";
  String address = "";
  String email = "";
  String businessLogo = "asset/default_logo.png";

  @override
  void initState() {
    super.initState();
    fetchVendorDetails();
  }

  void fetchVendorDetails() async {
    try {
      DocumentSnapshot vendorSnapshot = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(widget.vendorId)
          .get();

      if (vendorSnapshot.exists) {
        var vendorData = vendorSnapshot.data() as Map<String, dynamic>;

        setState(() {
          businessName = vendorData["businessName"] ?? "Unknown";
          address = vendorData["address"] ?? "No Address";
          email = vendorData["email"] ?? "No Email";
          businessLogo = vendorData["businessLogo"] ?? "asset/default_logo.png";
        });
      } else {
        setState(() {
          businessName = "No vendor found";
        });
      }
    } catch (e) {
      print("Error fetching vendor details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(businessName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network(
            businessLogo,
            height: 100,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset("asset/default_logo.png", height: 100);
            },
          ),
          SizedBox(height: 10),
          Text("Address: $address"),
          Text("Email: $email"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Close"),
        ),
      ],
    );
  }
}
