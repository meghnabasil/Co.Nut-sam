import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageBookingPage extends StatefulWidget {
  @override
  _ManageBookingPageState createState() => _ManageBookingPageState();
}

class _ManageBookingPageState extends State<ManageBookingPage> {
  // Reference to the bookings collection in Firestore
  final CollectionReference bookingsRef =
  FirebaseFirestore.instance.collection('bookings');

  // Function to update a booking's status in Firestore
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await bookingsRef.doc(bookingId).update({'status': newStatus});
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  // Confirm booking (set status to Confirmed)
  Future<void> confirmBooking(String bookingId) async {
    await updateBookingStatus(bookingId, 'Confirmed');
  }

  // Not confirm booking (set status to Not Confirmed)
  Future<void> notConfirmBooking(String bookingId) async {
    await updateBookingStatus(bookingId, 'Not Confirmed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Bookings", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF033015),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: bookingsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error loading bookings"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Extract the booking documents
          final bookingDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: bookingDocs.length,
            itemBuilder: (context, index) {
              var bookingData =
              bookingDocs[index].data() as Map<String, dynamic>;
              // Save the document ID for updating later
              String bookingId = bookingDocs[index].id;

              return Card(
                margin: EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service and customer info card
                      Card(
                        elevation: 2,
                        child: ListTile(
                          title: Text("Service: ${bookingData['serviceName']}",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              "Booked by: ${bookingData['fullName']}\nMobile: ${bookingData['mobileNumber']}"),
                        ),
                      ),
                      SizedBox(height: 12),
                      // Address details card
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Address Details",
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 6),
                              // Using buildingDetails, area, townCity, district, and pincode
                              Text(
                                "${bookingData['buildingDetails']}, ${bookingData['area']}, ${bookingData['townCity']}, ${bookingData['district']}, ${bookingData['pincode']}",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Landmark: ${bookingData['landmark']}",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      // Booking details card
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Booking Details",
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 6),
                              Text("Pickup Date: ${bookingData['pickupDate']}",
                                  style: TextStyle(fontSize: 14)),
                              Text("Return Date: ${bookingData['returnDate']}",
                                  style: TextStyle(fontSize: 14)),
                              Text("Total Price: \$${bookingData['price']}",
                                  style: TextStyle(fontSize: 14)),
                              Text("Status: ${bookingData['status']}",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue)),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          confirmBooking(bookingId),
                                      child: Text('Confirm'),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          notConfirmBooking(bookingId),
                                      child: Text('Cancel'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      // Status update buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  updateBookingStatus(bookingId, 'Delivered'),
                              child: Text('Delivered',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  updateBookingStatus(bookingId, 'Processing'),
                              child: Text('Processing',
                                  style: TextStyle(fontSize: 11)),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  updateBookingStatus(bookingId, 'On the way'),
                              child: Text('On the way',
                                  style: TextStyle(fontSize: 11)),
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
