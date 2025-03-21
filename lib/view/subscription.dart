import 'package:flutter/material.dart';

class Subscription extends StatefulWidget {
  @override
  _SubscriptionState createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscription> {
  final Map<String, String> vendorProductTypes = {
    "Coconut Haven": "Fresh Coconuts",
    "Tropical Delights": "Coconut Oil & By-products",
    "Green Harvest": "Coconut-based Health Supplements",
  };

  final Map<String, int> vendorSubscriptions = {
    "Coconut Haven": 10,
    "Tropical Delights": 15,
    "Green Harvest": 8,
  };

  void showSubscriptionPlans(String duration) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("$duration Subscription Plans"),
          content: SingleChildScrollView(
            child: Column(
              children: vendorSubscriptions.entries.map((entry) {
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text("${entry.key}",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF033015))),
                        SizedBox(height: 10),
                        Text("Product Type: ${vendorProductTypes[entry.key]}",
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[700])),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text("Select Plan"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
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
          backgroundColor: const Color(0xFF033015),
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text("Subscription Plan",style:TextStyle(color: Colors.white),)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => showSubscriptionPlans("1-Year"),
              child: Card(
                color:  Color(0xFF033015),
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                  width: 300,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text("1-Year Subscription",
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      SizedBox(height: 10),
                      Text(
                          "Enjoy premium access to fresh organic coconut products for a full year.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () => showSubscriptionPlans("6-Month"),
              child: Card(
                color: Colors.grey[900],
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                  width: 300,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text("6-Month Subscription",
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      SizedBox(height: 10),
                      Text(
                          "Get fresh organic products at an affordable plan for six months.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
