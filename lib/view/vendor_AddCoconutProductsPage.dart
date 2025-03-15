import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:uuid/uuid.dart';

import '../controller/session.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Subscription Controllers
  final TextEditingController _subscriptionPriceController =
      TextEditingController();
  final TextEditingController _subscriptionQuantityController =
      TextEditingController();
  final TextEditingController _subscriptionDurationController =
      TextEditingController();
  final TextEditingController _deliveryFrequencyController =
      TextEditingController();

  // Exporting Controllers
  final TextEditingController _exportQuantityController =
      TextEditingController();
  final TextEditingController _shippingCostController = TextEditingController();
  final TextEditingController _exportCountryController =
      TextEditingController();

  TextEditingController _minQuantityController = TextEditingController();
  TextEditingController _maxQuantityController = TextEditingController();
  TextEditingController _insuranceCostController = TextEditingController();
  TextEditingController _portCostController = TextEditingController();
  TextEditingController _costPerWeightController = TextEditingController();

  List<File> _images = [];
  List<String> _selectedCountries = [];
  String? _selectedCategory;
  bool _isUploading = false;
  bool _isSubscription = false;
  bool _isExporting = false;
  Map<String, Map<String, dynamic>> countryPricing = {};

  String? _subscriptionDuration;
  String? _deliveryFrequency;
  String? _selectedCountry;

  final List<String> _subscriptionDurations = ["1 Year", "6 Months"];
  final List<String> _deliveryFrequencies = [
    "Start of each Month",
    "Start of each Month and Mid-Month"
  ];
  final List<String> _exportCountries = [
    "UAE",
    "USA",
    "UK",
    "Canada",
    "Australia"
  ];

  final List<String> _categories = [
    "Fresh Coconuts",
    "Coconut Oil",
    "Tender Coconut",
    "Copra",
    "Copra cake",
    "Coir Products",
    "Coconut-based Food Items",
    "Beauty & Health Products",
    "Coconut Shell & Husk",
  ];

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

 /* Widget _buildTextField(TextEditingController controller, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hint,
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        _updatePricing();
      },
    );
  }*/
  Widget _buildTextField(
      TextEditingController controller,
      String hint, {
        int maxLines = 1,
        TextInputType inputType = TextInputType.text,
      }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hint,
        border: OutlineInputBorder(),
      ),
      keyboardType: inputType,
      maxLines: maxLines,
      onChanged: (value) {
        _updatePricing();
      },
    );
  }



  void _updatePricing() {
    setState(() {
      for (var country in _selectedCountries) {
        double insuranceCost =
            double.tryParse(countryPricing[country]?['insuranceCost'] ?? "0") ??
                0;
        double portCost =
            double.tryParse(countryPricing[country]?['portCost'] ?? "0") ?? 0;
        double minQuantity =
            double.tryParse(countryPricing[country]?['minQuantity'] ?? "0") ??
                0;
        double costPerWeightMin = double.tryParse(
                countryPricing[country]?['costPerWeightMin'] ?? "0") ??
            0;

        double totalCost =
            insuranceCost + portCost + (minQuantity * costPerWeightMin);

        countryPricing[country]!['totalCost'] = totalCost.toStringAsFixed(2);
      }
    });
  }


  Future<void> _uploadProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
    });

    try {
      Map<String, String?> vendorId = await Session.getVendor();
      List<String> imageUrls = [];
      for (File image in _images) {
        String fileName = Uuid().v4();
        Reference ref = FirebaseStorage.instance.ref().child('products/$fileName');
        await ref.putFile(image);
        String downloadURL = await ref.getDownloadURL();
        imageUrls.add(downloadURL);
      }

      // Prepare product data
      Map<String, dynamic> productData = {
        "vendorId": vendorId,
        "name": _nameController.text,
        "category": _selectedCategory,
        "price": double.tryParse(_priceController.text) ?? 0.0,
        "description": _descriptionController.text,
        "images": imageUrls,
        "isSubscription": _isSubscription,
        "isExporting": _isExporting,
        "timestamp": FieldValue.serverTimestamp(),
      };

      // Add subscription details if applicable
      if (_isSubscription) {
        productData.addAll({
          "subscriptionPrice": double.tryParse(_subscriptionPriceController.text) ?? 0.0,
          "subscriptionQuantity": int.tryParse(_subscriptionQuantityController.text) ?? 0,
          "subscriptionDuration": _subscriptionDuration,
          "deliveryFrequency": _deliveryFrequency,
        });
      }

      // Add exporting details if applicable
      if (_isExporting) {
        productData["exportCountries"] = _selectedCountries;
        Map<String, dynamic> exportPricing = {};
        for (var country in _selectedCountries) {
          exportPricing[country] = countryPricing[country];
        }
        productData["exportPricing"] = exportPricing;
      }

      // Save product data in Firestore
      await FirebaseFirestore.instance.collection("products").add(productData);

      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Product added successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Product", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF033015),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            color: Colors.white,
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.all(16),
                        alignment: Alignment.center,
                        child: Text(
                          "Select Product Images",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    _images.isNotEmpty
                        ? Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _images
                                .map((img) => ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: Image.file(img,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover),
                                    ))
                                .toList(),
                          )
                        : Text("No images selected"),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: "Product Category",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? "Select a category" : null,
                    ),
                    SizedBox(height: 10),
                    _buildTextField(_nameController, "Product Name"),
                    SizedBox(height: 10),
                    _buildTextField(_priceController, "Price"),
                    SizedBox(height: 10),
                    _buildTextField(
                        _descriptionController, "Description about Product",
                        maxLines: 5),

                    // ✅ Subscription Checkbox
                    CheckboxListTile(
                      title: Text("Subscription Available"),
                      value: _isSubscription,
                      onChanged: (value) =>
                          setState(() => _isSubscription = value!),
                    ),

                    // ✅ Subscription Fields (Only shown when checked)
                    if (_isSubscription) ...[
                      DropdownButtonFormField<String>(
                        value: _subscriptionDuration,
                        decoration:
                            InputDecoration(labelText: "Subscription Duration"),
                        items: _subscriptionDurations.map((duration) {
                          return DropdownMenuItem(
                              value: duration, child: Text(duration));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _subscriptionDuration =
                                value; // ✅ Ensure value is updated
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _deliveryFrequency,
                        decoration:
                            InputDecoration(labelText: "Delivery Frequency"),
                        items: _deliveryFrequencies.map((frequency) {
                          return DropdownMenuItem(
                              value: frequency, child: Text(frequency));
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _deliveryFrequency = value),
                      ),
                      SizedBox(height: 10),
                      _buildTextField(
                          _subscriptionPriceController, "Subscription Price"),
                      SizedBox(height: 10),
                      _buildTextField(_subscriptionQuantityController,
                          "Subscription Quantity"),
                    ],

                    CheckboxListTile(
                      title: Text("Exporting Available"),
                      value: _isExporting,
                      onChanged: (newValue) {
                        setState(() {
                          _isExporting = newValue!;
                        });
                      },
                    ),

                    if (_isExporting) ...[
                      MultiSelectDialogField(
                        items: _exportCountries
                            .map((country) => MultiSelectItem(country, country))
                            .toList(),
                        title: Text("Select Export Countries"),
                        buttonText: Text("Select Countries"),
                        initialValue: _selectedCountries,
                        onConfirm: (values) {
                          setState(() {
                            _selectedCountries = values.cast<String>();
                            for (var country in _selectedCountries) {
                              if (!countryPricing.containsKey(country)) {
                                countryPricing[country] = {
                                  'insuranceCost': 0.0,
                                  'portCost': "",
                                  'minQuantity': "",
                                  'costPerWeightMin': "",
                                  'maxQuantity': "",
                                  'costPerWeightMax': "",
                                  'costPerWeightAboveMax': "",
                                };
                              }
                            }
                          });
                        },
                      ),
                      SizedBox(height: 10),

                      ..._selectedCountries.map((country) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(country,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(height: 15),
                            _buildTextField(
                              TextEditingController(
                                  text:
                                      countryPricing[country]!['insuranceCost']
                                          .toString()),
                              "Insurance Cost ($country)",
                            ),
                            SizedBox(height: 15),
                            _buildTextField(
                              TextEditingController(
                                  text: countryPricing[country]!['portCost']
                                      .toString()),
                              "Port Cost ($country)",
                            ),
                            SizedBox(height: 15),
                            _buildTextField(
                              TextEditingController(
                                  text: countryPricing[country]!['minQuantity']
                                      .toString()),
                              "Minimum Quantity ($country)",
                            ),
                            SizedBox(height: 15),
                            _buildTextField(
                              TextEditingController(
                                  text: countryPricing[country]![
                                          'costPerWeightMin']
                                      .toString()),
                              "Cost per Weight for Min Quantity ($country)",
                            ),
                            SizedBox(height: 15),
                            _buildTextField(
                              TextEditingController(
                                  text: countryPricing[country]!['maxQuantity']
                                      .toString()),
                              "Maximum Quantity ($country)",
                            ),
                            SizedBox(height: 15),
                            _buildTextField(
                              TextEditingController(
                                  text: countryPricing[country]![
                                          'costPerWeightMax']
                                      .toString()),
                              "Cost per Weight for Max Quantity ($country)",
                            ),
                            SizedBox(height: 15),
                            _buildTextField(
                              TextEditingController(
                                  text: countryPricing[country]![
                                          'costPerWeightAboveMax']
                                      .toString()),
                              "Cost per Weight for Above Max Quantity ($country)",
                            ),
                            Text(
                                "Total Cost for Exporting to $country : ${countryPricing[country]?['totalCost'] ?? '0.00'}",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green)),
                            SizedBox(height: 15),
                          ],
                        );
                      }).toList(),
                    ],
                    SizedBox(height: 20),

                    _isUploading
                        ? Center(child: CircularProgressIndicator())
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _uploadProduct(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF033015),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                padding: EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text("Add Product",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
