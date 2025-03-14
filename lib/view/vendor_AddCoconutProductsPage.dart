import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dup/view/vendor_viewproduct.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:multi_select_flutter/multi_select_flutter.dart';

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
  final TextEditingController _subscriptionPriceController = TextEditingController();
  final TextEditingController _subscriptionQuantityController = TextEditingController();
  final TextEditingController _subscriptionDurationController = TextEditingController();
  final TextEditingController _deliveryFrequencyController = TextEditingController();


  // Exporting Controllers
  final TextEditingController _exportQuantityController = TextEditingController();
  final TextEditingController _shippingCostController = TextEditingController();
  final TextEditingController _exportCountryController = TextEditingController();

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
  Map<String, Map<String, double>> countryPricing = {};


  String? _subscriptionDuration;
  String? _deliveryFrequency;
  String? _selectedCountry;

  final List<String> _subscriptionDurations = ["1 Year", "6 Months"];
  final List<String> _deliveryFrequencies = ["Start of each Month","Start of each Month and Mid-Month"];
  final List<String> _exportCountries = ["UAE","USA", "UK", "Canada", "Australia"];



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

  Future<void> _uploadProduct() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null || _images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select images')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {

      Map<String, String?> vendorData = await Session.getVendor();
      String? vendorId = vendorData['vid'];
      if (vendorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Vendor not authenticated')),
        );
        return;
      }

      List<String> imageUrls = [];
      for (File image in _images) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageRef = FirebaseStorage.instance.ref().child('product_images/$fileName.jpg');
        UploadTask uploadTask = storageRef.putFile(image);
        TaskSnapshot taskSnapshot = await uploadTask;
        String imageUrl = await taskSnapshot.ref.getDownloadURL();
        imageUrls.add(imageUrl);
      }

 /*     await FirebaseFirestore.instance.collection('products').add({
        'name': _nameController.text,
      //  'company': _companyController.text,
        'price': double.parse(_priceController.text),
        'category': _selectedCategory,
        'description': _descriptionController.text,
        'imageUrls': imageUrls,
        'vendorId': vendorId, // ✅ Added vendor ID here
        'timestamp': FieldValue.serverTimestamp(),
        'subscription': _isSubscription,
        'exporting': _isExporting,

        // Subscription fields
        'subscription': _isSubscription,
        'subscriptionDuration': _isSubscription ? _subscriptionDuration : null, // ✅ FIXED
        'deliveryFrequency': _isSubscription ? _deliveryFrequency : null, // ✅ FIXED
        'subscriptionPrice': _isSubscription ? double.tryParse(_subscriptionPriceController.text) ?? 0.0 : null,
        'subscriptionQuantity': _isSubscription ? int.tryParse(_subscriptionQuantityController.text) ?? 0 : null,

        // Exporting fields
        'exporting': _isExporting,
        'exportCountries': _isExporting ? _selectedCountries : [], // ✅ FIXED
        'shippingCost': _isExporting ? double.tryParse(_shippingCostController.text) ?? 0.0 : null,
        'exportQuantity': _isExporting && _exportQuantityController.text.isNotEmpty
      ? int.tryParse(_exportQuantityController.text) ?? 0
          : 0,


      });*/

      await FirebaseFirestore.instance.collection('products').add({
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'category': _selectedCategory,
        'description': _descriptionController.text,
        'imageUrls': imageUrls,
        'vendorId': vendorId,
        'timestamp': FieldValue.serverTimestamp(),
        'subscription': _isSubscription,
        'subscriptionDuration': _isSubscription ? _subscriptionDuration : null,
        'deliveryFrequency': _isSubscription ? _deliveryFrequency : null,
        'subscriptionPrice': _isSubscription ? double.tryParse(_subscriptionPriceController.text) ?? 0.0 : null,
        'subscriptionQuantity': _isSubscription ? int.tryParse(_subscriptionQuantityController.text) ?? 0 : null,
        'exporting': _isExporting,
        'exportCountries': _isExporting ? _selectedCountries : [],
        'shippingCost': _isExporting ? double.tryParse(_shippingCostController.text) ?? 0.0 : null,
        'exportQuantity': _isExporting && _exportQuantityController.text.isNotEmpty
            ? int.tryParse(_exportQuantityController.text) ?? 0
            : 0,
        'minQuantity': int.tryParse(_minQuantityController.text) ?? 0,
        'maxQuantity': int.tryParse(_maxQuantityController.text) ?? 0,
        'insuranceCost': double.tryParse(_insuranceCostController.text) ?? 0.0,
        'portCost': double.tryParse(_portCostController.text) ?? 0.0,
        'costPerWeight': double.tryParse(_costPerWeightController.text) ?? 0.0,
      });


      setState(() {
        _isUploading = false;
        _isSubscription = false;
        _isExporting = false;
        _images = [];
        _nameController.clear();
        _companyController.clear();
        _priceController.clear();
        _descriptionController.clear();


        _subscriptionDurationController.clear();
        _deliveryFrequencyController.clear();
        _subscriptionPriceController.clear();
        _subscriptionQuantityController.clear();
        _exportCountryController.clear();
        _shippingCostController.clear();
        _exportQuantityController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product uploaded successfully!')),
      );

      //  Delay navigation slightly
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>Viewcocoandtools()),
        );
      });

    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

