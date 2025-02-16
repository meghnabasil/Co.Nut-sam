import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Subscription extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Available Subscription Plans")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('subscriptions').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No subscriptions available"));
          }

          var subscriptions = snapshot.data!.docs;

          return ListView.builder(
            itemCount: subscriptions.length,
            itemBuilder: (context, index) {
              var data = subscriptions[index].data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        data['product'] ?? "No Product Name",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 5),

                      // Company Name
                      Text(
                        "Company: ${data['companyName'] ?? 'Unknown'}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.blueGrey,
                        ),
                      ),
                      SizedBox(height: 5),

                      // Duration and Price
                      Text(
                        "Plan: ${data['duration'] ?? 'N/A'} | ₹${data['price'].toString()}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 8),

                      // Description (if available)
                      if (data.containsKey('description') && data['description'] != null)
                        Text(
                          data['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),

                      SizedBox(height: 12),

                      // Subscribe Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to subscription details page if needed
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: Text("Subscribe"),
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
}
