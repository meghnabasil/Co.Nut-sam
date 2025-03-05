import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  List<File> _images = [];
  String? _selectedCategory;
  bool _isUploading = false;

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

      await FirebaseFirestore.instance.collection('products').add({
        'name': _nameController.text,
      //  'company': _companyController.text,
        'price': double.parse(_priceController.text),
        'category': _selectedCategory,
        'description': _descriptionController.text,
        'imageUrls': imageUrls,
        'vendorId': vendorId, // ✅ Added vendor ID here
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isUploading = false;
        _images = [];
        _nameController.clear();
        _companyController.clear();
        _priceController.clear();
        _descriptionController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product uploaded successfully!')),
      );
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Product", style: TextStyle(color: Colors.white)),
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
      ),
    );
  }
}
