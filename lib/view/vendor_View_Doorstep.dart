import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../controller/session.dart';

class VendorServices extends StatefulWidget {
  @override
  _VendorServicesState createState() => _VendorServicesState();
}

class _VendorServicesState extends State<VendorServices> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? vendorId;

  @override
  void initState() {
    super.initState();
    _fetchVendorId();
  }

  Future<void> _fetchVendorId() async {
    var sessionData = await Session.getVendor();
    setState(() {
      vendorId = sessionData['vid'];
    });
  }

  void _editService(String serviceId, Map<String, dynamic> data) {
    TextEditingController priceController = TextEditingController(text: data['price'].toString());
    TextEditingController detailsController = TextEditingController(text: data['details']);
    TextEditingController addressController = TextEditingController(text: data['address']);
    TextEditingController phoneController = TextEditingController(text: data['phone']);
    TextEditingController cityController = TextEditingController(text: data['city']);
    TextEditingController deliveryAreaController = TextEditingController(text: data['delivery_area']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Service"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Price"),
              ),
              TextField(
                controller: detailsController,
                decoration: InputDecoration(labelText: "Details"),
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: "Address"),
              ),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: "Phone"),
              ),
              TextField(
                controller: cityController,
                decoration: InputDecoration(labelText: "City"),
              ),
              TextField(
                controller: deliveryAreaController,
                decoration: InputDecoration(labelText: "Delivery Area"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _firestore.collection("doorstep_deliveries").doc(serviceId).update({
                  "price": double.tryParse(priceController.text) ?? data['price'],
                  "details": detailsController.text,
                  "address": addressController.text,
                  "phone": phoneController.text,
                  "city": cityController.text,
                  "delivery_area": deliveryAreaController.text,
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Service Updated")));
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _deleteService(String serviceId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Service"),
          content: Text("Are you sure you want to delete this service?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmDelete) {
      await _firestore.collection("doorstep_deliveries").doc(serviceId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Service Deleted")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: vendorId == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection("doorstep_deliveries")
            .where("vendorId", isEqualTo: vendorId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error fetching data!"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("You have not added any services."));
          }

          var services = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(20),
            itemCount: services.length,
            itemBuilder: (context, index) {
              var service = services[index];
              var data = service.data() as Map<String, dynamic>;

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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data['processingType'] ?? 'Unknown Type',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editService(service.id, data),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteService(service.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        data['companyName'] ?? 'Unknown Company',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 10),
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(3),
                        },
                        children: [
                          _buildTableRow("Address:", data['address'] ?? 'No Address'),
                          _buildTableRow("Phone:", data['phone'] ?? 'No Phone'),
                          _buildTableRow("City:", data['city'] ?? 'No City'),
                          _buildTableRow("Delivery Area:", data['deliveryArea'] ?? 'No Delivery Area'),
                          _buildTableRow("Details:", data['details'] ?? 'No Details'),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        '\₹${(data['price'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF380230)),
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
