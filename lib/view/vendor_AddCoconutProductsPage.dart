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
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Subscription Controllers
  // final TextEditingController _subscriptionPriceController =
  //     TextEditingController();
  // final TextEditingController _subscriptionQuantityController =
  //     TextEditingController();
  // final TextEditingController _subscriptionDurationController =
  //     TextEditingController();
  // final TextEditingController _deliveryFrequencyController =
  //     TextEditingController();

  final TextEditingController _sixMonthPriceController = TextEditingController();
  final TextEditingController _sixMonthQuantityController = TextEditingController();
  final TextEditingController _sixMonthDescriptionController =TextEditingController();
  String? _sixMonthDeliveryFrequency;

  final TextEditingController _oneYearPriceController = TextEditingController();
  final TextEditingController _oneYearQuantityController = TextEditingController();
  final TextEditingController _oneYearDescriptionController=TextEditingController();
  String? _oneYearDeliveryFrequency;


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
  bool _isSixMonthsSelected = false;
  bool _isOneYearSelected = false;

  String? _subscriptionDuration;
  String? _deliveryFrequency;
  String? _selectedCountry;

  final List<String> _subscriptionDurations = ["1 Year", "6 Months"];
  final List<String> _deliveryFrequencies = [
    "Start of each Month",
    "Start of each Month and Mid-Month"
  ];

  @override
  void dispose() {
    _sixMonthPriceController.dispose();
    _sixMonthQuantityController.dispose();
    _oneYearPriceController.dispose();
    _oneYearQuantityController.dispose();
    super.dispose();
  }

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

  Widget _buildExportPricingTextField(
      String label, String country, String key) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          if (!countryPricing.containsKey(country)) {
            countryPricing[country] = {};
          }
          countryPricing[country]![key] = value;
          _updatePricing(); // Ensure the total cost updates dynamically
        });
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
      Map<String, String?> vendorIds = await Session.getVendor();
      String? vendorId = vendorIds['vid'];
      List<String> imageUrls = [];
      print("Uploading vendorID: ........$vendorId");
      // Upload images
      for (File image in _images) {
        String fileName = Uuid().v4();
        Reference ref =
            FirebaseStorage.instance.ref().child('products/$fileName');
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

      DocumentReference productRef = await FirebaseFirestore.instance
          .collection("products")
          .add(productData);

      if (_isExporting) {
        for (var country in _selectedCountries) {
          Map<String, dynamic> exportData = {
            "exportPricing": countryPricing[country],
            "createdAt": FieldValue.serverTimestamp(),
          };

          // Using country name as the document ID instead of auto-generated ID
          await productRef
              .collection("exportingData")
              .doc(country)
              .set(exportData);
        }
      }
      if (_isSubscription) {
        Map<String, dynamic> subscriptionData = {
          "createdAt": FieldValue.serverTimestamp(),
        };

        // ✅ If 6 months subscription is selected, add its details
        if (_isSixMonthsSelected) {
          subscriptionData["sixMonths"] = {
            "price": double.tryParse(_sixMonthPriceController.text) ?? 0.0,
            "quantity": _sixMonthQuantityController.text ?? "",
            "deliveryFrequency": _sixMonthDeliveryFrequency ?? "",
          };
        }

        // ✅ If 1 year subscription is selected, add its details
        if (_isOneYearSelected) {
          subscriptionData["oneYear"] = {
            "price": double.tryParse(_oneYearPriceController.text) ?? 0.0,
            "quantity": _oneYearQuantityController.text ?? "",
            "deliveryFrequency": _oneYearDeliveryFrequency ?? "",
          };
        }

        // ✅ Upload data to Firestore
        await productRef.collection("subscriptionData").add(subscriptionData);
      }


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
                    _buildTextField(_stockController, "stock"),
                    SizedBox(height: 10),
                    _buildTextField(
                        _descriptionController, "Description about Product",
                        maxLines: 5),
                    SizedBox(height: 10),
                  Divider(thickness: 10,color: Colors.grey,),
                    SizedBox(height: 10),


                    // ✅ Subscription Checkbox
                    CheckboxListTile(
                      title: Text("Subscription Available"),
                      value: _isSubscription,
                      onChanged: (value) => setState(() => _isSubscription = value!),
                    ),

                    if (_isSubscription) ...[
                      Text("Select Subscription Duration", style: TextStyle(fontWeight: FontWeight.bold)),

                      // ✅ 6 Months Checkbox
                      CheckboxListTile(
                        title: Text("6 Months"),
                        value: _isSixMonthsSelected,
                        onChanged: (value) {
                          setState(() {
                            _isSixMonthsSelected = value!;
                          });
                        },
                      ),

                      if (_isSixMonthsSelected) ...[
                        _buildTextField(_sixMonthPriceController, "Price for 6 Months"),
                        SizedBox(height: 5),
                        _buildTextField(_sixMonthQuantityController, "Quantity for 6 Months"),
                        SizedBox(height: 5),
                        _buildTextField(_sixMonthDescriptionController, "Details About  6 Months plan",maxLines: 5),
                        SizedBox(height: 5),
                        DropdownButtonFormField<String>(
                          value: _sixMonthDeliveryFrequency,
                          decoration: InputDecoration(labelText: "Delivery Frequency for 6 Months"),
                          items: _deliveryFrequencies.map((frequency) {
                            return DropdownMenuItem(value: frequency, child: Text(frequency));
                          }).toList(),
                          onChanged: (value) => setState(() => _sixMonthDeliveryFrequency = value),
                        ),
                        SizedBox(height: 10),
                      ],

                      // ✅ 1 Year Checkbox
                      CheckboxListTile(
                        title: Text("1 Year"),
                        value: _isOneYearSelected,
                        onChanged: (value) {
                          setState(() {
                            _isOneYearSelected = value!;
                          });
                        },
                      ),

                      if (_isOneYearSelected) ...[
                        _buildTextField(_oneYearPriceController, "Price for 1 Year"),
                        SizedBox(height: 5),
                        _buildTextField(_oneYearQuantityController, "Quantity for 1 Year"),
                        SizedBox(height: 5),
                        _buildTextField(_oneYearDescriptionController, "Details About 1 Year plan",maxLines: 5),
                        SizedBox(height: 5),
                        DropdownButtonFormField<String>(
                          value: _oneYearDeliveryFrequency,
                          decoration: InputDecoration(labelText: "Delivery Frequency for 1 Year"),
                          items: _deliveryFrequencies.map((frequency) {
                            return DropdownMenuItem(value: frequency, child: Text(frequency));
                          }).toList(),
                          onChanged: (value) => setState(() => _oneYearDeliveryFrequency = value),
                        ),
                        SizedBox(height: 10),
                      ],
                    ],


                    SizedBox(height: 10),
                    Divider(thickness: 10,color: Colors.grey,),
                    SizedBox(height: 10),



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
                                  'insuranceCost': '',
                                  'portCost': '',
                                  'minQuantity': '',
                                  'costPerWeightMin': '',
                                  'totalCost': '0',
                                };
                              }
                            }
                          });
                        },
                      ),
                      SizedBox(height: 10),

                      // Generate text fields dynamically for each selected country
                      Column(
                        children: _selectedCountries.map((country) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(country,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 5),
                              _buildExportPricingTextField(
                                  "Insurance Cost", country, 'insuranceCost'),
                              SizedBox(height: 5),
                              _buildExportPricingTextField(
                                  "Port Cost", country, 'portCost'),
                              SizedBox(height: 5),
                              _buildExportPricingTextField(
                                  "Minimum Quantity", country, 'minQuantity'),
                              SizedBox(height: 5),
                              _buildExportPricingTextField("Cost Per Weight",
                                  country, 'costPerWeightMin'),
                              SizedBox(height: 5),
                              _buildExportPricingTextField(
                                  "Maximum Quantity", country, 'maxQuantity'),
                              SizedBox(height: 5),
                              _buildExportPricingTextField("Cost Per Weight",
                                  country, 'costPerWeightMax'),
                              SizedBox(height: 10),
                              SizedBox(height: 5),
                              _buildExportPricingTextField(
                                  "Cost per Weight for Above Max Quantity",
                                  country,
                                  'costPerWeightMax'),
                              SizedBox(height: 10),
                              Text(
                                "Total Cost: ${countryPricing[country]?['totalCost'] ?? '0'}",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green),
                              ),
                              Divider(),
                            ],
                          );
                        }).toList(),
                      ),
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
