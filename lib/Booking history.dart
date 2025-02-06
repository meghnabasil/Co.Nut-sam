import 'package:flutter/material.dart';

class BookingHistoryPage extends StatelessWidget {
  final List<Map<String, String>> bookingHistory;

  BookingHistoryPage({required this.bookingHistory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Booking History", style: TextStyle(color: Colors.white)),
      //   backgroundColor: Color(0xFF033015),
      //   iconTheme: IconThemeData(color: Colors.white),
      // ),
      body: bookingHistory.isEmpty
          ? Center(
        child: Text("No booking history available", style: TextStyle(fontSize: 16, color: Colors.grey)),
      )
          : ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: bookingHistory.length,
        itemBuilder: (context, index) {
          final booking = bookingHistory[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            margin: EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Service: ${booking["service"]}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("Company: ${booking["company"]}", style: TextStyle(color: Colors.grey[700])),
                  Text("Price: \$${booking["price"]}", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF380230))),
                  Text("Pickup Date: ${booking["pickupDate"]}", style: TextStyle(color: Colors.grey[700])),
                  Text("Return Date: ${booking["returnDate"]}", style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
