import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for session handling

class ManageBookingPage extends StatefulWidget {
  @override
  _ManageBookingPageState createState() => _ManageBookingPageState();
}

class _ManageBookingPageState extends State<ManageBookingPage> {
  final CollectionReference bookingsRef = FirebaseFirestore.instance.collection('bookings');
  String? vendorId; // Store the logged-in vendor's ID

  @override
  void initState() {
    super.initState();
    getStoredVendorId(); // Fetch vendorId from session
  }

  // Retrieve vendorId from SharedPreferences
  Future<void> getStoredVendorId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      vendorId = prefs.getString('vid'); // Fetch vendorId from session
    });
  }

  // Function to update a booking's status
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await bookingsRef.doc(bookingId).update({'status': newStatus});
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  // Function to confirm status change before updating
  void confirmStatusChange(BuildContext context, String bookingId, String newStatus) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Status Change"),
          content: Text("Are you sure you want to change the status to '$newStatus'?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                updateBookingStatus(bookingId, newStatus); // Update status
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Bookings", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF033015),
      ),
      body: vendorId == null
          ? Center(child: CircularProgressIndicator()) // Wait for vendorId
          : StreamBuilder<QuerySnapshot>(
        stream: bookingsRef.where('vendorId', isEqualTo: vendorId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error loading bookings"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final bookingDocs = snapshot.data!.docs;
          if (bookingDocs.isEmpty) {
            return Center(child: Text("No bookings available"));
          }

          return ListView.builder(
            itemCount: bookingDocs.length,
            itemBuilder: (context, index) {
              var bookingData = bookingDocs[index].data() as Map<String, dynamic>;
              String bookingId = bookingDocs[index].id;

              return Card(
                margin: EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text("Service: ${bookingData['serviceName']}",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Booked by: ${bookingData['fullName']}\n"
                            "Mobile: ${bookingData['mobileNumber']}"),
                      ),
                      Divider(),
                      Text("Address Details", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        "${bookingData['buildingDetails']}, ${bookingData['area']}, "
                            "${bookingData['townCity']}, ${bookingData['district']}, ${bookingData['pincode']}",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      Text("Landmark: ${bookingData['landmark']}", overflow: TextOverflow.ellipsis),
                      Divider(),
                      Text("Booking Details", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Pickup Date: ${bookingData['pickupDate']}"),
                      Text("Return Date: ${bookingData['returnDate']}"),
                      Text("Total Price: \$${bookingData['price']}"),
                      Text("Status: ${bookingData['status']}",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      SizedBox(height: 10),

                      // Confirm and Cancel Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () => confirmStatusChange(context, bookingId, 'Confirmed'),
                            child: Text('Confirm'),
                          ),
                          ElevatedButton(
                            onPressed: () => confirmStatusChange(context, bookingId, 'Not Confirmed'),
                            child: Text('Cancel'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      // Status Change Buttons
                      Wrap(
                        spacing: 10, // Adjust spacing between buttons horizontally
                        runSpacing: 10, // Adjust spacing between rows
                        alignment: WrapAlignment.center,
                        children: [
                          SizedBox(
                            width: 150, // Set width to ensure two buttons per row
                            child: ElevatedButton(
                              onPressed: () => confirmStatusChange(context, bookingId, 'Delivered'),
                              child: Text('Delivered', style: TextStyle(fontSize: 10)),
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: ElevatedButton(
                              onPressed: () => confirmStatusChange(context, bookingId, 'Processing'),
                              child: Text('Processing', style: TextStyle(fontSize: 10)),
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: ElevatedButton(
                              onPressed: () => confirmStatusChange(context, bookingId, 'On the way'),
                              child: Text('On the way', style: TextStyle(fontSize: 10)),
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: ElevatedButton(
                              onPressed: () => confirmStatusChange(context, bookingId, 'Pickup done'),
                              child: Text('Pickup done', style: TextStyle(fontSize: 10)),
                            ),
                          ),
                        ],
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
