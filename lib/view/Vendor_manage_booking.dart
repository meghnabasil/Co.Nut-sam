import 'package:flutter/material.dart';

class ManageBookingPage extends StatefulWidget {


  @override
  _ManageBookingPageState createState() => _ManageBookingPageState();
}

class _ManageBookingPageState extends State<ManageBookingPage> {
  List<Map<String, dynamic>> bookings = [
    {
      'serviceName': 'Copra Processing',
      'customerName': 'John Doe',
      'customerMobile': '9876543210',
      'country': 'USA',
      'state': 'California',
      'townCity': 'Los Angeles',
      'pincode': '90001',
      'areaStreet': 'Main Street',
      'flatHouseNo': '12A',
      'landmark': 'Near City Mall',
      'pickupAddress': '123 Main Street, City',
      'pickupDate': '2025-02-20',
      'returnDate': '2025-02-22',
      'totalPrice': 250.0,
      'quantitySelected': 5,
      'status': 'Processing',
    },
    {
      'serviceName': 'Oil Extraction',
      'customerName': 'Jane Smith',
      'customerMobile': '8765432109',
      'country': 'USA',
      'state': 'Texas',
      'townCity': 'Houston',
      'pincode': '77001',
      'areaStreet': 'Elm Street',
      'flatHouseNo': '45B',
      'landmark': 'Near River Park',
      'pickupAddress': '456 Elm Street, Town',
      'pickupDate': '2025-02-21',
      'returnDate': '2025-02-23',
      'totalPrice': 180.0,
      'quantitySelected': 3,
      'status': 'On the way to pick',
    },
  ];


  void updateBookingStatus(int index, String newStatus) {
    setState(() {
      bookings[index]['status'] = newStatus;
    });
  }

  void confirmBooking(int index) {
    setState(() {
      bookings[index]['status'] = 'Confirmed';
    });
  }

  void notConfirmBooking(int index) {
    setState(() {
      bookings[index]['status'] = 'Not Confirmed';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF033015),
        title: Text("Manage Bookings", style: TextStyle(color: Colors.white)),
      ),
      body: ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          var booking = bookings[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    child: ListTile(
                        title: Text("Service Type: ${booking['serviceName']}", style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Booked by: ${booking['customerName']}\nMobile: ${booking['customerMobile']}")
                    ),
                  ),
                  SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Address Details", style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 6),
                          Text("${booking['flatHouseNo']}, ${booking['areaStreet']}, ${booking['townCity']}, ${booking['state']}, ${booking['country']} - ${booking['pincode']}", overflow: TextOverflow.ellipsis, maxLines: 2),
                          SizedBox(height: 6),
                          Text("Landmark: ${booking['landmark']}", overflow: TextOverflow.ellipsis, maxLines: 1),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Booking Details", style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 6),
                          Text("Pickup Date: ${booking['pickupDate']}", style: TextStyle(fontSize: 14)),
                          Text("Return Date: ${booking['returnDate']}", style: TextStyle(fontSize: 14)),
                          Text("Total Price: \$${booking['totalPrice']}", style: TextStyle(fontSize: 14)),
                          Text("Status: ${booking['status']}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue)),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => confirmBooking(index),
                                  child: Text('Confirm'),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => notConfirmBooking(index),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => updateBookingStatus(index, 'Delivered'),
                          child: Text('Delivered',style: TextStyle(fontSize:12)),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => updateBookingStatus(index, 'Processing'),
                          child: Text('Processing',style: TextStyle(fontSize:11)),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => updateBookingStatus(index, 'On the way'),
                          child: Text('On the way',style: TextStyle(fontSize:11)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
