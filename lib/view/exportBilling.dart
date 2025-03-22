import 'package:dup/view/payment.dart';
import 'package:flutter/material.dart';

class ExportBilling extends StatefulWidget {
  final String productId;
  final String productName;
  final String image;
  final String vendorId;
  final String selectedDestination;
  final String selectedPlan;
  final String selectedQuantity;
  final String costPerWeight;
  final String insuranceCost;
  final String portCost;

  ExportBilling({
    required this.productId,
    required this.productName,
    required this.image,
    required this.vendorId,
    required this.selectedDestination,
    required this.selectedPlan,
    required this.selectedQuantity,
    required this.costPerWeight,
    required this.insuranceCost,
    required this.portCost,
  });

  @override
  _ExportBillingState createState() => _ExportBillingState();
}

class _ExportBillingState extends State<ExportBilling> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _quantityError;
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _quantityController.text = widget.selectedQuantity; // Set initial quantity
    _calculateTotalPrice(); // Calculate initial total price
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _nameController.dispose();
    _addressLine1Controller.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _validateQuantity(String value) {
    int? enteredQuantity = int.tryParse(value);
    int maxQuantity = int.parse(widget.selectedQuantity);

    if (enteredQuantity == null || enteredQuantity <= 0) {
      setState(() {
        _quantityError = "Quantity must be a positive number.";
      });
    } else if (enteredQuantity > maxQuantity) {
      setState(() {
        _quantityError = "Quantity cannot exceed $maxQuantity.";
      });
    } else {
      setState(() {
        _quantityError = null;
      });
    }

    _calculateTotalPrice(); // Recalculate total price when quantity changes
  }

  void _calculateTotalPrice() {
    int enteredQuantity = int.tryParse(_quantityController.text) ?? 0;
    double costPerWeight = double.tryParse(widget.costPerWeight) ?? 0.0;
    double insuranceCost = double.tryParse(widget.insuranceCost) ?? 0.0;
    double portCost = double.tryParse(widget.portCost) ?? 0.0;

    setState(() {
      _totalPrice =
          (enteredQuantity * costPerWeight) + insuranceCost + portCost;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Export Billing"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Details Card
            Card(
              elevation: 4,
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Product Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Image.network(
                      widget.image,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.image_not_supported,
                            size: 50, color: Colors.grey);
                      },
                    ),
                    SizedBox(height: 10),
                    Text("Product Name: ${widget.productName}",
                        style: TextStyle(fontSize: 16)),
                    Text("Vendor ID: ${widget.vendorId}",
                        style: TextStyle(fontSize: 16)),
                    Text("Product ID: ${widget.productId}",
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),

            // Exporting Details Card
            Card(
              elevation: 4,
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Exporting Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text("Destination: ${widget.selectedDestination}",
                        style: TextStyle(fontSize: 16)),
                    Text("Plan: ${widget.selectedPlan}",
                        style: TextStyle(fontSize: 16)),
                    Text("Cost Per Weight: ₹${widget.costPerWeight}",
                        style: TextStyle(fontSize: 16)),
                    Text("Insurance Cost: ₹${widget.insuranceCost}",
                        style: TextStyle(fontSize: 16)),
                    Text("Port Cost: ₹${widget.portCost}",
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),

            // Quantity Input Field
            Card(
              elevation: 4,
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Enter Quantity",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Quantity",
                        hintText: "Enter quantity",
                        border: OutlineInputBorder(),
                        errorText: _quantityError,
                      ),
                      onChanged: _validateQuantity,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Maximum Allowed Quantity: ${widget.selectedQuantity}",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            // Address Form Card
            Card(
              elevation: 4,
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Shipping Address",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        hintText: "Enter your full name",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.name,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _addressLine1Controller,
                      decoration: InputDecoration(
                        labelText: "Address Line 1",
                        hintText: "Enter your address",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.streetAddress,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        hintText: "Enter your email",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: "Contact number",
                        hintText: "Enter your contact number",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        labelText: "City",
                        hintText: "Enter your city",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.streetAddress,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _stateController,
                      decoration: InputDecoration(
                        labelText: "State",
                        hintText: "Enter your state",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.streetAddress,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _postalCodeController,
                      decoration: InputDecoration(
                        labelText: "Postal Code",
                        hintText: "Enter your postal code",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _countryController,
                      decoration: InputDecoration(
                        labelText: "Country",
                        hintText: "Enter your country",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.streetAddress,
                    ),
                  ],
                ),
              ),
            ),

            // Total Price Card
            Center(
              child: Card(
                elevation: 4,
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total Price",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "₹$_totalPrice",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Confirm Button
            Center(
              child: ElevatedButton(
                 onPressed: _quantityError == null
                    ? () {

                  Map<String, String> shippingAddress = {
                    "fullName": _nameController.text,
                    "addressLine1": _addressLine1Controller.text,
                    "phone": _phoneController.text,
                    "Email":_emailController.text,
                    "city": _cityController.text,
                    "state": _stateController.text,
                    "postalCode": _postalCodeController.text,
                    "country": _countryController.text,
                  };
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentScreen(
                                totalPrice: _totalPrice,
                                productName: widget.productName,
                                productId: widget.productId,
                                vendorId: widget.vendorId,
                                selectedDestination: widget.selectedDestination,
                                selectedPlan: widget.selectedPlan,
                                selectedQuantity: widget.selectedQuantity,
                                costPerWeight: widget.costPerWeight,
                                insuranceCost: widget.insuranceCost,
                                portCost: widget.portCost,
                                shippingAddress: shippingAddress,),
                            ));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Export confirmed!")),
                        );
                      }
                    : null,
                child: Text("Confirm Export"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
