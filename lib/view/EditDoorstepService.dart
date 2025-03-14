import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditDoorstepService extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> serviceData;

  EditDoorstepService({required this.docId, required this.serviceData});

  @override
  _EditDoorstepServiceState createState() => _EditDoorstepServiceState();
}

class _EditDoorstepServiceState extends State<EditDoorstepService> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _companyNameController ;
  late TextEditingController _priceController;
  late TextEditingController _detailsController;

  @override
  void initState() {
    super.initState();
    _companyNameController  = TextEditingController(text: widget.serviceData['companyName']);
    _priceController = TextEditingController(text: widget.serviceData['price'].toString());
    _detailsController = TextEditingController(text: widget.serviceData['details']);
  }

  Future<void> _updateDelivery() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection("doorstep_deliveries").doc(widget.docId).update({
          "companyName": _companyNameController .text,
          "price": double.parse(_priceController.text),
          "details": _detailsController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Service updated successfully")));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update service")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Doorstep Service")),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller:  _companyNameController , decoration: InputDecoration(labelText: "CompanyName")),
              TextFormField(controller: _priceController, decoration: InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
              TextFormField(controller: _detailsController, decoration: InputDecoration(labelText: "Details")),

              SizedBox(height: 20),
              ElevatedButton(onPressed: _updateDelivery, child: Text("Update Service")),
            ],
          ),
        ),
      ),
    );
  }
}
