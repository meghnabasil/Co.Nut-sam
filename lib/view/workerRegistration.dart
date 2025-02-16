import 'package:flutter/material.dart';
import '../controller/worker_controller.dart';

class AddWorkerScreen extends StatefulWidget {
  @override
  _AddWorkerScreenState createState() => _AddWorkerScreenState();
}

class _AddWorkerScreenState extends State<AddWorkerScreen> {
  final _formKey = GlobalKey<FormState>();
  final WorkerController _workerController = WorkerController();

  String workerName = '';
  String jobTitle = '';
  String description = '';
  String phone = '';
  String city = '';

  /// Save Worker Data
  Future<void> _saveWorker() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String? errorMessage = await _workerController.registerWorker(
        workerName,
        jobTitle,
        phone,
        city,
        description,
      );

      if (errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registered as Worker  Successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register as Woker",style: TextStyle(color: Colors.white),), backgroundColor: Color(0xFF033015)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Card(
          elevation: 50,
          shadowColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
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

                  // Description
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Description'),
                    maxLines: 4,
                    validator: (value) => value!.isEmpty ? "Enter a description" : null,
                    onSaved: (value) => description = value!,
                  ),

                  SizedBox(height: 20),

                  // Register Button
                  ElevatedButton(
                    onPressed: _saveWorker,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(const Color(0xFF033015)),
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