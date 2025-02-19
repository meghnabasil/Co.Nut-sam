import 'package:dup/view/productlist.dart';
import 'package:flutter/material.dart';

class Subscription extends StatefulWidget {
  @override
  _SubscriptionState createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscription> {
  // Map to store product types for each vendor
  final Map<String, String> vendorProductTypes = {
    "Coconut Haven": "Fresh Coconuts",
    "Tropical Delights": "Coconut Oil & By-products",
    "Green Harvest": "Coconut-based Health Supplements",
  };

  final Map<String, int> vendorSubscriptions = {
    "Coconut Haven": 10,
    "Tropical Delights": 15,
    "Green Harvest": 8,
  }; // Quantities added by different vendors

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Subscription Plan")),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: vendorSubscriptions.entries.map((entry) {
              int index = vendorSubscriptions.entries.toList().indexOf(entry); // Get index for each vendor
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("${entry.key} ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      // Add product type under company name
                      Text("Product Type: ${vendorProductTypes[entry.key]}", style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      // Add an image below the company name
                      Image.asset(
                        'assets/images/product_image.jpg', // Replace with your image path
                        height: 100, // Adjust height
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 10),
                      Text("Get fresh organic coconut products delivered to your doorstep."),
                      SizedBox(height: 10),
                      // Add Select button
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to the product detail page and pass necessary parameters
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetail(
                                productIndex: index,
                                vendorId: entry.key, // Assuming the vendorId is the same as the vendor name
                              ),
                            ),
                          );
                        },
                        child: Text("Select Plan"),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
