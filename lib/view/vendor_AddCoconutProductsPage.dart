import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<File> _images = [];

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Handle form submission logic
      print("Product Added: ${_nameController.text}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Product")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: _pickImages,
                      child: Text("Select Images"),
                    ),
                    SizedBox(height: 10),
                    _images.isNotEmpty
                        ? Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _images.map((img) => Image.file(img, width: 80, height: 80)).toList(),
                    )
                        : Text("No images selected"),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: "Product Name"),
                      validator: (value) => value!.isEmpty ? "Enter product name" : null,
                    ),
                    TextFormField(
                      controller: _companyController,
                      decoration: InputDecoration(labelText: "Company Name"),
                      validator: (value) => value!.isEmpty ? "Enter company name" : null,
                    ),
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(labelText: "Price"),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? "Enter price" : null,
                    ),
                    TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(labelText: "Quantity"),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? "Enter quantity" : null,
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: "Description"),
                      maxLines: 3,
                      validator: (value) => value!.isEmpty ? "Enter description" : null,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text("Submit"),
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
