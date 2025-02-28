import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddToolPage extends StatefulWidget {
  @override
  _AddToolPageState createState() => _AddToolPageState();
}

class _AddToolPageState extends State<AddToolPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<File> _images = [];
  String? _selectedCategory;
  bool _isUploading = false;

  final List<String> _categories = [
    "Dehusking Machine",
    " Cutter",
    " Scraper",
    " Oil Extractor",
    " Dryer",
    "Coir Fiber Extractor",
    " Grinding Machine",
    "Husk Shredder",
    " Water Processing Machine",
    "Shell Charcoal Machine",
    " Milk Extractor",
    " Powder Making Machine",
  ];

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> _uploadTool() async {
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
      String? vendorId = FirebaseAuth.instance.currentUser?.uid;
      if (vendorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Vendor not authenticated')),
        );
        return;
      }

      List<String> imageUrls = [];
      for (File image in _images) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageRef = FirebaseStorage.instance.ref().child('tool_images/$fileName.jpg');
        UploadTask uploadTask = storageRef.putFile(image);
        TaskSnapshot taskSnapshot = await uploadTask;
        String imageUrl = await taskSnapshot.ref.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      await FirebaseFirestore.instance.collection('tools').add({
        'name': _nameController.text,
        'company': _brandController.text,
        'price': double.parse(_priceController.text),
        'category': _selectedCategory,
        'description': _descriptionController.text,
        'imageUrls': imageUrls,
        'vendorId': vendorId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isUploading = false;
        _images = [];
        _nameController.clear();
        _brandController.clear();
        _priceController.clear();
        _descriptionController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tool uploaded successfully!')),
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
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      ),
      maxLines: maxLines,
      validator: (value) => value!.isEmpty ? "Enter $label" : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Tool", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF033015),
      ),
      body: SingleChildScrollView( // ✅ Prevents overflow
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 5,
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
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text("Select Tool Images"),
                        ),
                      ),
                      SizedBox(height: 10),

                      // ✅ Fixed overflow issue with horizontal scrolling
                      SizedBox(
                        height: 100,
                        child: _images.isNotEmpty
                            ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _images.map((img) => Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(img, width: 80, height: 80, fit: BoxFit.cover),
                              ),
                            )).toList(),
                          ),
                        )
                            : Text("No images selected"),
                      ),

                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: "Tool Category",
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
                      _buildTextField(_nameController, "Tool Name"),
                      SizedBox(height: 10),
                      _buildTextField(_brandController, "Company"),
                      SizedBox(height: 10),
                      _buildTextField(_priceController, "Price"),
                      SizedBox(height: 10),
                      _buildTextField(_descriptionController, "Description", maxLines: 5),
                      SizedBox(height: 20),
                      _isUploading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                        onPressed: _uploadTool,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF033015),
                        ),
                        child: Text("Upload Tool", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
