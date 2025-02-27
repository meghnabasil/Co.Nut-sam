import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class addtoolPage extends StatefulWidget {
  @override
  _addtoolPageState createState() => _addtoolPageState();
}

class _addtoolPageState extends State<addtoolPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<File> _images = [];
  String? _selectedCategory;

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

  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      print("Product Added: ${_nameController.text}, Category: $_selectedCategory");
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
                      children: _images
                          .map((img) => ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.file(img, width: 80, height: 80, fit: BoxFit.cover),
                      ))
                          .toList(),
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
                    SizedBox(height: 10),
                    _buildTextField(_companyController, "Company Name"),
                    SizedBox(height: 10),
                    _buildTextField(_priceController, "Price"),
                    SizedBox(height: 10),
                    _buildTextField(_descriptionController, "Description about Product", maxLines: 5),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
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