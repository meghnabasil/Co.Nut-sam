import 'package:dup/view/Booking.dart';
import 'package:flutter/material.dart';

class Doorsteps extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Doorstep Services", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF033015),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(20),
        itemCount: 4, // Update this with actual service count
        itemBuilder: (context, index) {
          String serviceName = 'Service ${index + 1}';
          String companyName = 'Company Name';
          double price = (index + 1) * 30.0;

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            shadowColor: Colors.green,
            elevation: 8,
            margin: EdgeInsets.only(bottom: 25),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    companyName,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    'Location: City XYZ',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    'Address: City XYZ',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    'Processing Type: Home Service',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    'Details:',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF380230)),
                  ),
                  SizedBox(height: 5),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingPage(
                              index: index,
                              serviceName: serviceName,
                              companyName: companyName,
                              price: price,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delivery_dining, color: Colors.white),
                          SizedBox(width: 10),
                          Text("Book your PickUp", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
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