/*  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5)],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        maxLines: maxLines,
        validator: (value) => value!.isEmpty ? "Enter $label" : null,
      ),
    );
  }*/

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hint,
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        _updatePricing();  // Call dynamic pricing update if needed
      },
    );
  }

  void _updatePricing() {
    int minQuantity = int.tryParse(_minQuantityController.text) ?? 0;
    int maxQuantity = int.tryParse(_maxQuantityController.text) ?? 0;

    if (minQuantity > 0 && maxQuantity > minQuantity) {
      // Add your dynamic pricing logic here
      print("Min Quantity: $minQuantity, Max Quantity: $maxQuantity");
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
                      children: _images.map((img) => ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.file(img, width: 80, height: 80, fit: BoxFit.cover),
                      )).toList(),
                    )
                        : Text("No images selected"),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: "Product Category",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
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
                      validator: (value) => value == null ? "Select a category" : null,
                    ),
                    SizedBox(height: 10),
                    _buildTextField(_nameController, "Product Name"),
                    /*SizedBox(height: 10),
                    _buildTextField(_companyController, "Company Name"),*/
                    SizedBox(height: 10),
                    _buildTextField(_priceController, "Price"),
                    SizedBox(height: 10),
                    _buildTextField(_descriptionController, "Description about Product", maxLines: 5),


                    // ✅ Subscription Checkbox
                    CheckboxListTile(
                      title: Text("Subscription Available"),
                      value: _isSubscription,
                      onChanged: (value) => setState(() => _isSubscription = value!),
                    ),

                    // ✅ Subscription Fields (Only shown when checked)
                    if (_isSubscription) ...[
                      DropdownButtonFormField<String>(
                        value: _subscriptionDuration,
                        decoration: InputDecoration(labelText: "Subscription Duration"),
                        items: _subscriptionDurations.map((duration) {
                          return DropdownMenuItem(value: duration, child: Text(duration));
                        }).toList(),
              onChanged: (value) {
                setState(() {
                  _subscriptionDuration = value; // ✅ Ensure value is updated
                });
              },
                        ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _deliveryFrequency,
                        decoration: InputDecoration(labelText: "Delivery Frequency"),
                        items: _deliveryFrequencies.map((frequency) {
                          return DropdownMenuItem(value: frequency, child: Text(frequency));
                        }).toList(),
                        onChanged: (value) => setState(() => _deliveryFrequency = value),
                      ),
                      SizedBox(height: 10),
                      _buildTextField(_subscriptionPriceController, "Subscription Price"),
                      SizedBox(height: 10),
                      _buildTextField(_subscriptionQuantityController, "Subscription Quantity"),
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
                      /*MultiSelectDialogField(
                        items: _exportCountries.map((country) => MultiSelectItem(country, country)).toList(),
                        title: Text("Select Export Countries"),
                        buttonText: Text("Select Countries"),
                        initialValue: _selectedCountries,
                        onConfirm: (values) {
                          setState(() {
                            _selectedCountries = values.cast<String>();
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      _buildTextField(_shippingCostController, "Shipping Cost"),
                      SizedBox(height: 10),
                      if (_isExporting)
                        _buildTextField(_exportQuantityController, "Export Quantity"),
*/
 /*                     MultiSelectDialogField(
                        items: _exportCountries.map((country) => MultiSelectItem(country, country)).toList(),
                        title: Text("Select Export Countries"),
                        buttonText: Text("Select Countries"),
                        initialValue: _selectedCountries,
                        onConfirm: (values) {
                          setState(() {
                            _selectedCountries = values.cast<String>();
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      _buildTextField(_minQuantityController, "Min Quantity"),
                      SizedBox(height: 10),
                      _buildTextField(_insuranceCostController, "Insurance Cost"),
                      SizedBox(height: 10),
                      _buildTextField(_portCostController, "Port Cost"),
                      SizedBox(height: 10),
                      _buildTextField(_costPerWeightController, "Cost Per Weight (KG/Lit)"),
                      SizedBox(height: 20),
                      _buildTextField(_maxQuantityController, "Max Quantity"),
                      SizedBox(height: 10),
                      if (_isExporting)
                        _buildTextField(_exportQuantityController, "Export Quantity"),
                      SizedBox(height: 10),*/

                      MultiSelectDialogField(
                        items: _exportCountries.map((country) => MultiSelectItem(country, country)).toList(),
                        title: Text("Select Export Countries"),
                        buttonText: Text("Select Countries"),
                        initialValue: _selectedCountries,
                        onConfirm: (values) {
                          setState(() {
                            _selectedCountries = values.cast<String>();
                            // Initialize country pricing for selected countries
                            for (var country in _selectedCountries) {
                              if (!countryPricing.containsKey(country)) {
                                countryPricing[country] = {
                                  'shippingCost': 0.0,
                                  'insuranceCost': 0.0,
                                  'portCost': 0.0,
                                  'costPerWeight': 0.0,
                                };
                              }
                            }
                          });
                        },
                      ),

                    ],
                    SizedBox(height: 20),



                    _isUploading
                        ? Center(child: CircularProgressIndicator())
                        : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _uploadProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF033015),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text("Add Product", style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),);

  }


}
