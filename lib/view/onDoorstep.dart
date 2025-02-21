import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dup/view/Booking.dart';

class Doorsteps extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Doorstep Services", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF033015),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("doorstep_deliveries").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Loading state
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error fetching data!")); // Error state
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No doorstep delivery services available.")); // No data state
          }

          var services = snapshot.data!.docs; // Fetching all service documents

          return ListView.builder(
            padding: EdgeInsets.all(20),
            itemCount: services.length,
            itemBuilder: (context, index) {
              var data = services[index].data() as Map<String, dynamic>;

              String vendorId =data['vendorId'];
              String processingType = data['processingType'] ?? 'Unknown Type'; // Used as title
              String companyName = data['companyName'] ?? 'Unknown Company';
              String address = data['address'] ?? 'No Address';
              String phone = data['phone'] ?? 'No Phone';
              String city = data['city'] ?? 'No City';
              String deliveryArea = data['deliveryArea'] ?? 'No Delivery Area';
              String details = data['details'] ?? 'No Details';
              double price = (data['price'] as num?)?.toDouble() ?? 0.0;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                shadowColor: Colors.green,
                elevation: 5,
                margin: EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Processing Type is now displayed as the title
                      Text(
                        processingType,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        companyName,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),

                      SizedBox(height: 10),
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(3),
                        },
                        children: [
                          _buildTableRow("Address:", address),
                          _buildTableRow("Phone:", phone),
                          _buildTableRow("City:", city),
                          _buildTableRow("Delivery Area:", deliveryArea),
                          _buildTableRow("Details:", details),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        '\$${price.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF380230)),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingPage(
                                  index: index,
                                  serviceName: processingType, // Passed processingType instead
                                  companyName: companyName,
                                  price: price,
                                  userId: FirebaseAuth.instance.currentUser!.uid,
                                  vendorId: vendorId,
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.delivery_dining, color: Colors.white),
                          label: Text("Book your PickUp", style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Helper function to create table rows
  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
