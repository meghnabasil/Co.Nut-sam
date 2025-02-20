import 'dart:io';
import 'package:dup/controller/session.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/vendor_controller.dart';

class VendorRegisterScreen extends StatefulWidget {
  @override
  _VendorRegisterScreenState createState() => _VendorRegisterScreenState();
}

class _VendorRegisterScreenState extends State<VendorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final VendorController _vendorController = VendorController();

  String businessName = '';
  String phone = '';
  String address = '';
  String city = '';
  String businessType = 'Farm';
  String productCategory = '';
  List<String> selectedBusinessTypes = [];
  File? businessLogo;
  bool agreedToTerms = false;

  /// Pick Image from Gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        businessLogo = File(pickedFile.path);
      });
    }
  }

  /// Save Vendor Data
  Future<void> _saveVendor() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String? vendorID = await _vendorController.registerVendor(
        businessName,
        phone,
        address,
        city,
        businessType,
        productCategory,
        selectedBusinessTypes,
      );
      print(vendorID);
      if (vendorID != null && !vendorID.contains("User not logged in")) {
        await Session.saveVendor(vendorID);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$vendorID Vendor Registered Successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vendorID??"Error registering vendor""Error registering vendor")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "Vendor Registration",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF033015)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Card(
          shadowColor: Colors.green,
          elevation: 30,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Business Logo Upload
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: businessLogo != null
                          ? FileImage(businessLogo!)
                          : null,
                      child: businessLogo == null
                          ? Icon(Icons.camera_alt, size: 40)
                          : null,
                    ),
                  ),
                  SizedBox(height: 10),

                  // Business Name
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Business Name'),
                    validator: (value) =>
                        value!.isEmpty ? "Enter business name" : null,
                    onSaved: (value) => businessName = value!,
                  ),

                  // Phone
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.length >= 10
                        ? null
                        : "Enter a valid phone number",
                    onSaved: (value) => phone = value!,
                  ),

                  // Address
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Business Address'),
                    validator: (value) =>
                        value!.isEmpty ? "Enter address" : null,
                    onSaved: (value) => address = value!,
                  ),

                  // City
                  TextFormField(
                    decoration: InputDecoration(labelText: 'City'),
                    validator: (value) =>
                        value!.isEmpty ? "Enter city name" : null,
                    onSaved: (value) => city = value!,
                  ),

                  // Business Type Dropdown
                  DropdownButtonFormField(
                    value: businessType,
                    items: ['Farm', 'Manufacturer', 'Retailer']
                        .map((type) =>
                            DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => businessType = value as String),
                    decoration: InputDecoration(labelText: 'Business Type'),
                  ),

                  // Product Category
                  TextFormField(
                    decoration: InputDecoration(
                        labelText:
                            'Product Category (coconut oil, copra, etc.)'),
                    onChanged: (value) =>
                        setState(() => productCategory = value),
                  ),

                  SizedBox(height: 20),

                  // Business Model (Checkboxes)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Business Model",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Wrap(
                        spacing: 10,
                        children: [
                          'Wholesale',
                          'Retail',
                          'International Exporting'
                        ]
                            .map((model) => CheckboxListTile(
                                  title: Text(model),
                                  value: selectedBusinessTypes.contains(model),
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedBusinessTypes.add(model);
                                      } else {
                                        selectedBusinessTypes.remove(model);
                                      }
                                    });
                                  },
                                ))
                            .toList(),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  SizedBox(height: 10),

                  // Register Button
                  ElevatedButton(
                    onPressed: _saveVendor,
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xFF033015)),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                    child: const Text('Register'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
