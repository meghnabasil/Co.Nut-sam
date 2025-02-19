import 'package:flutter/material.dart';
import '../controller/Door_controller.dart';

class AddDoorstepDelivery extends StatefulWidget {
  @override
  _AddDoorstepDeliveryState createState() => _AddDoorstepDeliveryState();
}

class _AddDoorstepDeliveryState extends State<AddDoorstepDelivery> {
  final _formKey = GlobalKey<FormState>();
  final DoorstepDeliveryController _controller = DoorstepDeliveryController();

  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController deliveryAreaController = TextEditingController();
  final TextEditingController processingTypeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    companyNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    deliveryAreaController.dispose();
    processingTypeController.dispose();
    priceController.dispose();
    detailsController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      double? price = double.tryParse(priceController.text);
      if (price == null || price <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid price')),
        );
        setState(() => _isLoading = false);
        return;
      }

      String? result = await _controller.addDoorstepDelivery(

        companyNameController.text,
        phoneController.text,
        addressController.text,
        cityController.text,
        deliveryAreaController.text,
        processingTypeController.text,
        price,
        detailsController.text,
      );

      setState(() => _isLoading = false);

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doorstep Delivery Added Successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Doorstep Delivery")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5, // Adds a slight shadow effect
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Rounded card
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  buildTextField("Company Name", companyNameController),
                  buildTextField("Phone", phoneController, keyboardType: TextInputType.phone),
                  buildTextField("Address", addressController),
                  buildTextField("City", cityController),
                  buildTextField("Limited Delivery Area", deliveryAreaController),
                  buildTextField("Processing Type", processingTypeController),
                  buildTextField("Price", priceController, keyboardType: TextInputType.number),
                  buildTextField("Details", detailsController, maxLines: 3),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF033015),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: _isLoading ? null : _submitForm,
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : const Text("Submit", style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// **Rounded TextFormField Builder**
  Widget buildTextField(
      String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[200], // Light background for better contrast
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35), // Rounded corners, // No border
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16), // Padding inside text field
        ),
        validator: (value) => value!.isEmpty ? "$label is required" : null,
      ),
    );
  }
}
