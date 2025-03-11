import 'package:flutter/material.dart';
import 'package:dup/controller/Booking_controller.dart';
import 'package:dup/model/Booking_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingPage extends StatefulWidget {
  final int index;
  final String serviceName;
  final String companyName;
  final double price;
  final String userId;
  // Added vendor details
  final String vendorId;

  BookingPage({
    required this.index,
    required this.serviceName,
    required this.companyName,
    required this.price,
    required this.userId,
    required this.vendorId,
  });

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final BookingController _bookingController = BookingController();

  TextEditingController pickupDateController = TextEditingController();
  TextEditingController returnDateController = TextEditingController();

  // Address details controllers
  TextEditingController fullNameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController townCityController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController buildingDetailsController = TextEditingController();
  TextEditingController landmarkController = TextEditingController();

  int quantity = 1;
  String unit = "kg";
  double updatedPrice = 0.0;

  @override
  void initState() {
    super.initState();
    updatedPrice = widget.price;
  }

  void _updatePrice() {
    setState(() {
      double basePrice = widget.price;
      if (unit == "kg") {
        updatedPrice = basePrice * quantity;
      } else if (unit == "ltr") {
        updatedPrice = basePrice * quantity * 0.8;
      }
    });
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text =
        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _confirmBooking() {
    if (fullNameController.text.isEmpty ||
        mobileNumberController.text.isEmpty ||
        stateController.text.isEmpty ||
        townCityController.text.isEmpty ||
        pincodeController.text.isEmpty ||
        areaController.text.isEmpty ||
        buildingDetailsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please enter all required address details"),
      ));
      return;
    }

    Booking newBooking = Booking(
      serviceName: widget.serviceName,
      companyName: widget.companyName,
      price: updatedPrice,
      quantity: quantity,
      unit: unit,
      pickupDate: pickupDateController.text,
      returnDate: returnDateController.text,
      fullName: fullNameController.text,
      mobileNumber: mobileNumberController.text,
      district: stateController.text,
      townCity: townCityController.text,
      pincode: pincodeController.text,
      area: areaController.text,
      buildingDetails: buildingDetailsController.text,
      landmark: landmarkController.text,
      userId: widget.userId,
      vendorId: widget.vendorId,
      createdAt: Timestamp.now(),
    );

    _bookingController.addBooking(newBooking);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Booking Confirmed!"),
    ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book Service", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF033015),
          iconTheme: IconThemeData(color: Colors.white),

    ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildServiceCard(),
            SizedBox(height: 15),
            _buildAddressCard(),
            SizedBox(height: 15),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.serviceName,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
            SizedBox(height: 5),
            Text(widget.companyName, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            SizedBox(height: 10),
            Text("Price: \$${updatedPrice.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF380230))),
            Divider(thickness: 1, color: Colors.grey[300]),
            SizedBox(height: 10),
            _buildQuantityAndUnitSelection(),
            SizedBox(height: 15),
            _buildTextField(pickupDateController, "Select Pickup Date", isDate: true),
            SizedBox(height: 10),
            _buildTextField(returnDateController, "Select Return Date", isDate: true),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Enter Your Address",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
            SizedBox(height: 10),
            _buildTextField(fullNameController, "Full Name"),
            SizedBox(height: 10),
            _buildTextField(mobileNumberController, "Mobile Number", keyboardType: TextInputType.phone),
            SizedBox(height: 10),
            _buildTextField(buildingDetailsController, "house or company name/no"),
            SizedBox(height: 10),
            _buildTextField(areaController, "Area, Street, Sector, Village"),
            SizedBox(height: 10),
            _buildTextField(townCityController, "Town/City"),
            SizedBox(height: 10),
            _buildTextField(stateController, "District"),
            SizedBox(height: 10),
            _buildTextField(pincodeController, "Pincode", keyboardType: TextInputType.number),
            SizedBox(height: 10),
            _buildTextField(landmarkController, "Landmark (Optional)"),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {TextInputType keyboardType = TextInputType.text, bool isDate = false}) {
    return TextField(
      controller: controller,
      readOnly: isDate,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        suffixIcon: isDate ? Icon(Icons.calendar_today, color: Colors.grey[600]) : null,
      ),
      onTap: isDate ? () => _selectDate(context, controller) : null,
    );
  }

  Widget _buildQuantityAndUnitSelection() {
    return Row(
      children: [
        Expanded(
          child: DropdownButton<int>(
            value: quantity,
            items: [1, 2, 3, 4, 5, 10, 20].map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text("$value"),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                quantity = newValue!;
                _updatePrice();
              });
            },
          ),
        ),
        SizedBox(width: 10),
        DropdownButton<String>(
          value: unit,
          items: ["kg", "ltr"].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              unit = newValue!;
              _updatePrice();
            });
          },
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF033015),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: _confirmBooking,
        child: Text("Confirm Booking", style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
