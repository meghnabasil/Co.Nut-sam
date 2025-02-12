import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddWorkerScreen extends StatefulWidget {
  @override
  _AddWorkerScreenState createState() => _AddWorkerScreenState();
}

class _AddWorkerScreenState extends State<AddWorkerScreen> {
  final _formKey = GlobalKey<FormState>();

  String workerName = '';
  String jobTitle = '';
  String description = '';
  String phone = '';
  String city = '';
  String workType = 'Farming'; // Default dropdown value
  File? workerPhoto;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Pick Image from Gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        workerPhoto = File(pickedFile.path);
      });
    }
  }

  /// Add Worker to Firebase
  Future<void> _addWorker() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        await _firestore.collection('workers').add({
          'workerName': workerName,
          'jobTitle': jobTitle,
          'description': description,
          'phone': phone,
          'city': city,
          // 'workType': workType,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Worker Added Successfully!')),
        );

        Navigator.pop(context);
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Worker"), backgroundColor: Color(0xFF033015)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Photo Upload
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: workerPhoto != null ? FileImage(workerPhoto!) : null,
                  child: workerPhoto == null ? Icon(Icons.camera_alt, size: 40) : null,
                ),
              ),
              SizedBox(height: 10),

              // Worker Name
              TextFormField(
                decoration: InputDecoration(labelText: 'Worker Name'),
                validator: (value) => value!.isEmpty ? "Enter worker name" : null,
                onSaved: (value) => workerName = value!,
              ),

              // Job Title
              TextFormField(
                decoration: InputDecoration(labelText: 'Job Title'),
                validator: (value) => value!.isEmpty ? "Enter job title" : null,
                onSaved: (value) => jobTitle = value!,
              ),

              // Job Description
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? "Enter job description" : null,
                onSaved: (value) => description = value!,
              ),

              // Phone
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.length >= 10 ? null : "Enter a valid phone number",
                onSaved: (value) => phone = value!,
              ),

              // City
              TextFormField(
                decoration: InputDecoration(labelText: 'City'),
                validator: (value) => value!.isEmpty ? "Enter city name" : null,
                onSaved: (value) => city = value!,
              ),

              // Work Type Dropdown
              // DropdownButtonFormField(
              //   value: workType,
              //   items: ['Farming', 'Processing', 'Delivery', 'Coir Making', 'Other']
              //       .map((type) => DropdownMenuItem(value: type, child: Text(type)))
              //       .toList(),
              //   onChanged: (value) => setState(() => workType = value as String),
              //   decoration: InputDecoration(labelText: 'Work Type'),
              // ),

              SizedBox(height: 20),

              // Add Worker Button
              ElevatedButton(
                onPressed: _addWorker,
                child: Text("Add Worker"),
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF033015)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
