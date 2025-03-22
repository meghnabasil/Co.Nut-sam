/*
import 'package:flutter/material.dart';

class ManageOrdersPage extends StatefulWidget {
  @override
  _ManageOrdersPageState createState() => _ManageOrdersPageState();
}

class _ManageOrdersPageState extends State<ManageOrdersPage> {

  final Color primaryColor = Color(0xFF033015);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Orders',
          style: TextStyle(color: Colors.white),

        ),
        iconTheme: IconThemeData(color: Colors.white),

        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount:,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order # - ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Customer: '),
                          Text('Product ID: '),
                          Text('Order Date: '),
                          Text('Delivery Address: '),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DropdownButton<String>(
                                value:,
                                onChanged: (String? newStatus) {
                                  // Only perform action if newStatus is not null and is different.
                                  if (newStatus != null &&
                                      newStatus !=) {
                                    ;
                                  }
                                },
                                items: [
                                  'Pending',
                                  'Processing',
                                  'Shipped',
                                  'Delivered',
                                  'Cancelled'
                                ].map<DropdownMenuItem<String>>((
                                    String status) {
                                  return DropdownMenuItem<String>(
                                    value: status,
                                    child: Text(status),
                                  );
                                }).toList(),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                child: Text('Confirm this order'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dup/view/venddrOrdersTab.dart';
import 'package:dup/view/vendorExportingOrdersTab.dart';
import 'package:flutter/material.dart';
import '../controller/session.dart';

class ManageOrdersPage extends StatefulWidget {
  @override
  _ManageOrdersPageState createState() => _ManageOrdersPageState();
}

class _ManageOrdersPageState extends State<ManageOrdersPage> {
  final Color primaryColor = Color(0xFF033015);
  String? vendorID;

  @override
  void initState() {
    super.initState();
    _getVendorID();
  }

  void _getVendorID() async {
    final sessionData = await Session.getVendor();
    setState(() {
      vendorID = sessionData['vid'];
      print("Vendor Data: $vendorID");
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Manage Orders',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: primaryColor,
          bottom: TabBar(
            indicatorColor: Colors.brown,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Orders"),
              Tab(text: "Exporting Orders"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            VendorOrdersTab(),
            vendorID != null
                ? VendorExportingOrdersTab(vendorID: vendorID!)
                : Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}